module ActiveRecord
  class Base
    ##
    # Deprecated method last existing in Rails 2.3.8
    # Adding here as acts_as_taggable.rb still calls this method.
    # TODO: replaces acts_as_taggable_on_steroids with acts_as_taggable_on gem
    def self.merge_conditions(*conditions)
      segments = []
      conditions.each do |condition|
        unless condition.blank?
          sql = sanitize_sql(condition)
          segments << sql unless sql.blank?
        end
      end
      "(#{segments.join(') AND (')})" unless segments.empty?
    end
  end
end