# -*- ruby -*-

# simply for debugging - prints a slice of an array or any other object that supports 'each'
def printSlice (theslice)
  theIterator=0
  theslice.each do |the_entry|
    print the_entry.inspect, "; "
    break if theIterator > 10
    theIterator=theIterator+1
  end
end

# simply for debugging - prints (puts) an inspection of the object
def inspectObject (theObject)
  puts theObject.inspect
end

def human_timing(elapsed_seconds)
  return "unknown time" if elapsed_seconds.nil?
  return "#{((elapsed_seconds*100).round.to_f)/100} seconds" if elapsed_seconds < 5
  return "#{((elapsed_seconds*10).round.to_f)/10} seconds" if elapsed_seconds < 60
  return "#{((elapsed_seconds/6).round.to_f)/10} minutes"
end

def block_timing (taskname="task")
  puts "starting #{taskname}" if @verbose
  start = Time.now
  yield
  stop = Time.now
  elapsed_seconds = stop.to_f - start.to_f
  puts "#{taskname} ran in "+ human_timing(elapsed_seconds) if @verbose
end

def row_iterator(data, cnt=0, row_message_cnt=500, start=nil)
  data.each do |data_row|
    cnt+=1
    if cnt%row_message_cnt==0 and @verbose
      if ! start.blank?
        stop = Time.now
        elapsed_seconds = stop.to_f - start.to_f
        puts "processed #{cnt} rows in " + human_timing(elapsed_seconds)
      else
        puts "processed #{cnt} rows" 
      end
    end
    yield(data_row)
    begin
    rescue Exception => error
      puts "something happened: "+error
      errors += $!.message
      puts data_row.inspect
      throw data_row.inspect
    end
  end
end

