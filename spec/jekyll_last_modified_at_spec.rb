# frozen_string_literal: true

RSpec.describe JekyllLastModifiedAt do
  class MemDB
    @@db = {}

    def self.records=(db)
      @@db = db
    end

    def self.records
      @@db
    end

    def self.read_all
      records
    end

    def self.update(record)
      records[record.file_name] = record
    end

    def self.flush!
      self.records = {}
    end
  end

  it "has a version number" do
    expect(JekyllLastModifiedAt::VERSION).not_to be nil
  end

  describe JekyllLastModifiedAt::Loader do
    let(:loader) do
      described_class.new(doc, MemDB)
    end

    let(:file_name) { "_posts/my_post.md" }
    let(:content) { "I wrote a post!" }

    let(:doc) do
      instance_double(
        Jekyll::Document,
        relative_path: file_name,
        content: content,
        source_file_mtime: mtime,
      )
    end
    let(:mtime) do
      Time.now.utc.iso8601
    end

    let(:entry) do
      checksum = Digest::MD5.hexdigest(content)
      JekyllLastModifiedAt::Entry.new(file_name, checksum, mtime)
    end

    before(:each) do
      MemDB.flush!
    end

    after(:each) do
      MemDB.flush!
    end

    it "determines last_modified_at from mtime without an existing entry" do
      expect(loader.last_modified_at.timestamp).to eq(mtime)
    end

    it "determines last_modified_at from mtime without an existing entry and saves it" do
      expect(MemDB).to receive(:update).with(entry).once

      loader.last_modified_at
    end

    it "with no checksum change it returns the old record and does nothing" do
      MemDB.update(entry)

      expect(MemDB).not_to receive(:update)

      expect(loader.last_modified_at).to eq(entry)
    end

    context "checksum changes" do
      let(:content) { "I'm some new content" }

      it "with a checksum change the database is updated and the entry with a new timestamp" do
        checksum = Digest::MD5.hexdigest("I'm old content")
        old_entry = JekyllLastModifiedAt::Entry.new(file_name, checksum, mtime)
        MemDB.update(old_entry)

        expect(MemDB).to receive(:update).with(entry).once

        expect(loader.last_modified_at).to eq(entry)
        expect(MemDB.records.keys.size).to eq(1)
      end
    end
  end

  describe JekyllLastModifiedAt::FileDB do
    let(:db) { described_class }
    it "parses JSON and builds entries" do
      name = "some_file"
      checksum = "abc213"
      time = Time.now.utc.iso8601
      file = {
        some_file: {
          file_name: name,
          checksum: checksum,
          last_modified_at: time,
        }
      }

      json =JSON.generate(file)

      allow(File).to receive(:readable?).and_return(true)
      allow(File).to receive(:read).with(described_class::DATABASE).and_return(json)


      entries = db.read_all
      entry = JekyllLastModifiedAt::Entry.new(name, checksum, time)

      expect(entries).to eq({ "some_file" => entry})
    end

    it "updates" do
      name, checksum, time = "name", "abc123", Time.now.utc.iso8601
      entry = JekyllLastModifiedAt::Entry.new(name, checksum, time)

      db.update(entry)

      entries = db.read_all

      expect(entries.keys.size).to eq(1)
    end
  end
end
