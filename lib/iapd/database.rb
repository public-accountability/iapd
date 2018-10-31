# frozen_string_literal: true

module Iapd
  class Database
    attr_reader :db

    delgate :execute, to: :@db
    
    def initialize(database = 'iapd.db')
      @db = SQLite3::Database.new(database)
    end

    def tables
      @db
        .execute("SELECT name FROM sqlite_master WHERE type='table'")
        .flatten
    end
  end
end
