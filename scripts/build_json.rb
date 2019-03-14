#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'iapd.rb'

advisors = Hash.new { [] }

IAPD.with_database do |db|
  db.execute("SELECT * FROM advisors") do |row|
    crd_number = row['crd_number']
    advisors[crd_number] = advisors[crd_number] << row
  end
end

# Sort the rows by date_submitted (most recent first)
advisors.transform_values! do |arr|
  arr.sort! do |a, b|
    IAPD.to_dt(b['date_submitted']) <=> IAPD.to_dt(a['date_submitted'])
  end
end

File.write 'advisors.json', JSON.pretty_generate(advisors)

owners = Hash.new { [] }

IAPD.with_database do |db|
  db.execute("SELECT * FROM owners") do |row|
    key = IAPD.owner_key(row)
    owners[key] = owners[key] << row
  end
end

File.write 'owners.json', JSON.pretty_generate(owners)
