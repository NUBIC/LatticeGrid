module ActiveRecord
  module Acts #:nodoc:
    module Taggable #:nodoc:
      module SingletonMethods

        # assumes there is a column called 'information_content' in Taggings
        def information_cloud(tag_ids, options = {})
          # order by the sum of all the information_content tags for a taggable_id
          # column_names.collect{|x| base_class.table_name+'.'+x}.join(',')
          Tag.find(:all, options.merge({
            :select => "#{Tagging.table_name}.taggable_id, COUNT(#{Tagging.table_name}.tag_id) AS count, SUM(#{Tagging.table_name}.information_content) AS total",
            :joins  => "JOIN #{Tagging.table_name} ON #{Tagging.table_name}.taggable_type = '#{base_class.name}'
              AND  #{Tag.table_name}.id IN (#{tag_ids.join(',')})
              AND  #{Tagging.table_name}.tag_id = #{Tag.table_name}.id",
            :order => options[:order] || "total DESC, #{Tagging.table_name}.taggable_id",
            :group => "#{Tagging.table_name}.taggable_id"
          }))
        end
      end
    end
  end
end

