require 'liquid'

module JekyllLastModifiedAt
  class LastModifiedBlock < ::Liquid::Block
    def render(context)

      page = context['page'].relative_path

      entry = JekyllLastModifiedAt::FileDB.read(page)
      if entry
        "#{entry.to_liquid}"
      else
        "#{Time.now.iso8601}"
      end
    end
  end
end

Liquid::Template.register_tag('last_modified_at', JekyllLastModifiedAt::LastModifiedBlock)
