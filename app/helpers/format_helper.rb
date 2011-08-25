module FormatHelper
  def formatted_date(obj)
    return "" if obj.blank?
    return obj.to_s(:justdate) if obj.class.to_s =~ /date|time/i
    return obj.to_s
  end
  
  def format_object_div(div_name, item)
    out="<div id='#{div_name}'>"
    unless item.blank? then
      out+="<b>#{div_name.to_s.humanize}</b><br/>"
      out+=formatted_date(item)
    end
    out+="</div>"
    out
  end
end
