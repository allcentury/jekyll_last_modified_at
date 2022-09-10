module JekyllLastModifiedAt
  class Entry
    attr_accessor :file_name, :checksum, :last_modified_at, :url
    def initialize(file_name, checksum, last_modified_at, url)
      @file_name = file_name
      @checksum = checksum
      @last_modified_at = last_modified_at
      @url = url
    end

    def to_h
      {
        file_name: file_name,
        checksum: checksum,
        last_modified_at: last_modified_at.iso8601,
        url: url,
      }
    end

    def ==(other)
      file_name == other.file_name && checksum == other.checksum
    end

    def to_json(_arg)
      to_h.to_json
    end

    def timestamp
      last_modified_at.iso8601
    end

    def to_liquid
      "#{last_modified_at.iso8601}"
    end
  end
end
