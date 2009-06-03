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


