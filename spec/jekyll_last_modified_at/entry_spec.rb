require "spec_helper"

RSpec.describe JekyllLastModifiedAt::Entry do
  let(:file_name) { "name" }
  let(:checksum) { "check123" }
  let(:last_modified_at) { Time.now }
  let(:entry) do
    described_class.new(file_name, checksum, last_modified_at)
  end

  it "==" do
    other = described_class.new(file_name, checksum, last_modified_at)
    expect(entry).to eq(other)
  end

  it "to_liquid" do
    expect(entry.to_liquid).to eq(last_modified_at.iso8601)
  end
end
