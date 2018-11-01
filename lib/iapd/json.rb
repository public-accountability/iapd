# frozen_string_literal: true

module Iapd
  module Json

    def save_json_to_file(file_path = './iapd.json')
      File.open(file_path, 'w') do |f|
        f.write JSON.pretty_generate(json)
      end
    end

    def json(filter = nil)
      advisors(filter).map do |advisor|
        the_owners = owners(advisor['sec_file_number'])
        advisor.merge('owners' => the_owners)
      end
    end
  end
end
