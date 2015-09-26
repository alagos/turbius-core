module Turbius
  module RequestsQueue
    class << self

      attr_accessor :queue_size

      def queue_size
        @queue_size ||= ENV['queue_size'].to_i
      end

      def enqueue(request)
        hydra.queue request
        run if hydra.queued_requests.size >= queue_size
      end

      def run
        hydra.run
      end

      private

      attr_accessor :hydra

      def hydra
        @hydra ||= Typhoeus::Hydra.new
      end

    end

  end
end