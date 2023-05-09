require "spec_helper"

RSpec.describe JekyllLastModifiedAt::LastModifiedBlock do
  let(:jekyll_context) do
    instance_double(Liquid::Context)
  end
  let(:tag_name) { "last_modified_at" }
  let(:mark_up) { "last_modified_at" }
  let(:last_modified_at) { Time.now }

  before(:each) do
    JekyllLastModifiedAt::FileDB.flush_all!
  end

  context "documents" do
    let(:file) do
      double("File", relative_path: "my_file")
    end

    let(:page) do
      instance_double(Jekyll::Drops::DocumentDrop, to_liquid: file)
    end

    before(:each) do
      allow(file).to receive(:[]).with("relative_path").and_return(file.relative_path)
    end

    it "finds the last_modified_at if found" do
      entry = JekyllLastModifiedAt::Entry.new("my_file", "abc123", last_modified_at, "url")
      JekyllLastModifiedAt::FileDB.update(entry)
      JekyllLastModifiedAt::FileDB.read(entry)

      expect(Liquid::Template.tags.to_h.keys).to include("last_modified_at")


      template = Liquid::Template.parse("{% last_modified_at %}last_modified_at: {% endlast_modified_at %}")

      expect(template.render("page" => page)).to eq("last_modified_at: #{last_modified_at.iso8601}")
    end

    it "renders current time if last_modified_at is not found" do

      template = Liquid::Template.parse("{% last_modified_at %} last_modified_at: {% endlast_modified_at %}")

      utc = Time.now.iso8601
      time = instance_double(Time, iso8601: utc)
      allow(Time).to receive(:now).and_return(time)

      expect(template.render("page" => page)).to include(utc)
    end
  end
end
