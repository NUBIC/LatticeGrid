module TagsHelper
  # See the README for an example using tag_cloud.
  def tag_cloud(tags, classes)
    return if tags.empty?
    
    max_count = tags.sort_by(&:count).last.count.to_i
    min_count = tags.sort_by(&:count).first.count.to_i
    divisor = ((max_count - min_count) / classes.size) + 1
     
    tags.each do |tag|
      index = ((tag.count.to_i - min_count) / divisor).round
      yield tag, classes[index]
    end
  end
end
