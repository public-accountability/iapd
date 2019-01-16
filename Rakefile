# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'bundler/setup'
require 'rspec/core/rake_task'
require 'iapd'

RSpec::Core::RakeTask.new(:spec)

ADV_ZIP_FILE = './form-adv-complete-ria.zip'

task :default => :spec

desc 'save json over all companies with more than $10 billion in assets'
task :companies_over_10_billion do
  iapd = Iapd::Database.new
  filter = Iapd::Advisors::ASSETS_FILTER.curry[10_000_000_000]

  File.open('companies_over_10_billion.json', 'w') do |f|
    f.write JSON.pretty_generate(iapd.json(filter))
  end
end

desc 'downloads form adv complete zip file'
task download: ['form-adv-complete-ria.zip']

file 'form-adv-complete-ria.zip' do |t|
  sh "curl -# -L https://www.sec.gov/foia/docs/adv/form-adv-complete-ria.zip > #{t.name}"
end

desc 'creates the iapd database'
file 'iapd.db' => %w[data] do |t|
  sh './scripts/build-db'
end

directory 'data'
