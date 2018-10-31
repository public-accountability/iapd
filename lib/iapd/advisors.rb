# frozen_string_literal: true

module Iapd
  class Advisors < SimpleDelegator

    def save_to_csv(file_path = './advisors.csv')
      sec_numbers = Set.new

      File.open(file_path, 'w') do |f|
        f.write %w[name sec_file_number crd_number table].to_csv

        base_a_tables.each do |table|
          execute(advisor_sql(table)).each do |row|
            unless sec_numbers.include? row[1]
              sec_numbers << row[1]
              f.write row.insert(3, table).to_csv
            end
          end
        end
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

  end
end
