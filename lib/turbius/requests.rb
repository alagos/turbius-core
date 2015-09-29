module Turbius
  module Requests

    include Turbius::ScrapeUtils

    def get_cities(date, &block)
      cities = post_index(cities_params(date))
      cities_dom = Nokogiri::HTML(cities.body).xpath(cities_xpath)
      if cities_dom.any?
        cities_dom.each do |city_dom|
          block.call(city_dom)
        end if block
        cities_dom
      end
    end

    def get_best_prices(origin, destination, date, &block)
      request = post_index(best_prices_params(origin, destination, date)) do |best_prices|
        save_html("#{origin} #{destination}", best_prices.body, date)
        best_prices_dom = Nokogiri::HTML(best_prices.body).xpath(itineraries_xpath)
        block.call(best_prices_dom)
      end
      Turbius::RequestsQueue.enqueue request
    end

    def get_itineraries(origin, destination, date, &block)
      request = post_index(best_prices_params(origin, destination, date)) do |itineraries|
        save_html("#{origin} #{destination}", itineraries.body, date)
        itineraries_dom = Nokogiri::HTML(itineraries.body).xpath(itineraries_xpath)
        if itineraries_dom && itineraries_dom.children.any?
          if block
            itineraries_dom.children.each do |itinerary_dom|
              block.call(itinerary_dom)
            end

            get_itinerary_pages(itineraries) do |itinerary_dom|
              block.call(itinerary_dom)
            end
          else
            get_itinerary_pages(itineraries)
          end
          itineraries_dom
        end
      end
      Turbius::RequestsQueue.enqueue request
    end

    def get_itinerary_pages(itineraries, &block)
      itineraries_dom = Nokogiri::HTML(itineraries.body)
      count = 1
      loop do
        has_next_page = itineraries_dom.css(itinerary_next_page_css).children.any?
        if has_next_page
          logger.info "\t --- Analyzing page #{count+= 1} ---"
          itineraries = post_itinerary(itinerary_page_params('next'))
          itineraries_dom = Nokogiri::HTML(itineraries.body)
          itinerary_table = itineraries_dom.xpath(itineraries_xpath)
          if itinerary_table && itinerary_table.children.any?
            itinerary_table.children.each do |itinerary_dom|
              block.call(itinerary_dom)
            end if block
          end
        else
          break
        end
      end
    end

    def get_seats(itinerary_dom, trip)
      params = Itinerary.params_by_dom(itinerary_dom)
      itinerary = Itinerary.find_same_itinerary(params)
      # Some days display itineraries for the next day, those shouldn't be saved
      if itinerary_dom.css(itinerary_for_tomorrow_css).children.any?
        logger.info "\tTomorrow: #{itinerary.departure_time} with #{itinerary.price}"
      # If is a new itinerary or their fare has changed, it will be saved
      elsif !itinerary || itinerary.fare != params[:fare]
        itinerary = Itinerary.new(params) if !itinerary
        logger.info "\t#{itinerary.departure_time}/#{itinerary.seat_type}: #{itinerary.price}"
        itinerary.fare = params[:fare] if itinerary.fare != params[:fare]

        # Selecting actual itinerary
        post_itinerary(select_itinerary_params(
          itinerary_dom.children.last.children.first[:id]
        ))

        # Then goes to the seat selection page
        seats = post_itinerary(seats_params)
        seats_dom = Nokogiri::HTML(seats.body).css(seats_css)
        itinerary.total_seats = seats_dom.size / 2
        itinerary.free_seats = itinerary.total_seats - seats_dom.css('img').size
        itinerary.trip = trip
        itinerary.save
        logger.info "\t* total_seats:#{itinerary.total_seats} - free_seats:#{itinerary.free_seats}"
        itinerary
      else
        logger.info "\tNo changes for #{itinerary.departure_time} with #{itinerary.price}"
      end
    end

  end
end
