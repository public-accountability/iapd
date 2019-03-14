# frozen_string_literal: true

# task :default => :csv

desc 'downloads form adv complete zip file'
task download: ['form-adv-complete-ria.zip']

file 'form-adv-complete-ria.zip' do |t|
  sh "curl -# -L https://www.sec.gov/foia/docs/adv/form-adv-complete-ria.zip > #{t.name}"
end

task :csvs do
  ruby './scripts/build_csvs.rb'
end

desc 'creates the iapd database'
task :database => ['iapd.db']

file 'iapd.db' do
  sh "sqlite3 iapd.db < ./scripts/iapd.sql"
end

# directory 'data'

# require 'bundler/gem_tasks'
# require 'bundler/setup'
# require 'rspec/core/rake_task'
# require 'iapd'

# RSpec::Core::RakeTask.new(:spec)

# ADV_ZIP_FILE = './form-adv-complete-ria.zip'

# desc 'save json over all companies with more than $10 billion in assets'
# task :companies_over_10_billion do
#   iapd = Iapd::Database.new
#   filter = Iapd::Advisors::ASSETS_FILTER.curry[10_000_000_000]

#   File.open('companies_over_10_billion.json', 'w') do |f|
#     f.write JSON.pretty_generate(iapd.json(filter))
#   end
# end

# desc 'top 200 advisors'
# task :top_200 do
#   top_200 = Iapd::Database.new
#               .json(Iapd::Advisors::ASSETS_FILTER.curry[1_000_000_000])
#               .sort_by { |x| x['assets_under_management'] }
#               .reverse
#               .take(200)
    
#   File.open('top_200.json', 'w') do |f|
#     f.write JSON.pretty_generate(top_200)
#   end
# end

# desc 'creates json of all iapd advisors'
# file 'advisors.json' do |t|
#   Iapd::Database.new.save_json_to_file(t.name)
# end

