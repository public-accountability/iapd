# frozen_string_literal: true

module Iapd
  class Database
    attr_reader :db

    delegate :execute, to: :@db
    
    def initialize(database = 'iapd.db')
      @db = SQLite3::Database.new(database)
    end

    def tables
      @db
        .execute("SELECT name FROM sqlite_master WHERE type='table'")
        .flatten
    end

    def base_a_tables
      tables
        .select { |t| t.include? 'ADV_Base_A' }
        .sort
        .reverse
    end
  end
end
