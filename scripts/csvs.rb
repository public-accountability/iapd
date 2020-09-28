#!/usr/bin/env ruby
# frozen_string_literal: true

require 'csv'
require 'pathname'

DATA_DIR = Pathname.new(Dir.pwd).join('./data').freeze
YEARS = (2016..2020).map(&:to_s).freeze
QUARTERS = (1..4).map { |i| "Q#{i}" }.freeze

ADVISORS_FILE = './advisors.csv'
OWNERS_FILE = './owners.csv'

BASE_A_FILTER = /IA_ADV_Base_A/             # for advisors
SCHEDULE_A_B_FILTER = /IA_Schedule_A_B/     # for owners

ADVISORS_HEADER_MAP = {
  '1A' => 'name',
  # Annoyingly, some years use a different code for these fields
  '1B' => 'dba_name',
  '1B1' => 'dba_name',
  '1E' => 'crd_number',
  '1E1' => 'crd_number',

  '1D' => 'sec_file_number',
  '5F2C' => 'assets_under_management',
  '5F2F' => 'total_number_of_accounts',
  'FILINGID' => 'filing_id',
  'DATESUBMITTED' => 'date_submitted'
}.freeze

OWNERS_HEADER_MAP = {
  'FILINGID' => 'filing_id',
  'SCHA-3' => 'scha_3',
  'SCHEDULE' => 'schedule',
  'FULL LEGAL NAME' => 'name',
  "DE/FE/I" => 'owner_type',
  'ENTITY IN WHICH' => 'entity_in_which',
  "TITLE OR STATUS" => 'title_or_status',
  'STATUS ACQUIRED' => 'acquired',
  'OWNERSHIP CODE' => 'ownership_code',
  'CONTROL PERSON' => 'control_person',
  'PR' => 'public_reporting',
  'OWNERID' => 'owner_id'
}.freeze

def loop_files(filter = nil, &block)
  YEARS.each do |year|
    QUARTERS.each do |quarter|
      path = DATA_DIR.join(year).join(quarter)
      next unless path.exist?

      Dir.each_child(path) do |file|
        if filter.nil? || filter.match?(file)
          block.call(year, quarter, path.join(file))
        end
      end
    end
  end
end

def advisors
  CSV.open(ADVISORS_FILE, 'w', col_sep: '|') do |csv|
    headers = ADVISORS_HEADER_MAP.values.uniq + %w[filename iapd_year iapd_quarter]
    csv << headers

    loop_files(BASE_A_FILTER) do |year, quarter, file|
      puts "Parsing #{file}"

      CSV.open(file, headers: true, liberal_parsing: true).each do |row|
        line = row
               .to_h
               .transform_keys!(&:upcase)                      # handle uneven captialization
               .slice(*ADVISORS_HEADER_MAP.keys)               # extract subset of keys
               .transform_keys! { |k| ADVISORS_HEADER_MAP[k] } # rename to friendlier column names
               .merge!('filename' => file.basename.to_s,       # add file metadata
                       'iapd_year' => year,
                       'iapd_quarter' => quarter)
               .values_at(*headers)                            # convert to array

        csv << line
      end
    end
  end
end

def owners
  CSV.open(OWNERS_FILE, 'w', col_sep: '|') do |csv|
    headers = OWNERS_HEADER_MAP.values.uniq + %w[filename iapd_year iapd_quarter]
    csv << headers

    loop_files(SCHEDULE_A_B_FILTER) do |year, quarter, file|
      puts "Parsing #{file}"

      CSV.open(file, headers: true, liberal_parsing: true).each do |row|
        line = row
               .to_h
               .transform_keys!(&:upcase)                      # handle uneven captialization
               .slice(*OWNERS_HEADER_MAP.keys)                 # extract subset of keys
               .transform_keys! { |k| OWNERS_HEADER_MAP[k] }   # rename to friendlier column names
               .merge!('filename' => file.basename.to_s,       # add file metadata
                       'iapd_year' => year,
                       'iapd_quarter' => quarter)
               .values_at(*headers)                            # convert to array

        csv << line
      end
    end
  end
end

# run:
advisors
owners
