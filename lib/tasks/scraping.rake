Dir[Rails.root.join(*%w{lib turbius *.rb})].each { |file| require file }
require 'pry'
require 'geokit'

namespace :scraping do

  include Turbius::Requests

  desc 'Get a list of actual cities'
  task :cities => :environment do
    scraping_setup
    get_cities(Time.now) do |city|
      city = City.find_or_initialize_by(name: city.children[0].text)
      location = Geokit::Geocoders::GoogleGeocoder.geocode "#{city.name}, Chile"
      city.city = location.city
      city.full_address = location.full_address
      city.province = location.province
      city.lonlat = "POINT(#{location.lng} #{location.lat})"
      if city.save
        logger.info "#{city.name} was created"
      else
        logger.warn "#{city.name} was not saved: #{city.errors.full_messages}"
      end

    end
  end

  desc 'Get all the available trips'
  task :trips => :environment do
    date_from = 1.day.from_now.to_i
    date_to   = 7.days.from_now.to_i
    logger.info "SESSION_ID: #{scraping_setup}"
    logger.info "cities: #{Settings.cities.inspect}"

    Settings.cities.permutation(2).each do |origin, destination|
      unless Trip.find_by(origin: origin, destination: destination)
        logger.info "origin: #{origin}, destination: #{destination}"
        trip = Trip.new(origin: origin, destination: destination, available: false)
        response = nil
        (date_from..date_to).step(3.days) do |date|
          logger.info "\tat #{Time.at(date).strftime('%d/%m/%Y')}"
          response = get_best_prices(origin, destination, Time.at(date)) do |best_prices_dom|
            trip.set_available if best_prices_dom && best_prices_dom.children.any?
          end
          break if trip.available?
        end # (date_from..date_to).step(3.days)
        trip.save if response.success?
        logger.info "\t== #{ 'Not ' unless trip.available? }Available =="
      end # if trip.available?
    end # cities.combination(2).each do |origin, destination|
  end

  desc 'Do a deep checking of unavailable trips'
  task :check_unavailable_trips => :environment do
    #TODO
  end

  desc 'Do a full scraping, getting all the itineraries given the available trips'
  task :full => :environment do
    date_from = 1.day.from_now.to_i
    date_to   = 1.month.from_now.to_i
    date_step = 1.day
    Trip.availables.each do |trip|
      logger.info "#{trip.available?}-> origin: #{origin}, destination: #{destination}"
      logger.info "SESSION_ID: #{scraping_setup}"
      (date_from..date_to).step(date_step) do |date|
        logger.info "Trip #{origin} - #{destination} at #{Time.at(date).strftime('%d/%m/%Y')}"
        get_itineraries(origin, destination, Time.at(date)) do |itinerary_dom|
          get_seats(itinerary_dom, trip)
        end
      end # (date_from..date_to).step(date_step)
      if trip.itineraries.blank?
        logger.info "No itineraries for #{origin} - #{destination} trip"
        trip.set_unavailable
      end
    end # Trip.availables.each do |trip|

    # Execute any lasting request in queue
    Turbius::RequestsQueue.run
  end

end
