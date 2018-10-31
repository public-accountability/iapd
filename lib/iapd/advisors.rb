# frozen_string_literal: true

module Iapd
  module Advisors
    ADVISOR_COLUMNS = %w[name sec_file_number crd_number].freeze
    SORT_BY_RECENT_SUBMISSION_DATE = ->(a, b) { Date.parse(b.fetch('DateSubmitted')) <=> Date.parse(a.fetch('DateSubmitted')) }

    # Generate an array of all advisors across all Base_A Tables
    # Many advisors will have entries in many tables, but this
    # will only include the most recent table.
    # 
    # columns: name, sec_file_number, crd_number, table
    def advisors
      sec_numbers = Set.new
      rows = []

      base_a_tables.each do |table|
        execute(advisor_sql(table)).each do |row|
          unless sec_numbers.include? row['sec_file_number']
            sec_numbers << row['sec_file_number']
            rows << row.values_at(*ADVISOR_COLUMNS) + [table]
          end
        end
      end

      rows
    end

    def advisor_by_sec_file_number(sec_file_number)
      base_a_tables.each do |table|
        rows = execute(search_by_file_number_sql(sec_file_number, table))
        if rows.length > 0
          return rows
                   .sort(&SORT_BY_RECENT_SUBMISSION_DATE)
                   .first
                   .merge('table' => table)
                   .delete_if { |k, _| k.is_a? Integer }
        end
      end
    end

    # saves output of #advisors to csv
    def save_advisors_to_csv(file_path = './advisors.csv')
      File.open(file_path, 'w') do |f|
        f.write (ADVISOR_COLUMNS + %w[table]).to_csv
        advisors.each { |row| f.write row.to_csv }
      end
    end

    private

    def advisor_sql(table)
      if table.scan(/_([0-9]+)_/).first.first >= '20171001'
        crd_col = '1E1'
      else
        crd_col = '1E'
      end

      <<-SQL
      SELECT `1A` as name,
             `1D` as sec_file_number,
             `#{crd_col}` as crd_number
      FROM #{table}
      SQL
    end

    def search_by_file_number_sql(sec_file_number, table)
      "SELECT *  FROM #{table} WHERE `1D` = '#{sec_file_number}'"
    end
  end
end
