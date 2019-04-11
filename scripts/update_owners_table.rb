#!/usr/bin/env ruby
# frozen_string_literal: true
require 'pry'
require_relative 'iapd.rb'

def create_column(name, type)
  unless IAPD.execute("PRAGMA table_info(owners)").bsearch { |c| c['name'] == name }
    IAPD.execute "ALTER TABLE owners ADD COLUMN #{name} #{type}"
  end
end

create_column "owner_key", "TEXT"
create_column "advisor_crd_number", "INTEGER"

update_sql = 'UPDATE owners SET owner_key = ?, advisor_crd_number = ?  WHERE rowid = ?'
filings_id_sql = "SELECT group_concat(filing_id) as filing_ids, crd_number from advisors group by crd_number"

crd_number_lookup = IAPD.execute(filings_id_sql).each_with_object({}) do |row, h|
  row['filing_ids'].split(',').each do |filing_id|
    h.store filing_id, row['crd_number']
  end
end



IAPD.with_database do |db|
  db.execute("SELECT *, rowid FROM owners").each do |row|
    db.execute update_sql, [IAPD.owner_key(row), row['rowid']]
  end
end
