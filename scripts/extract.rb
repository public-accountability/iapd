#!/usr/bin/env ruby
# frozen_string_literal: true

require 'zip'
require 'fileutils'

DATA_DIR = Pathname.new('./data').freeze

FileUtils.mkdir_p DATA_DIR

Metadata = Struct.new(:basename, :year, :period, :quarter, :schedule)

# The IAPD zipfile contains hundreds of files.
# This takes the filename and gathers useful information about it.
def filename_metadata(filename)
  basename = Pathname.new(filename).basename.to_s

  year = basename.scan(/(?<=_)20[[:digit:]]{2}/).first || raise("Invalid filename: #{filename}")

  unless (period = basename.scan(/(?<=_)20[[:digit:]]{6}_20[[:digit:]]{6}/).first)
    period = basename.scan(/(?<=_)20[[:digit:]]{6}/).first || raise("Could not find time range in #{basename}")
  end

  case period[4..5].to_i
  when 1..3
    quarter = 1
  when 4..6
    quarter = 2
  when 7..9
    quarter = 3
  when 10..12
    quarter = 4
  else
    raise "Invalid month: #{month}"
  end

  schedule = basename.scan(/schedule\w+(?=_20)/i).first

  Metadata.new(basename, year, period, quarter, schedule)
end

# Rake download gets us form-adv-complete-ria.zip
# inside multiple zip files, including "FORM ADV COMPLETE RIA Jan 2001 to June 30, 2020.zip"
# which gets extracted to form_adv_complete_ria_jan_2001_to_june_30_2020.zip
def extract_inner_zip
  Zip::File.open('./form-adv-complete-ria.zip') do |outer_zip_file|
    entry = outer_zip_file.get_entry("FORM ADV COMPLETE RIA Jan 2001 to June 30, 2020.zip")
    filename = entry.name.downcase.tr(' ', '_').tr(',', '')
    entry.extract(filename) unless File.exist?(filename)
  end
end

def loop_entries
  Zip::File.open('./form_adv_complete_ria_jan_2001_to_june_30_2020.zip') do |zip_file|
    zip_file.entries.each do |entry|
      yield entry
    end
  end
end

def file_writer(entry)
  proc do |file|
    entry.get_input_stream.each_line do |line|
      file.puts(line
                  .strip
                  .force_encoding(Encoding::ISO_8859_1)
                  .encode('UTF-8', :invalid => :replace, :undef => :replace, :replace => ''))
    end
  end
end

def extract_files
  loop_entries do |entry|
    metadata = filename_metadata(entry.name)
    directory = DATA_DIR.join(metadata.year).join("Q#{metadata.quarter}")
    FileUtils.mkdir_p directory
    path = directory.join(metadata.basename).to_s
    puts "Extracting #{path}"
    File.open(path, 'w', encoding: Encoding::UTF_8, &file_writer(entry))
  end
end

def run
  extract_inner_zip
  extract_files
end

run
