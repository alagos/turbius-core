require_relative "../turbius/scrape_utils.rb"
require_relative "../turbius/requests_queue.rb"
require 'pry'

namespace :scraping do

  include Turbius::ScrapeUtils

  desc 'Get a list of actual cities'
  task :cities => :environment do
    scraping_setup
    get_cities(Time.now) do |city|
      logger.info "#{city.children[0].text}"
    end
  end

  desc 'Get all the available trips'
  task :trips => :environment do
    date = 1.day.from_now
    scraping_setup
    # Settings.cities.combination(2).each do |origin, destination|
    %w{Algarrobo Santiago Temuco}.permutation(2).each do |origin, destination|
      trip = Trip.find_or_initialize_by(origin: origin, destination: destination)
      # logger.info "origin: #{origin}, destination: #{destination}"
      unless trip.persisted?
        logger.info "Scraping trip #{origin} - #{destination} at #{date}"
        get_best_prices(origin, destination, Time.at(date)) do |best_prices_dom|
          logger.info "best_prices_dom: #{best_prices_dom}"
          if best_prices_dom.any?
            logger.info "Trip #{origin} - #{destination} at #{date}"
            best_prices_dom.each do |best_price_dom|
              logger.info "\t#{best_price_dom.content.gsub(/\n/, ' ')}"
            end
          elsif trip.itineraries.blank?
            logger.info "No itineraries for #{origin} - #{destination} trip"
            trip.set_unavailable
          end
          trip.save
        end
      end
    end
    Turbius::RequestsQueue.run

  end

  desc 'Do a deep checking of unavailable trips'
  task :check_unavailable_trips => :environment do
  end

  desc 'Do a full scraping, getting all the trips and itineraries info'
  task :full => :environment do
    cities = Settings.cities
    date_from = 1.day.from_now.to_i
    date_to   = 1.months.from_now.to_i
    date_step = 1.day
    logger.info "\n\tChecking #{cities.size} cities\n\n"
    cities.permutation(2).each do |origin, destination|
      trip = Trip.find_or_create_by(origin: origin, destination: destination)
      logger.info "#{trip.available?}-> origin: #{origin}, destination: #{destination}"
      if trip.available?
        scraping_setup
        (date_from..date_to).step(date_step) do |date|
          logger.info "Trip #{origin} - #{destination} at #{Time.at(date).strftime('%d/%m/%Y')}"
          get_itineraries(origin, destination, Time.at(date)) do |itinerary_dom|
            if itinerary_dom.any?
              get_seats(itinerary_dom, trip)
            elsif trip.itineraries.blank?
              logger.info "No itineraries for #{origin} - #{destination} trip"
              trip.set_unavailable
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

    # If is a new itinerary or their fare has changed, it will be saved
    if !itinerary || itinerary.fare != params[:fare]
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
    else
      logger.info "\tNo changes for #{itinerary.departure_time} with #{itinerary.price}"
    end
    itinerary
  end

  def save_html(name, html, date = Time.now)
    format_name  = "#{name.parameterize.underscore}_#{date.strftime('%d_%m_%Y')}"
    filename = "tmp/#{format_name}_#{Time.now.strftime("%Y%m%d%H%M%S%L")}.html"
    Dir.mkdir('tmp') unless File.exists?('tmp')
    output = File.expand_path(File.join(filename))
    File.write(output, html.encode('utf-8', undef: :replace, replace: ''))
  end

end
