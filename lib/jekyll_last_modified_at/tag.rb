require 'liquid'
require 'time'

module JekyllLastModifiedAt
  class LastModifiedBlock < ::Liquid::Block
    def render(context)
      text = super
      page = context['page'].relative_path

      entry = JekyllLastModifiedAt::FileDB.read(page)
      if entry
        "#{text}#{entry.to_date}"
      else
        "#{text}#{Time.now.strftime("%d-%b-%y")}"
      end
    end
  end
end

Liquid::Template.register_tag('last_modified_at', JekyllLastModifiedAt::LastModifiedBlock)
