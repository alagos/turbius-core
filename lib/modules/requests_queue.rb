module Turbius
  module RequestsQueue
    class << self

      attr_accessor :hydra

      QUEUE_SIZE = 2

      def hydra
        @hydra ||= Typhoeus::Hydra.new
      end

      def enqueue(request)
        hydra.queue request
        run if hydra.queued_requests.size >= QUEUE_SIZE
      end

      def run
        hydra.run
      end
    end

  end
end