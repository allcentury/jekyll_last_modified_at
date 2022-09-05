module JekyllLastModifiedAt
  class FileDB
    DATABASE = "last_modified_at.json"

    def self.read_all
      return {} unless File.readable?(DATABASE)

      file = File.read(DATABASE)

      return {} if file.empty?

      json = JSON.parse(file)

      json.map do |file, entry|
        [
          file,
          Entry.new(
            file,
            entry["checksum"],
            Time.parse(entry["last_modified_at"])
          )
        ]
      end.to_h
    end

    def self.update(record)
      existing = read_all
      existing[record.file_name] = record

      File.open(DATABASE, "w+") do |file|
        file << JSON.generate(existing)
      end
    end

    def self.flush_all!
      File.open(DATABASE, "w") {}
    end
  end
end
