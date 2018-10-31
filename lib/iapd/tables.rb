# frozen_string_literal: true

module Iapd
  module Tables
    def tables
      execute("SELECT name FROM sqlite_master WHERE type='table'")
        .map { |t| t['name'] }
    end

    def base_a_tables
      return @_base_a_tables if defined?(@_base_a_tables)

      @_base_a_tables = tables.select { |t| t.include? 'ADV_Base_A' }.sort.reverse
    end

    def base_a_to_schedule(base_a_table)
      date_str = base_a_table.scan(/_([0-9]+_[0-9]+)$/).first.first
      "IA_Schedule_A_B_#{date_str}"
    end
  end
end
