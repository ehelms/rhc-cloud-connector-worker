# frozen_string_literal: true

require 'config'
require 'json'
require 'rest-client'

module RhcCloudConnectorWorker
  class Foreman
    def initialize
      @address = Settings.foreman.address
      @require_ssl = Settings.foreman.require_ssl
      @ssl_ca_file = Settings.foreman.ssl_ca_file
      @token = Settings.foreman.token
      @user = Settings.foreman.user
    end

    def pass(metadata)
      connection['rh_cloud/cloud_request'].post(metadata.to_json, content_type: :json)
    end

    private

    def connection
      @connection ||= RestClient::Resource.new(
        "#{@address}/api/v2",
        user: @user,
        password: @token,
        verify_ssl: verify_ssl,
        ssl_ca_file: ssl_ca_file
      )
    end

    def verify_ssl
      @require_ssl ? OpenSSL::SSL::VERIFY_PEER : OpenSSL::SSL::VERIFY_NONE
    end

    def ssl_ca_file
      @ssl_ca_file unless @ssl_ca_file&.empty?
    end
  end
end
