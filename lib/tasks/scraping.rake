Dir[Rails.root.join(*%w{lib turbius *.rb})].each { |file| require file }
require 'pry'

namespace :scraping do

  include Turbius::Requests

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
    Settings.cities.permutation(2).each do |origin, destination|
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
    #TODO
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
        logger.info "SESSION_ID: #{scraping_setup}"
        (date_from..date_to).step(date_step) do |date|
          logger.info "Trip #{origin} - #{destination} at #{Time.at(date).strftime('%d/%m/%Y')}"
          get_itineraries(origin, destination, Time.at(date)) do |itinerary_dom|
            if itinerary_dom.any?
              get_seats(itinerary_dom, trip)
              trip.set_available
            elsif trip.itineraries.blank?
              logger.info "No itineraries for #{origin} - #{destination} trip"
              trip.set_unavailable
            end
          end
        end # (date_from..date_to).step(3.days)
      end # if trip.available?
    end # cities.combination(2).each do |origin, destination|
    Turbius::RequestsQueue.run
  end

end
