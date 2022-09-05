module JekyllLastModifiedAt
  class Entry
    attr_accessor :file_name, :checksum, :last_modified_at
    def initialize(file_name, checksum, last_modified_at)
      @file_name = file_name
      @checksum = checksum
      @last_modified_at = last_modified_at
    end

    def to_h
      {
        file_name: file_name,
        checksum: checksum,
        last_modified_at: last_modified_at,
      }
    end

    def ==(other)
      file_name == other.file_name && checksum == other.checksum
    end

    def to_json(_arg)
      to_h.to_json
    end

    def timestamp
      last_modified_at
    end

    def to_liquid
      "#{last_modified_at}"
    end
  end
end
