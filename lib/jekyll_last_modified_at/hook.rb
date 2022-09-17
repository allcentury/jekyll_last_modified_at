require "jekyll"

module JekyllLastModifiedAt
  module Hook
    def self.get_modified
      proc do |item|
        loader = JekyllLastModifiedAt::Loader.new(item)
        next if loader.ignore?

        item.data['last_modified_at'] = loader.last_modified_at
      end
    end
  end
end


Jekyll::Hooks.register(:documents, :post_render, priority: :high, &JekyllLastModifiedAt::Hook.get_modified)
Jekyll::Hooks.register(:posts, :post_render, priority: :high, &JekyllLastModifiedAt::Hook.get_modified)
Jekyll::Hooks.register(:pages, :post_render, priority: :high, &JekyllLastModifiedAt::Hook.get_modified)
