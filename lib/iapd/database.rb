# frozen_string_literal: true

module Iapd
  class Database
    attr_reader :db
    delegate :execute, to: :@db

    include Iapd::Tables
    include Iapd::Advisors
    include Iapd::Owners
    
    def initialize(database = 'iapd.db')
      @db = SQLite3::Database.new(database)
      @db.results_as_hash = true
    end
  end
end
