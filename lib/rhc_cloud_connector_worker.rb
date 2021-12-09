# frozen_string_literal: true

# Initialization code

require 'config'

require_relative 'rhc_cloud_connector_worker/version'
require_relative 'rhc_cloud_connector_worker/service'

module RhcCloudConnectorWorker
  class Error < StandardError; end

  class Initializer
    def start
      Config.setup do |config|
        config.const_name = 'Settings'
        config.use_env = true
        config.env_prefix = 'CC_WORKER'
        config.env_separator = '__'
        config.env_converter = :downcase
        config.env_parse_values = true
      end

      Config.load_and_set_settings(
        File.join(__dir__, '..', 'config', 'settings.yml'),
        '/etc/rhc-cloud-connector-worker/settings.yml',
        File.join(__dir__, '..', 'config', 'settings.local.yml')
      )
    end
  end

  def self.initializer
    @initializer ||= Initializer.new
  end

  def self.init
    initializer.start
  end
end

RhcCloudConnectorWorker.init
