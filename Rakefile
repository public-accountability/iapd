require 'sqlite3'
require 'csv'
require 'pry'

COMPLETE_URL = 'https://www.sec.gov/foia/docs/adv/form-adv-complete-ria.zip'

def iapd_execute(sql)
  SQLite3::Database
    .new('iapd.db')
    .prepare(sql)
end

desc 'downloads form-adv-complete-ria.zip'
file 'form-adv-complete-ria.zip' do
  sh "curl -L -O #{COMPLETE_URL}"
end

desc 'unzips form-adv-complete-ria.zip'
directory 'form-adv-complete-ria' do
  mkdir_p 'form-adv-complete-ria'
  sh 'unzip -j -d ./form-adv-complete-ria form-adv-complete-ria.zip'
  sh 'find form-adv-complete-ria -type f -print0 | xargs -P 2 -0 -I FILE iso8859_to_utf8! FILE'
end

desc 'creates the iapd sqlite database'
file 'iapd.db' do
  ruby 'build_db.rb'
end


desc 'creates csv for companies with over 1 billion in assets'
task :top_companies do
  sql = <<-SQL
    SELECT group_concat(FilingID, '|') as filing_ids, 
           MAX("5F2C") as assets_under_management,
           "1A", "1D", "1E1"
    FROM IA_ADV_Base_A_20180401_20180630
    WHERE "5F2C" >= 1000000000
    GROUP BY "1E1", "IA", "1E1", "1D"
    ORDER BY assets_under_management desc
  SQL
  

  File.open('top_companies.csv', 'w') do |f|
    cursor = iapd_execute(sql)
    f.write cursor.columns.to_csv
    cursor.each { |row| f.write row.to_csv }
  end
end
