#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'sqlite3'

owners = Hash.new { [] }

CRD = /\A[[:digit:]]+\Z/
TAX = /\A[[:digit:]]{2}-{1}[[:digit:]]+\Z/

# The owners dataset doesn't have a single unquie identifier for all people/companies.
# Some owners have a CRD or TAX number which can be used.
# Othwerwise, the "name" is the used as the key
def owner_key(row)
  owner_id = row['owner_id']
  return owner_id if CRD.match?(owner_id) || TAX.match?(owner_id)

  row['name']
end

SQLite3::Database.new("iapd.db", results_as_hash: true) do |db|
  db.execute("SELECT * FROM owners") do |row|
    key = owner_key(row)
    owners[key] = owners[key] << row
  end
end

File.write 'owners.json', JSON.pretty_generate(owners)
