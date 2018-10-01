#!/usr/bin/env ruby

# PATHS
adv_complete_dir = './form-adv-complete-ria'
CSVSQL = File.expand_path('~/.local/bin/csvsql')
DB = File.expand_path('./iapd.db')

# FILTERS
is_schedule_a_b = proc { |x| x.include? "IA_Schedule_A_B" } 
is_base_a = proc { |x| x.include? 'IA_ADV_Base_A_' }
is_2018 = proc { |x| /_2018\d{4}_/.match? x }

# CSVS
csvs = Dir["#{adv_complete_dir}/*.csv"]

# csvsql command to insert file/table into database
def insert_cmd(csv_file)
  "#{CSVSQL} --db sqlite:///#{DB} --insert #{csv_file}".tap do |cmd|
    puts "Executing: #{cmd}"
  end
end

# Base A
csvs.select(&is_base_a).select(&is_2018).each do |csv_file|
  system insert_cmd(csv_file)
end

# Schedule A B
csvs.select(&is_schedule_a_b).select(&is_2018).each do |csv_file|
  system insert_cmd(csv_file)
end


