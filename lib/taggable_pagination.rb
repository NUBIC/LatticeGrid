module ActiveRecord
  module Acts #:nodoc:
    module Taggable #:nodoc:
      module SingletonMethods

        def count_tagged_with(*args)
          options = find_options_for_find_tagged_with(*args)
          options.delete(:order)
          options.blank? ? 0 : count("#{table_name}.id", options.merge(:select => nil, :distinct => true))
        end

        def _paginate_tagged_with(tags, options = {})
          page, per_page = wp_parse_options(options)
          offset = (page.to_i - 1) * per_page
          options.delete(:per_page)
          options.delete(:page)
          count = count_tagged_with(tags, options)
          options.merge!(:offset => offset, :limit => per_page.to_i)
          items = find_tagged_with(tags, options)
          returning WillPaginate::Collection.new(page, per_page, count) do |p|
            p.replace items
          end
        end

      end
    end
  end
end
