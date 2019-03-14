#!/usr/bin/env ruby
# frozen_string_literal: true

# This generates an json object from the advisors dataset.
# The key is the crd_number (the unique identifier for an advisor)
# and the value is an array of rows of for that adivsors.x

require 'date'
require 'json'
require 'sqlite3'

advisors = Hash.new { [] }

SQLite3::Database.new("iapd.db", results_as_hash: true) do |db|
  db.execute("SELECT * FROM advisors") do |row|
    crd_number = row['crd_number']
    advisors[crd_number] = advisors[crd_number] << row
  end
end

def to_dt(str)
  DateTime.strptime str, '%m/%d/%Y %I:%M:%S %p'
end

# Sort the rows by date_submitted (most recent first)
advisors.transform_values! do |arr|
  arr.sort! do |a, b|
    to_dt(b['date_submitted']) <=> to_dt(a['date_submitted'])
  end
end

File.write 'advisors.json', JSON.pretty_generate(advisors)
