
def generate_csv(data)
  data_hash = Hash.new(0)
  data.each do |x|
    the_date = x.created_at.to_s(:db_date)
    if data_hash.has_key?(the_date) then
      data_hash[the_date]=data_hash[the_date]+1
    else
      data_hash[the_date] = 1
    end
  end
  data_hash.sort 
end

def redirect_stdout
  orig_defout = $stdout
  $stdout = StringIO.new
  yield
  $stdout.string
ensure
  $stdout = orig_defout
end

def parse_svg (string, add_string)
  string=string.gsub(/\s/,' ')
  string=string.sub(/^.*<\?xml/,'<?xml')
  string=string.sub(/(<svg[^>]*>)/,'\1'+add_string)
  string=string.gsub(/>/,">\n")
  string=string.sub(/svg>.*$/,'svg>')
end

