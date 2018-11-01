# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'bundler/setup'
require 'rspec/core/rake_task'
require 'iapd'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

desc 'save json over all companies with more than $10 billion in assets'
task :companies_over_10_billion do
  iapd = Iapd::Database.new
  filter = Iapd::Advisors::ASSETS_FILTER.curry[10_000_000_000]

  File.open('companies_over_10_billion.json', 'w') do |f|
    f.write JSON.pretty_generate(iapd.json(filter))
  end
end
