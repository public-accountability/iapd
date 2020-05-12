#!/usr/bin/env ruby
# frozen_string_literal: true

require 'zip'
require 'fileutils'

ZIP_FILE = './form-adv-complete-ria.zip'
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

Zip::File.open(ZIP_FILE) do |zip_file|
  zip_file.entries.each do |entry|
    metadata = filename_metadata(entry.name)
    directory = DATA_DIR.join(metadata.year).join("Q#{metadata.quarter}")
    FileUtils.mkdir_p directory
    path = directory.join(metadata.basename).to_s

    puts "Extracting #{path}"

    File.open(path, 'w', encoding: Encoding::UTF_8) do |file|
      entry.get_input_stream.each_line do |line|
        file.puts(line
                    .strip
                    .force_encoding(Encoding::ISO_8859_1)
                    .encode('UTF-8', :invalid => :replace, :undef => :replace, :replace => ''))
      end
    end
  end
end
