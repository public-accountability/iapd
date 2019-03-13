#!/usr/bin/env ruby
# frozen_string_literal: true
require 'pry'
require 'csv'
require 'zip'


ZIP_FILE = './form-adv-complete-ria.zip'
ADVISORS_FILE = './advisors.csv'
OWNERS_FILE = './owners.csv'

BASE_A_FILTER = proc { |x| /IA_ADV_Base_A/.match? x.name }
SCHEDULE_A_B_FILTER = proc { |x| /IA_Schedule_A_B/.match? x.name }

# Used to find quotes insides of quotes that need to be doubled quoted but are not
# examples:
#    "foo "bar""
#    ""foo" bar"
#    ""foobar""
#    "foo "bar" baz"
QUOTE_ALONE = /(?<=[^",]{1})(")(?=[^",]{1})/
TWO_QUOTES_AT_START = /((?<=\A)|(?<=[[:alnum:]]{1},))("{2})(?=[^",]{1})/
TWO_QUOTES_AT_END = /(?<=[^",]{1})("{2})(?=\Z|,[^ ]{1})/
COLUMN_IN_QUOTES = /(,"")([^"]+)("",)/

# DOUBLE_QUOTE_START = /(?<=[^"]{2}),""/
# DOUBLE_QUOTE_END = /(?<=[^,]{1})"",/

TWO_QUOTES = '""'
THREE_QUOTES = '"""'

def quote(str)
  str
    .gsub(COLUMN_IN_QUOTES, ',"""\2""",')
    .gsub(QUOTE_ALONE, TWO_QUOTES)
    .gsub(TWO_QUOTES_AT_START, THREE_QUOTES)
    .gsub(TWO_QUOTES_AT_END, THREE_QUOTES)
end

# There are a bewildering number of headers, all with cryptic names.
# These maps are used to select which fields we care about, and give them
# human-understandable titles
ADVISORS_HEADER_MAP = {
  '1A' => 'name',
  '1B' => 'dba_name',
  '1C-Legal' => 'umbrella',
  # Annoyingly, some years use a different code for this field
  '1E1' => 'crd_number',
  '1E' => 'crd_number',
  '1D' => 'sec_file_number',
  '5F2C' => 'assets_under_management',
  '5F2F' => 'total_number_of_accounts',
  'FilingId' => 'filing_id',
  'DateSubmitted' => 'date_submitted'
}

OWNERS_HEADER_MAP = {
  'FilingID' => 'filing_id',
  'SchA-3' => 'scha_3',
  'Schedule' => 'schedule',
  'Full Legal Name' => 'name',
  "DE/FE/I" => 'owner_type',
  'Entity in Which' => 'entity_in_which',
  "Title or Status" => 'title_or_status',
  'Status Acquired' => 'acquired',
  'Ownership Code' => 'ownership_code',
  'Control Person' => 'control_person',
  'PR' => 'public_reporting',
  'OwnerID' => 'owner_id'
}

# Oh encoding issues; they never seem to away.
# I *think* the CSVs inside the zipfile are encoding with ISO_8859_1, but
# in any case, this bit of ruby magic seems to do the trick.
def normalize(line)
  l = line
          .force_encoding(Encoding::ISO_8859_1)
          .encode('UTF-8', :invalid => :replace, :undef => :replace, :replace => '')
          .strip
  # puts quote(l)
  quote(l)
end

def parse_file(zip_file, out_file:, headers_map:, filter:)
  CSV.open(out_file, 'wb',  col_sep: '|') do |csv|
    csv << (headers_map.values.uniq + ['filename'])

    zip_file.entries.filter(&filter).each do |entry|
      filename = entry.name.split('/').last
      puts "Processing: #{filename}"
      stream = entry.get_input_stream
      headers = CSV.parse_line(stream.readline.strip)

      stream.each_line do |line|
        csv << CSV.parse_line(normalize(line), headers: headers)
                 .to_h
                 .slice(*headers_map.keys)
                 .merge('filename' => filename)
                 .values
      end
    end
  end
end

def advisors(zip_file)
  parse_file zip_file,
             out_file: ADVISORS_FILE,
             headers_map: ADVISORS_HEADER_MAP,
             filter: BASE_A_FILTER
end

def owners(zip_file)
  parse_file zip_file,
             out_file: OWNERS_FILE,
             headers_map: OWNERS_HEADER_MAP,
             filter: SCHEDULE_A_B_FILTER
end

Zip::File.open(ZIP_FILE) do |zip_file|
  advisors zip_file
  owners zip_file
end




