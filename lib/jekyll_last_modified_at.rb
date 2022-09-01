# frozen_string_literal: true

require_relative "jekyll_last_modified_at/version"
require 'digest'
require 'json'
require 'jekyll'

module JekyllLastModifiedAt
  class Error < StandardError; end
  class LastModifiedAtLoader
    Entry = Struct.new(:file_name, :checksum, :last_modified_at) do
      def ==(other)
        file_name == other.file_name && checksum == other.checksum
      end

      def to_json(_arg)
        to_h.to_json
      end
    end


    attr_reader :file_name, :content, :entry, :doc
    DATABASE = "last_modified_at.json"

    def initialize(doc)
      @file_name = doc.relative_path
      @content = doc.content
      @doc = doc
      @entry = Entry.new(file_name, checksum)
    end

    def last_modified_at
      existing_entry = entries[file_name]

      # we've never seen this file before
      # set the last_modified_at to the mtime and persist
      if !existing_entry
        entry.last_modified_at = doc.source_file_mtime || Time.now.utc

        update_file
      elsif existing_entry == entry
        ## no change in checksum so the file hasn't changed
        puts "No change in #{file_name}"
      else
        ## checksum has changed, update timestamp
        entry.last_modified_at = Time.now

        update_file
      end
    end

    def update_file
      existing = entries
      existing[file_name] = entry

      puts "updating existing file with #{JSON.generate(existing)}"
      File.open(DATABASE, "w+") do |file|
        file << JSON.generate(existing)
      end
    end

    def entries
      return {} unless File.readable?(DATABASE)

      file = File.read(DATABASE)
      json = JSON.parse(file)

      load_entries(json)
    end

    def load_entries(json)
      json.map do |file, entry|
        [file, Entry.new(file, entry["checksum"], entry["last_modified_at"])]
      end.to_h
    end

    def checksum
      Digest::MD5.hexdigest(content)
    end
  end
end

Jekyll::Hooks.register(:documents, :post_render, priority: :high) do |doc, payload|
  modified_at = LastModifiedAtLoader.new(doc).last_modified_at

  puts modified_at
end
