# frozen_string_literal: true

task :default => %i[download extract csvs database]

desc 'downloads form adv complete zip file'
task download: ['form-adv-complete-ria.zip']

file 'form-adv-complete-ria.zip' do |t|
  sh "curl -# -L https://www.sec.gov/foia/docs/adv/form-adv-complete-ria.zip > #{t.name}"
end

task :extract do
  ruby './scripts/extract.rb'
end

task :csvs do
  ruby './scripts/csvs.rb'
end

desc 'creates the iapd database'
task :database => ['iapd.db']

file 'iapd.db' do
  sh "sqlite3 iapd.db < ./scripts/iapd.sql"
end

# desc 'adds column owner_key and advisor_crd_number to owners table'
# task :update_owners_table do
#   ruby './scripts/update_owners_table.rb'
# end

# desc 'creates advisors.json and owners.json'
# task :json do
#   ruby './scripts/build_json.rb'
# end

# desc 'creates relationships.csv'
# task :relationships do
#   ruby './scripts/relationships_csv.rb'
# end

desc 'Remove all csv and json files'
task :clean do
  rm %w[csv json db].map { |x| Dir.glob("*.#{x}") }.reduce(:+)
end
