#!/usr/bin/ruby

require 'rexml/document'
include REXML
require 'xmlbasedgraphviz' # see the snippet making a diagram with XML and graphviz

# file: xml2graphviz.rb

class XML2Graphviz
 
  def nrecords
    doc = Document.new("<nodes><summary/></nodes>")
    doc.root.add_element @nrecords
    doc
  end
  
  def erecords
    doc = Document.new("<nodes><summary><output_type>gif</output_type><output_file>../htdocs/graphics2.gif</output_file></summary></nodes>")
    doc.root.add_element @erecords
    doc
  end
  
  private

  def initialize(doc)
    @count = 100
    @nrecords = Element.new('records')
    @erecords = Element.new('records')

    b = fetch_all_nodes(doc, @nrecords, @erecords)

  end
  
  def get_id()
    @count += 1
    @count.to_s
  end
  
  def add_node(doc_name, records)
    node = Element.new('node')
    node.add_attribute('id', get_id())
    label = Element.new('label')
    label.text = doc_name
    node.add_element label
    
    records.add_element node
  end
  
  def fetch_all_nodes(doc, nrecords, erecords)

    pnode = add_node(doc.name, nrecords) if doc.name.to_s.length > 0 
    
    doc.elements.each do |node|
      edge = Element.new('edge')
      summary = Element.new('summary')
      records = Element.new('records')
      edge.add_element summary

      child_node = fetch_all_nodes(node, nrecords, erecords) 
      
      cnode = Document.new(child_node.to_s)
      pnode_copy = Document.new(pnode.to_s)
      records.add_element pnode_copy
      records.add_element cnode

      edge.add_element records
      erecords.add_element edge
    end
   
    return pnode if doc.name.to_s.length > 0 
    
  end
end


if __FILE__ == $0 then

letter =<<LETTER
<letters>
  <summary/>
  <records>
    <letter>a</letter>
    <letter>b</letter>
  </records>
</letters>
LETTER

options =<<OPTIONS
<options>
  <summary/>
  <records>
    <option>
      <summary><type>node</type></summary>
      <records>
        <attribute><name>color</name><value>#ddaa66</value></attribute>
        <attribute><name>style</name><value>filled</value></attribute>
        <attribute><name>shape</name><value>box</value></attribute>                    
        <attribute><name>penwidth</name><value>1</value></attribute>          
        <attribute><name>fontname</name><value>Trebuchet MS</value></attribute>
        <attribute><name>fontsize</name><value>8</value></attribute>                    
        <attribute><name>fillcolor</name><value>#775500</value></attribute>                    
        <attribute><name>fontcolor</name><value>#ffeecc</value></attribute>          
        <attribute><name>margin</name><value>0.0</value></attribute>
      </records>
    </option>
    <option>
      <summary><type>edge</type></summary>
      <records>
        <attribute><name>color</name><value>#999999</value></attribute>
        <attribute><name>weight</name><value>1</value></attribute>
        <attribute><name>fontsize</name><value>6</value></attribute>                    
        <attribute><name>fontcolor</name><value>#444444</value></attribute>          
        <attribute><name>fontname</name><value>Verdana</value></attribute>
        <attribute><name>dir</name><value>forward</value></attribute>                    
        <attribute><name>arrowsize</name><value>0.5</value></attribute>          
      </records>    
    </option>  
  </records>
</options>
OPTIONS

  doc = Document.new(letter)
  x2g = XML2Graphviz.new(doc)

  doc_options = Document.new(options)
  xbg = XMLBasedGraphviz.new(doc_options, x2g.nrecords, x2g.erecords)


end
