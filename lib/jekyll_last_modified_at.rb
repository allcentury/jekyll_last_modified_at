# frozen_string_literal: true

require_relative "jekyll_last_modified_at/version"
require 'digest'
require 'json'
require 'jekyll'

module JekyllLastModifiedAt
  class Error < StandardError; end

  class FileDB
    DATABASE = "last_modified_at.json"

    def self.read_all
      return {} unless File.readable?(DATABASE)

      file = File.read(DATABASE)
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
      existing[file_name] = record

      File.open(DATABASE, "w+") do |file|
        file << JSON.generate(existing)
      end
    end
  end

  Entry = Struct.new(:file_name, :checksum, :last_modified_at) do
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

  class Loader
    attr_reader :file_name, :content, :entry, :doc, :database, :entries

    def initialize(doc, database = FileDB)
      @file_name = doc.relative_path
      @content = doc.content
      @doc = doc
      @entry = Entry.new(file_name, checksum)
      @database = database
      @entries = database.read_all
    end

    def last_modified_at
      existing_entry = entries[file_name]

      # we've never seen this file before
      # set the last_modified_at to the mtime and persist
      if !existing_entry
        entry.last_modified_at = doc.source_file_mtime || Time.now.utc.iso8601

        database.update(entry)
        entry
      elsif existing_entry == entry
        ## no change in checksum so the file hasn't changed
        existing_entry
      else
        ## checksum has changed, update timestamp
        entry.last_modified_at = Time.now.utc.iso8601

        database.update(entry)

        entry
      end
    end

    def checksum
      Digest::MD5.hexdigest(content)
    end
  end
end

Jekyll::Hooks.register(:documents, :post_render, priority: :high) do |doc, payload|
  modified_at = JekyllLastModifiedAt::Loader.new(doc).last_modified_at
  doc.data['last_modified_at'] = modified_at
end
