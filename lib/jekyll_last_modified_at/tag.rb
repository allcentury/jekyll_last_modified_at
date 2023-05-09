require 'liquid'

module JekyllLastModifiedAt
  class LastModifiedBlock < ::Liquid::Block
    def render(context)
      text = super
      if text.include?("IGNORE")
        text = nil
      end
      page = context['page']["relative_path"]

      entry = JekyllLastModifiedAt::FileDB.cache(page)
      if entry
        "#{text}#{entry.to_liquid}"
      else
        "#{text}#{Time.now.iso8601}"
      end
    end
  end
end

Liquid::Template.register_tag('last_modified_at', JekyllLastModifiedAt::LastModifiedBlock)
