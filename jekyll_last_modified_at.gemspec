# frozen_string_literal: true

require_relative "lib/jekyll_last_modified_at/version"

Gem::Specification.new do |spec|
  spec.name          = "jekyll_last_modified_at"
  spec.version       = JekyllLastModifiedAt::VERSION
  spec.authors       = ["Anthony Ross"]
  spec.email         = ["anthony.s.ross@gmail.com"]

  spec.summary       = "A Gem to compute last-modified-at for Jekyll Posts and Sitemaps"
  spec.description   = "A gem that computes the last-modified-at value of a given post"
  spec.homepage      = "https://github.com/allcentury/jekyll_last_modified_at"
  spec.required_ruby_version = ">= 2.4.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "jekyll", "~> 4.0"
  spec.add_development_dependency "pry", "~> 0.1"
end
