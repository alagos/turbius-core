require "#{Rails.root}/lib/modules/scrape_utils.rb"
namespace :scraping do

  include ScrapeUtils

  desc 'Get a list of actual cities'
  task :cities => :environment do
    scraping_setup
    get_cities(Time.now) do |city|
      puts "#{city.children[0].text}"
    end
  end

  desc 'Do a full scraping, getting all the trips and itineraries info'
  task :full => :environment do#, [:arg1, :arg2] do |t, args|
    cities = Settings.cities
    # cities = %w{Angol Chillan}
    date_from = 1.day.from_now.to_i
    date_to = 1.months.from_now.to_i
    date_step = 3.days
    cities.combination(2).each do |origin, destination|
      trip = Trip.find_or_create_by(origin: origin, destination: destination)
      if trip.available?
        scraping_setup
        (date_from..date_to).step(date_step) do |date|

          # Best prices request for three days
          # date = Time.at(d)
          best_prices = get_best_prices(origin, destination, Time.at(date)) do |best_price|
            itineraries = get_itineraries(bp) do |itinerary|
              get_seats(itinerary)
            end
          end
          unless best_prices
            logger.debug "No itineraries to #{origin} - #{destination} at #{date}"
            if trip.itineraries.blank?
              puts "No itineraries to #{origin} - #{destination} trip"
              trip.set_unavailable
              break
            end
          end

          best_prices = post_index(best_prices_params(origin, destination, date))
          best_prices_dom = Nokogiri::HTML(best_prices.body).xpath(best_prices_xpath)

          # If there's a best price response, it will start to analyze each row
          if best_prices_dom.any?
            best_prices_dom.each do |best_price|
              puts "Scraping trip #{origin} - #{destination} at #{best_price.children[0].content}"
              # First, choosing the best price row
              # debugger
              best_price_id = best_price.xpath(best_prices_link_xpath).children[0][:id]
              post_best_price(best_price_row_params(best_price_id))

              # Then goes to the itinerary page
              # get_itineraries
              itineraries = Nokogiri::HTML(post_best_price(itineraries_params).body)
              itineraries_dom = itineraries.xpath(itineraries_xpath)
              if itineraries_dom && itineraries_dom.children.any?
                analyze_itineraries(itineraries_dom, trip)

                # Checks if there are more pages
                pages = itineraries.css(itinerary_pages_css).children.size
                puts "\t --Found #{pages} pages"
                pages.times do |page|
                  puts "\t --Analyzing page #{page + 2}"
                  itineraries = Nokogiri::HTML(post_itinerary(itinerary_page_params(page + 2)).body)
                  itineraries_dom = itineraries.xpath(itineraries_xpath)
                  if itineraries_dom && itineraries_dom.children.any?
                    analyze_itineraries(itineraries_dom, trip)
                  else
                    error = itineraries.xpath(error_xpath)[0].content
                    puts "---Itineraries to #{origin} - #{destination} at #{date}: #{error}"

                    #'Seleccione un Itinerario para la Ida'
                    # puts "Itineraries to #{origin} - #{destination} at #{date}: #{error}"
                    # debugger
                  end
                end
              else
                error = itineraries.xpath(error_xpath)[0].content
                #'Seleccione un Itinerario para la Ida'
                if error == 'Seleccione un Itinerario para la Ida'
                  puts "\tTrying once again #{origin} - #{destination} at #{best_price.children[0].content}"
                  post_best_price(best_price_row_params(best_price_id))
                  itineraries = Nokogiri::HTML(post_best_price(itineraries_params).body)
                  itineraries_dom = itineraries.xpath(itineraries_xpath)
                  if itineraries_dom && itineraries_dom.children.any?
                    analyze_itineraries(itineraries_dom, trip)

                    # Checks if there are more pages
                    pages = itineraries.css(itinerary_pages_css).children.size
                    puts "\t --Found #{pages} pages"
                    pages.times do |page|
                      puts "\t --Analyzing page #{page + 2}"
                      itineraries = Nokogiri::HTML(post_itinerary(itinerary_page_params(page + 2)).body)
                      itineraries_dom = itineraries.xpath(itineraries_xpath)
                      if itineraries_dom && itineraries_dom.children.any?
                        analyze_itineraries(itineraries_dom, trip)
                      else
                        error = itineraries.xpath(error_xpath)[0].content
                        if error == 'Seleccione un Itinerario para la Ida'
                          post_best_price(best_price_row_params(best_price_id))
                        end
                        #'Seleccione un Itinerario para la Ida'
                        puts "-Itineraries to #{origin} - #{destination} at #{date}: #{error}"
                        # debugger
                      end
                    end
                  else
                    error = itineraries.xpath(error_xpath)[0].content
                    #'Seleccione un Itinerario para la Ida'
                    puts "--Itineraries to #{origin} - #{destination} at #{date}: #{error}"
                    # debugger
                  end
                else
                  puts "--Itineraries to #{origin} - #{destination} at #{date}: #{error}"
                end

                # debugger
              end
            end
          else
            logger.debug "No itineraries to #{origin} - #{destination} at #{date}"
            if trip.itineraries.blank?
              puts "No itineraries to #{origin} - #{destination} trip"
              trip.set_unavailable
              break
            end
          end
        end # (date_from..date_to).step(3.days)
        # if trip.itineraries.blank?
        #   puts "No itineraries to #{origin} - #{destination} trip"
        #   trip.set_unavailable
        # end
      # else
        # break
      end # if trip.available?


    end # cities.combination(2).each do |origin, destination|
  end

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
    # date = Time.at(d)
    best_prices = post_index(best_prices_params(origin, destination, date))
    best_prices_dom = Nokogiri::HTML(best_prices.body).xpath(best_prices_xpath)
    if best_prices_dom.any?
      best_prices_dom.each do |best_price|
        block.call(best_price)
      end if block
      best_prices_dom
    end
  end

  def get_itineraries

  end

  def get_seats

  end

  def analyze_itineraries(itineraries_dom, trip)
    itineraries_dom.children.each do |itinerary_dom|
      params = Itinerary.params_by_dom(itinerary_dom)
      itinerary = Itinerary.find_same_itinerary(params)

      # If is a new itinerary or their fare has changed, it will save
      if !itinerary || itinerary.fare != params[:fare]
        itinerary = Itinerary.new(params) if !itinerary
        puts "\t#{itinerary.departure_time}/#{itinerary.seat_type}: #{itinerary.price}"
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
      else
        puts "\tNo changes for #{params[:departure_date]} with #{params[:fare]}"
      end
    end

  end
end
