#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'iapd.rb'

unless IAPD.execute("PRAGMA table_info(owners)").bsearch { |c| c['name'] == 'owner_key' }
  IAPD.execute "ALTER TABLE owners ADD COLUMN owner_key TEXT"
end

update_sql = 'UPDATE owners SET owner_key = ? WHERE rowid = ?'

IAPD.with_database do |db|
  db.execute("SELECT *, rowid FROM owners").each do |row|
    db.execute update_sql, [IAPD.owner_key(row), row['rowid']]
  end
end
