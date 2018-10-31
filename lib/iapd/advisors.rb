# frozen_string_literal: true

module Iapd
  module Advisors
    def advisors
      sec_numbers = Set.new
      rows = []

      base_a_tables.each do |table|
        execute(advisor_sql(table)).each do |row|
          unless sec_numbers.include? row[1]
            sec_numbers << row[1]
            rows << row.insert(3, table)
          end
        end
      end

      rows
    end
    
    def save_advisors_to_csv(file_path = './advisors.csv')
      File.open(file_path, 'w') do |f|
        f.write %w[name sec_file_number crd_number table].to_csv
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

  end
end
