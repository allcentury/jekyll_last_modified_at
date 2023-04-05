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
    context "with a Document" do
      let(:loader) do
        described_class.new(doc, MemDB)
      end

      let(:file_name) { "_posts/my_post.md" }
      let(:content) { "I wrote a post!" }
      let(:url) { '/mypost' }

      let(:doc) do
        instance_double(
          Jekyll::Document,
          relative_path: file_name,
          content: content,
          source_file_mtime: mtime,
          url: url,
          site: site,
        )
      end

      let(:site) do
        instance_double(Jekyll::Site, config: config)
      end
      let(:config) do
        {
          'jekyll_last_modified_at' => {
            'exclude' => [
              '.*.scss',
              'feed.xml',
              '.*.css',
              '.*.js',
            ]
          }
        }
      end
      let(:mtime) do
        Time.now
      end

      let(:formatted_dat) do
        mtime.strftime("%d-%b-%y")
      end

      let(:entry) do
        checksum = Digest::MD5.hexdigest(content)
        JekyllLastModifiedAt::Entry.new(file_name, checksum, mtime, url)
      end

      before(:each) do
        MemDB.flush!
      end

      after(:each) do
        MemDB.flush!
      end

      context "exclusions" do
        context "exact matches" do
          let(:file_name) { "feed.xml" }
          it "skips from a config list" do
            expect(loader.ignore?).to eq true
          end
        end

        context "wildcards" do
          let(:file_name) { "mygreat.css" }

          it "skips from a config list" do
            expect(loader.ignore?).to eq true
          end
        end

        context "no exclusions" do
          let(:config) { {} }
          it "returns false" do
            expect(loader.ignore?).to eq false
          end
        end

        context "no matches" do
          let(:file_name) { "mygreat.md" }
          it "returns false" do
            expect(loader.ignore?).to eq false
          end
        end
      end

      it "determines last_modified_at from mtime without an existing entry" do
        expect(loader.last_modified_at.timestamp).to eq(mtime.iso8601)
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
          old_entry = JekyllLastModifiedAt::Entry.new(file_name, checksum, mtime, url)
          MemDB.update(old_entry)

          expect(MemDB).to receive(:update).with(entry).once

          expect(loader.last_modified_at).to eq(entry)
          expect(MemDB.records.keys.size).to eq(1)
        end
      end
    end

    context "with a Page" do
      let(:loader) do
        described_class.new(page, MemDB)
      end

      let(:file_path) { "pages/404.html" }
      let(:content) { "my 404 page" }

      let(:page) do
        instance_double(
          Jekyll::Page,
          relative_path: file_path,
          content: content,
          url: "mypost",
        )
      end
      let(:mtime) { Time.now }

      it "determines last_modified_at from mtime without an existing entry" do
        allow(File).to receive(:mtime).and_return(mtime)
        expect(loader.last_modified_at.timestamp).to eq(mtime.iso8601)
      end

      it "determines last_modified_at if the file has never been persisted before" do
        allow(File).to receive(:readable?).and_return(false)
        expect(loader.last_modified_at.timestamp).to eq(mtime.iso8601)
      end
    end
  end
end
