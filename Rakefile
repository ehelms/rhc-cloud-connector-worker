# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

require 'rubocop/rake_task'

RuboCop::RakeTask.new

task default: %i[test rubocop]

namespace :dev do
  desc 'Download and build yggdrasil proto'
  task :build do
    `wget -O protocol/yggdrasil.proto https://github.com/RedHatInsights/yggdrasil/raw/main/protocol/yggdrasil.proto`
    puts 'Building ruby stubs...'
    `bundle exec grpc_tools_ruby_protoc --proto_path=protocol --ruby_out=lib --grpc_out=lib protocol/yggdrasil.proto`
    puts 'Done'
  end
end
