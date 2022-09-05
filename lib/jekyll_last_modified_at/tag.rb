module JekyllLastModifiedAt
  class Tag < Liquid::Tag
    def initialize(tag_name, text, tokens)
      super
    end

    def render(context)

    end
  end
end

Liquid::Template.register_tag('last_modified_at', JekyllLastModifiedAt::Tag)
