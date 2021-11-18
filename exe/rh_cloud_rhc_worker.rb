#!/usr/bin/env ruby

require 'bundler/setup'
require 'rh_cloud_rhc_worker'

pid = Process.pid
rhc_socket = ENV['YGG_SOCKET_ADDR']

puts "Pid and YGG_SOCKET_ADDR should be set. pid: #{pid}, YGG_SOCKET_ADDR: #{rhc_socket}" unless pid || rhc_socket

service = RhCloudRhcWorker::Service.new(initial_socket: rhc_socket, pid: pid)
service.start_server
