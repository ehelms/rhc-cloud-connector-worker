# frozen_string_literal: true

require_relative 'version'
require_relative '../yggdrasil_services_pb'
require_relative 'foreman'

module RhcCloudConnectorWorker
  class MessageDispatchingServer < Yggdrasil::Worker::Service
    def send(data, _request)
      GRPC.logger.debug("Received message: #{data}")

      Foreman.new.pass(data.metadata)

      # Respond with a receipt
      Yggdrasil::Receipt.new
    end
  end
end
