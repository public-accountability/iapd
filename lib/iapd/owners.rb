# frozen_string_literal: true

module Iapd
  module Owners
    REMOVE_INT_PAIRS = ->(h) { h.delete_if { |k, _| k.is_a?(Integer) } }
    
    def owners(sec_file_number)
      advisor = advisor_by_sec_file_number(sec_file_number)
      filing_id = advisor.fetch "FilingID"
      table = base_a_to_schedule advisor.fetch('table')

      execute(owners_sql(filing_id, table)).map(&REMOVE_INT_PAIRS)
    end

    private

    def owners_sql(filing_id, table)
      <<-SQL
      SELECT *
      FROM #{table}
      WHERE FilingId = #{filing_id}
      SQL
    end
  end
end
