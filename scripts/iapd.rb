#!/usr/bin/env ruby
# frozen_string_literal: true

# Helper functions for the IAPD dataset

require 'json'
require 'sqlite3'

module IAPD
  DB_FILE = 'iapd.db'
  BUSY_TIMEOUT = 500

  CRD = /\A[[:digit:]]+\Z/
  TAX = /\A[[:digit:]]{2}-{1}[[:digit:]]+\Z/

  # DB FUNCTIONS
  def self.database
    db = SQLite3::Database.new(DB_FILE, results_as_hash: true)
    db.busy_timeout = BUSY_TIMEOUT
    db
  end

  def self.with_database
    SQLite3::Database.new(DB_FILE, results_as_hash: true) do |db|
      db.busy_timeout = BUSY_TIMEOUT
      yield db
    end
  end

  def self.execute(sql, bindings = [])
    db = database
    result = db.execute(sql, bindings)
    db.close
    result
  end

  # various helper functions

  def self.to_dt(str)
    DateTime.strptime str, '%m/%d/%Y %I:%M:%S %p'
  end

  def self.tax?(s)
    TAX.match?(s) && !%w[00 99].include?(s.slice(0, 2))
  end

  # The owners dataset doesn't have a single unquie identifier for all people/companies.
  # Some owners have a CRD or EIN number which can be used.
  # Othwerwise, the "name" is the used as the key
  def self.owner_key(row)
    owner_id = row['owner_id']
    return owner_id if CRD.match?(owner_id) || tax?(owner_id)

    row['name']
  end
end
