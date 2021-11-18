# frozen_string_literal: true

require_relative 'rh_cloud_rhc_worker/version'
require_relative 'yggdrasil_services_pb'
require_relative 'message_dispatching_server'

module RhCloudRhcWorker
  class Error < StandardError; end

  class Service
    def initialize(initial_socket:, pid:)
      @initial_socket = convert_socket(initial_socket)
      @pid = pid
    end

    def start_server
      session_address = perform_hadshake

      return unless session_address

      session_address = convert_socket(session_address) if session_address

      grpc_server = GRPC::RpcServer.new
      grpc_server.add_http2_port(session_address, :this_port_is_insecure)
      grpc_server.handle(MessageDispatchingServer)
      # Runs the server with SIGHUP, SIGINT and SIGQUIT signal handlers to
      #   gracefully shutdown.
      # User could also choose to run server via call to run_till_terminated
      grpc_server.run_till_terminated_or_interrupted([1, 'int', 'SIGQUIT'])
    end

    private

    def perform_hadshake
      ygg_stub = Yggdrasil::Dispatcher::Stub.new(@initial_socket, :this_channel_is_insecure)
      response = ygg_stub.register(
        ::Yggdrasil::RegistrationRequest.new(
          handler: 'foreman_rh_cloud',
          pid: @pid,
          detached_content: false
        )
      )

      return response.address if response.registered
    end

    def convert_socket(original)
      original = "unix:#{original}" if original.start_with?('@')
      original.sub('unix:@', 'unix-abstract:')
    end
  end
end
