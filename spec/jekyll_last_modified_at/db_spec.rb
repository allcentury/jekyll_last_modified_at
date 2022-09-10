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
    url = "myurl"
    file = {
      some_file: {
        file_name: name,
        checksum: checksum,
        last_modified_at: time,
        url: url,
      }
    }

    json = JSON.generate(file)
    entry = JekyllLastModifiedAt::Entry.new(name, checksum, time, url)
    db.update(entry)

    entries = db.read_all

    expect(entries).to eq({ "some_file" => entry})
  end

  context "updates" do
    it "updates" do
      name, checksum, time, url = "name", "abc123", Time.now, "myurl"
      entry = JekyllLastModifiedAt::Entry.new(name, checksum, time, url)

      db.update(entry)

      entries = db.read_all

      expect(entries.keys.size).to eq(1)
    end
  end
end

