# frozen_string_literal: true

require_relative "jekyll_last_modified_at/version"
require_relative "jekyll_last_modified_at/db"
require_relative "jekyll_last_modified_at/entry"
require_relative "jekyll_last_modified_at/tag"
require_relative "jekyll_last_modified_at/hook"
require 'digest'
require 'json'
require 'jekyll'

module JekyllLastModifiedAt
  class Error < StandardError; end


  class Loader
    attr_reader :file_name, :content, :entry, :doc, :database, :entries

    def initialize(doc, database = FileDB)
      @file_name = doc.relative_path
      @content = doc.content
      @doc = doc
      @entry = Entry.new(file_name, checksum, nil, doc.url)
      @database = database
      @entries = database.read_all
    end

    def ignore?
      exclusions = doc.site.config.dig('last_modified_at', 'exclude')
      return false unless exclusions
      exclusions.each do |ex|
        # check for exact matches
        return true if File.basename(file_name) == ex
        if ex.include?("*")
          return true if file_name.match(ex)
        end
      end
    end

    def last_modified_at
      existing_entry = entries[file_name]

      # we've never seen this file before
      # set the last_modified_at to the mtime and persist
      if !existing_entry
        if doc.respond_to?(:source_file_mtime)
          entry.last_modified_at = doc.source_file_mtime || Time.now
        else # Page object
          entry.last_modified_at = if File.readable?(file_name)
            File.mtime(file_name)
          else
            Time.now
          end
        end

        database.update(entry)
        entry
      elsif existing_entry == entry
        ## no change in checksum so the file hasn't changed
        existing_entry
      else
        ## checksum has changed, update timestamp
        entry.last_modified_at = Time.now

        database.update(entry)

        entry
      end
    end

    def checksum
      Digest::MD5.hexdigest(content)
    end
  end
end
