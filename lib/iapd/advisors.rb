# frozen_string_literal: true

module Iapd
  module Advisors
    ADVISOR_COLUMNS = %w[name sec_file_number crd_number table].freeze
    EXTRACT_DATE = ->(h) { Date.parse(h.fetch('DateSubmitted')) }
    SORT_BY_RECENT_SUBMISSION_DATE = ->(a, b) { EXTRACT_DATE.call(b) <=> EXTRACT_DATE.call(a) }

    # Generate an array of all advisors across all Base_A Tables
    # Many advisors will have entries in many tables, but this
    # will only include the most recent table.
    def advisors
      sec_numbers = Set.new
      rows = []

      base_a_tables.each do |table|
        execute(advisor_sql(table)).each do |row|
          unless sec_numbers.include? row['sec_file_number']
            sec_numbers << row['sec_file_number']
            rows << add_table_and_remove_int_pairs(table, row)
          end
        end
      end

      rows
    end

    def advisor_by_sec_file_number(sec_file_number)
      base_a_tables.each do |table|
        rows = execute(search_by_file_number_sql(sec_file_number, table))
        next unless rows.length.positive?

        advisor_hash = rows.sort(&SORT_BY_RECENT_SUBMISSION_DATE).first
        return add_table_and_remove_int_pairs(table, advisor_hash)
      end
    end

    # saves output of #advisors to csv
    def save_advisors_to_csv(file_path = './advisors.csv')
      File.open(file_path, 'w') do |f|
        f.write ADVISOR_COLUMNS.to_csv
        advisors.each do |row|
          f.write row.values_at(*ADVISOR_COLUMNS).to_csv
        end
      end
    end

    private

    def add_table_and_remove_int_pairs(table, row)
      add_table(remove_int_pairs(row), table)
    end

    def remove_int_pairs(row)
      row.delete_if { |k, _| k.is_a? Integer }
    end

    def add_table(row, table)
      row.merge('table' => table)
    end

    def advisor_sql(table)
      if table.scan(/_([0-9]+)_/).first.first >= '20171001'
        crd_col = '1E1'
      else
        crd_col = '1E'
      end

      <<-SQL
      SELECT `1A` as name,
             `1D` as sec_file_number,
             `#{crd_col}` as crd_number,
             `5F2C` as assets_under_management,
             `5F2F` as total_number_of_accounts
      FROM #{table}
      SQL
    end

    def search_by_file_number_sql(sec_file_number, table)
      "SELECT *  FROM #{table} WHERE `1D` = '#{sec_file_number}'"
    end
  end
end
