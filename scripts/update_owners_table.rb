#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'iapd.rb'

def create_column(name, type)
  unless IAPD.execute("PRAGMA table_info(owners)").bsearch { |c| c['name'] == name }
    IAPD.execute "ALTER TABLE owners ADD COLUMN #{name} #{type}"
  end
end

create_column "owner_key", "TEXT"
create_column "advisor_crd_number", "INTEGER"

filings_id_sql = "SELECT group_concat(filing_id) as filing_ids, crd_number from advisors group by crd_number"
update_sql = "UPDATE owners SET owner_key = ?, advisor_crd_number = ? WHERE rowid = ?"

# Map between filing id and crd_number
crd_number_lookup = IAPD.execute(filings_id_sql).each_with_object({}) do |row, h|
  row['filing_ids'].split(',').each do |filing_id|
    h.store filing_id, row['crd_number']
  end
end

IAPD.with_database do |db|
  total_count = db.execute("SELECT COUNT(*) as count from owners")[0]['count'].to_f
  display_when_eql_to_these_numbers = (0..total_count).filter { |i| (i % 500).zero? }
  current_count = 0

  db.execute("SELECT *, rowid FROM owners").each do |row|
    next if row['filing_id']&.to_i&.zero?

    values = [IAPD.owner_key(row),
              crd_number_lookup.fetch(row['filing_id'].to_s, 'NULL'),
              row['rowid']]

    db.execute(update_sql, values)

    current_count += 1
    if display_when_eql_to_these_numbers.include?(current_count)
      current_pct = ((current_count / total_count) * 100).round(2).to_s
      print "#{current_pct}%\r"
      $stdout.flush
    end
  end
end
