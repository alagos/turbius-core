require "#{Rails.root}/lib/modules/scrape_utils.rb"
require 'pry'

namespace :scraping do

  include ScrapeUtils

  desc 'Get a list of actual cities'
  task :cities => :environment do
    scraping_setup
    get_cities(Time.now) do |city|
      puts "#{city.children[0].text}"
    end
  end

  desc 'Get all the available trips'
  task :trips => :environment do
    date = 1.day.from_now
    Settings.cities.combination(2).each do |origin, destination|
      trip = Trip.find_or_initialize_by(origin: origin, destination: destination)
      scraping_setup
      unless trip.persisted?
        puts "Scraping trip #{origin} - #{destination} at #{date}"
        best_prices = get_best_prices(origin, destination, Time.at(date)) do |best_price_dom|
          puts "\t#{best_price_dom.content.gsub(/\n/, ' ')}"
        end
        unless best_prices
          if trip.itineraries.blank?
            puts "No itineraries for #{origin} - #{destination} trip"
            trip.set_unavailable
          end
        end
        trip.save
      end
    end
  end

  desc 'Do a full scraping, getting all the trips and itineraries info'
  task :full => :environment do
    cities = Settings.cities
    date_from = 1.day.from_now.to_i
    date_to   = 1.months.from_now.to_i
    date_step = 3.days
    cities.combination(2).each do |origin, destination|
      trip = Trip.find_or_create_by(origin: origin, destination: destination)
      puts "origin: #{origin}, destination: #{destination}"
      if trip.available?
        puts "available"
        scraping_setup
        (date_from..date_to).step(date_step) do |date|
          puts "date:#{Time.at(date)}"

          # Best prices request for three days
          best_prices = get_best_prices(origin, destination, Time.at(date)) do |best_price_dom|
            puts "Scraping trip #{origin} - #{destination} at #{best_price_dom.children[0].content}"
            itineraries = get_itineraries(best_price_dom) do |itinerary_dom|
              get_seats(itinerary_dom, trip)
            end
            if itineraries == 'Seleccione un Itinerario para la Ida'
              puts "\t Trying once again"
              get_itineraries(best_price_dom) do |itinerary_dom|
                get_seats(itinerary_dom, trip)
              end
              # logger.info "--Itineraries to #{origin} - #{destination} at #{date}: #{error}"
              # error
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

        end # (date_from..date_to).step(3.days)
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
    best_prices = post_index(best_prices_params(origin, destination, date))
    best_prices_dom = Nokogiri::HTML(best_prices.body).xpath(best_prices_xpath)
    if best_prices_dom.any?
      best_prices_dom.each do |best_price_dom|
        block.call(best_price_dom)
      end if block
      best_prices_dom
    end
  end

  def get_itineraries(best_price_dom, &block)
    # First, choosing the best price row
    best_price_id = best_price_dom.css(best_prices_link_css).children[0][:id]
    post_best_price(best_price_row_params(best_price_id))

    # Then goes to the itinerary page
    itineraries = Nokogiri::HTML(post_best_price(itineraries_params).body)
    itineraries_dom = itineraries.xpath(itineraries_xpath)
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
    else
      error = itineraries.xpath(error_xpath)
      if error && error[0]
        error[0].content
      else
        debugger
      end
    end
  end

  def get_itinerary_pages(itineraries, &block)
    # Checks if there are more pages
    pages = itineraries.css(itinerary_pages_css).children.size
    puts "\t --Found #{pages} pages"
    pages.times do |page|
      puts "\t --Analyzing page #{page + 2}"
      itineraries = Nokogiri::HTML(post_itinerary(itinerary_page_params(page + 2)).body)
      itineraries_dom = itineraries.xpath(itineraries_xpath)
      if itineraries_dom && itineraries_dom.children.any?
        itineraries_dom.children.each do |itinerary_dom|
          block.call(itinerary_dom)
        end if block
      end
    end
  end

  def get_seats(itinerary_dom, trip)
    params = Itinerary.params_by_dom(itinerary_dom)
    itinerary = Itinerary.find_same_itinerary(params)

    # If is a new itinerary or their fare has changed, it will save
    if !itinerary || itinerary.fare != params[:fare]
      # binding.pry
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
    itinerary
  end

end
