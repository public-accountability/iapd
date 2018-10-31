# frozen_string_literal: true

module Iapd
  class Database
    attr_reader :db

    delegate :execute, to: :@db

    def initialize(database = 'iapd.db')
      @db = SQLite3::Database.new(database)
    end

    def tables
      execute("SELECT name FROM sqlite_master WHERE type='table'").flatten
    end

    def base_a_tables
      tables
        .select { |t| t.include? 'ADV_Base_A' }
        .sort
        .reverse
    end

    def advisors
      @advisors ||= Iapd::Advisors.new(self)
    end
    
    # 'IA_ADV_Base_A_20171001_20171231'
  end
end
