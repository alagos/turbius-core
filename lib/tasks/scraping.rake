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
    date_from = 1.day.from_now.to_i
    date_to   = 1.week.from_now.to_i
    logger.info "SESSION_ID: #{scraping_setup}"
    Settings.cities.permutation(2).each do |origin, destination|
      logger.info "origin: #{origin}, destination: #{destination}"
      unless Trip.find_by(origin: origin, destination: destination)
        trip = Trip.new(origin: origin, destination: destination, available: false)
        (date_from..date_to).step(2.days) do |date|
          logger.info "\tat #{Time.at(date).strftime('%d/%m/%Y')}"
          get_best_prices(origin, destination, Time.at(date)) do |best_prices_dom|
            trip.set_available if best_prices_dom && best_prices_dom.children.any?
          end
          break if trip.available?
        end # (date_from..date_to).step(3.days)
        trip.save
        logger.info "\t== #{ 'Not ' unless trip.available? }Available =="
      end # if trip.available?
    end # cities.combination(2).each do |origin, destination|
  end

  desc 'Do a deep checking of unavailable trips'
  task :check_unavailable_trips => :environment do
    #TODO
  end

  desc 'Do a full scraping, getting all the trips and itineraries info'
  task :full => :environment do
    cities = Settings.cities
    date_from = 1.day.from_now.to_i
    date_to   = 1.week.from_now.to_i
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
            get_seats(itinerary_dom, trip)
          end
        end # (date_from..date_to).step(3.days)
        if trip.itineraries.blank?
          logger.info "No itineraries for #{origin} - #{destination} trip"
          trip.set_unavailable
        end
      end # if trip.available?
    end # cities.combination(2).each do |origin, destination|
    Turbius::RequestsQueue.run
  end

end
