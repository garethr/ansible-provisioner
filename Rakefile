require 'rake'
require 'rspec/core/rake_task'
require 'digitalocean'

Digitalocean.client_id = ENV['DO_CLIENT_ID']
Digitalocean.api_key = ENV['DO_API_KEY']
result = Digitalocean::Droplet.all
hosts = []
result.droplets.each do |droplet|
  hosts << {
    :address => droplet.ip_address,
    :name    => droplet.name,
  }
end

desc "Run serverspec on all hosts"
task :spec => 'serverspec:all'

task :default => [:spec]

class ServerspecTask < RSpec::Core::RakeTask
  attr_accessor :target
  def spec_command
    cmd = super
    "env TARGET_HOST=#{target} #{cmd}"
  end
end

namespace :serverspec do
  task :all => hosts.map {|h| 'serverspec:' + h[:name] }
  hosts.each do |host|
    desc "Run serverspec on #{host[:name]}"
    ServerspecTask.new(host[:name].to_sym) do |t|
      t.target = host[:address]
      t.pattern = 'spec/*_spec.rb'
    end
  end
end

