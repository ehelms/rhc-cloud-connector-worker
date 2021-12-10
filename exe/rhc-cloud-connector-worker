#!/usr/bin/env ruby

require 'bundler/setup'
require 'rhc_cloud_connector_worker'

pid = Process.pid
rhc_socket = ENV['YGG_SOCKET_ADDR']

puts "Pid and YGG_SOCKET_ADDR should be set. pid: #{pid}, YGG_SOCKET_ADDR: #{rhc_socket}" unless pid || rhc_socket

service = RhcCloudConnectorWorker::Service.new(initial_socket: rhc_socket, pid: pid)
service.start_server
