require "spec_helper"

RSpec.describe JekyllLastModifiedAt::FileDB do
  let(:db) { described_class }
  before(:each) do
    db.flush_all!
  end

  it "parses JSON and builds entries" do
    name = "some_file"
    checksum = "abc213"
    time = Time.now.utc
    file = {
      some_file: {
        file_name: name,
        checksum: checksum,
        last_modified_at: time,
      }
    }

    json = JSON.generate(file)
    entry = JekyllLastModifiedAt::Entry.new(name, checksum, time)
    db.update(entry)

    entries = db.read_all

    expect(entries).to eq({ "some_file" => entry})
  end

  context "updates" do
    it "updates" do
      name, checksum, time = "name", "abc123", Time.now
      entry = JekyllLastModifiedAt::Entry.new(name, checksum, time)

      db.update(entry)

      entries = db.read_all

      expect(entries.keys.size).to eq(1)
    end
  end
end

