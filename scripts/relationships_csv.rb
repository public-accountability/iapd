#!/usr/bin/env ruby
# frozen_string_literal: true

# Generates relationships.csv
# This script loads large JSON into memory
# Expect it to use about 2GB

require 'csv'
require 'set'
require 'json'

OWNERS = JSON.parse File.read('owners.json')
ADVISORS = JSON.parse File.read('advisors.json')

csv = CSV.open("relationships.csv", "wb")

csv << %w[crd_number advisor_name owner_key owner_name]

# lookup to go from filing --> owner_key
filings = Hash.new { Set.new }

OWNERS.each do |owner_key, data|
  data.map { |f| f['filing_id'] }.each do |filing_id|
    filings[filing_id] = filings[filing_id].add(owner_key)
  end
end

ADVISORS.each do |crd_number, data|
  filing_ids = data.map { |x| x['filing_id'] }
  owner_keys = filing_ids.reduce(Set.new) { |memo, id| memo + filings[id] }

  owner_keys.each do |owner_key|
    row = [
      acrd_number,
      data.first['name'],
      owner_key,
      OWNERS[owner_key].first['name']
    ]
    csv << row
  end
end

csv.close
