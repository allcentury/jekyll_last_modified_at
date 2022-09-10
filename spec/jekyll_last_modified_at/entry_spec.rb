require "spec_helper"

RSpec.describe JekyllLastModifiedAt::Entry do
  let(:file_name) { "name" }
  let(:checksum) { "check123" }
  let(:last_modified_at) { Time.now }
  let(:url) { "/mypost" }
  let(:entry) do
    described_class.new(file_name, checksum, last_modified_at, url)
  end

  context "==" do
    it "when equal" do
      other = described_class.new(file_name, checksum, last_modified_at, url)
      expect(entry).to eq(other)
    end
    it "when not equal" do
      other = described_class.new(file_name, "check124", last_modified_at, url)
      expect(entry).not_to eq(other)
    end
  end

  it "to_liquid" do
    expect(entry.to_liquid).to eq(last_modified_at.iso8601)
  end
end
