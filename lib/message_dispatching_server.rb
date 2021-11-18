# frozen_string_literal: true

require_relative 'rh_cloud_rhc_worker/version'
require_relative 'yggdrasil_services_pb'

module RhCloudRhcWorker
  class MessageDispatchingServer < Yggdrasil::Worker::Service
    def send(data, _request)
      GRPC.logger.debug("Received message: #{data}")

      # Respond with a receipt
      Yggdrasil::Receipt.new
    end
  end
end
