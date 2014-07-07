#!/bin/sh
# UNIX shell script. written Warren Kibbe, 2007

#Generate tree graphs of connections using publications
# junk in the first line -   awk 'NR!=1 {print}' removes it!

rake getConnectors program_num=1 print_internal=1 | awk 'NR!=1 {print}' > Program1int.dot
rake getConnectors program_num=1 print_external=1 | awk 'NR!=1 {print}' > Program1ext.dot
rake getConnectors program_num=1 print_internal=1 print_external=1 | awk 'NR!=1 {print}' > Program1.dot
rake getConnectors program_num=2 print_internal=1 | awk 'NR!=1 {print}' > Program2int.dot
rake getConnectors program_num=2 print_external=1 | awk 'NR!=1 {print}' > Program2ext.dot
rake getConnectors program_num=2 print_internal=1 print_external=1 | awk 'NR!=1 {print}' > Program2.dot

rake getConnectors program_num=3 print_internal=1 | awk 'NR!=1 {print}' > Program3int.dot
rake getConnectors program_num=3 print_external=1 | awk 'NR!=1 {print}' > Program3ext.dot
rake getConnectors program_num=3 print_internal=1 print_external=1 | awk 'NR!=1 {print}' > Program3.dot

rake getConnectors program_num=4 print_internal=1 | awk 'NR!=1 {print}' > Program4int.dot
rake getConnectors program_num=4 print_external=1 | awk 'NR!=1 {print}' > Program4ext.dot
rake getConnectors program_num=4 print_internal=1 print_external=1 | awk 'NR!=1 {print}' > Program4.dot

rake getConnectors program_num=5 print_internal=1 | awk 'NR!=1 {print}' > Program5int.dot
rake getConnectors program_num=5 print_external=1 | awk 'NR!=1 {print}' > Program5ext.dot
rake getConnectors program_num=5 print_internal=1 print_external=1 | awk 'NR!=1 {print}' > Program5.dot

rake getConnectors program_num=6 print_internal=1 | awk 'NR!=1 {print}' > Program6int.dot
rake getConnectors program_num=6 print_external=1 | awk 'NR!=1 {print}' > Program6ext.dot
rake getConnectors program_num=6 print_internal=1 print_external=1 | awk 'NR!=1 {print}' > Program6.dot

rake getConnectors program_num=7 print_internal=1 | awk 'NR!=1 {print}' > Program7int.dot
rake getConnectors program_num=7 print_external=1 | awk 'NR!=1 {print}' > Program7ext.dot
rake getConnectors program_num=7 print_internal=1 print_external=1 | awk 'NR!=1 {print}' > Program7.dot

rake getConnectors program_num=8 print_internal=1 | awk 'NR!=1 {print}' > Program8int.dot
rake getConnectors program_num=8 print_external=1 | awk 'NR!=1 {print}' > Program8ext.dot
rake getConnectors program_num=8 print_internal=1 print_external=1 | awk 'NR!=1 {print}' > Program8.dot

rake getConnectors program_num=9 print_internal=1 | awk 'NR!=1 {print}' > Program9int.dot
rake getConnectors program_num=9 print_external=1 | awk 'NR!=1 {print}' > Program9ext.dot
rake getConnectors program_num=9 print_internal=1 print_external=1 | awk 'NR!=1 {print}' > Program9.dot

rake getConnectors program_num=10 print_internal=1 | awk 'NR!=1 {print}' > Program10int.dot
rake getConnectors program_num=10 print_external=1 | awk 'NR!=1 {print}' > Program10ext.dot
rake getConnectors program_num=10 print_internal=1 print_external=1 | awk 'NR!=1 {print}' > Program10.dot

rake getConnectors program_num=11 print_internal=1 | awk 'NR!=1 {print}' > Program11int.dot
rake getConnectors program_num=11 print_external=1 | awk 'NR!=1 {print}' > Program11ext.dot
rake getConnectors program_num=11 print_internal=1 print_external=1 | awk 'NR!=1 {print}' > Program11.dot

#output graphs as png files
/Applications/GraphViz/Graphviz.app/Contents/MacOS/dot -Tpng -oProgram1.png Program1.dot 
/Applications/GraphViz/Graphviz.app/Contents/MacOS/dot -Tpng -oProgram1int.png Program1int.dot 
/Applications/GraphViz/Graphviz.app/Contents/MacOS/dot -Tpng -oProgram1ext.png Program1ext.dot 

/Applications/GraphViz/Graphviz.app/Contents/MacOS/dot -Tpng -oProgram2.png Program2.dot 
/Applications/GraphViz/Graphviz.app/Contents/MacOS/dot -Tpng -oProgram2int.png Program2int.dot 
/Applications/GraphViz/Graphviz.app/Contents/MacOS/dot -Tpng -oProgram2ext.png Program2ext.dot 

/Applications/GraphViz/Graphviz.app/Contents/MacOS/dot -Tpng -oProgram3.png Program3.dot 
/Applications/GraphViz/Graphviz.app/Contents/MacOS/dot -Tpng -oProgram3int.png Program3int.dot 
/Applications/GraphViz/Graphviz.app/Contents/MacOS/dot -Tpng -oProgram3ext.png Program3ext.dot 

/Applications/GraphViz/Graphviz.app/Contents/MacOS/dot -Tpng -oProgram4.png Program4.dot 
/Applications/GraphViz/Graphviz.app/Contents/MacOS/dot -Tpng -oProgram4int.png Program4int.dot 
/Applications/GraphViz/Graphviz.app/Contents/MacOS/dot -Tpng -oProgram4ext.png Program4ext.dot 

/Applications/GraphViz/Graphviz.app/Contents/MacOS/dot -Tpng -oProgram5.png Program5.dot 
/Applications/GraphViz/Graphviz.app/Contents/MacOS/dot -Tpng -oProgram5int.png Program5int.dot 
/Applications/GraphViz/Graphviz.app/Contents/MacOS/dot -Tpng -oProgram5ext.png Program5ext.dot 

/Applications/GraphViz/Graphviz.app/Contents/MacOS/dot -Tpng -oProgram6.png Program6.dot 
/Applications/GraphViz/Graphviz.app/Contents/MacOS/dot -Tpng -oProgram6int.png Program6int.dot 
/Applications/GraphViz/Graphviz.app/Contents/MacOS/dot -Tpng -oProgram6ext.png Program6ext.dot 

/Applications/GraphViz/Graphviz.app/Contents/MacOS/dot -Tpng -oProgram7.png Program7.dot 
/Applications/GraphViz/Graphviz.app/Contents/MacOS/dot -Tpng -oProgram7int.png Program7int.dot 
/Applications/GraphViz/Graphviz.app/Contents/MacOS/dot -Tpng -oProgram7ext.png Program7ext.dot 

/Applications/GraphViz/Graphviz.app/Contents/MacOS/dot -Tpng -oProgram8.png Program8.dot 
/Applications/GraphViz/Graphviz.app/Contents/MacOS/dot -Tpng -oProgram8int.png Program8int.dot 
/Applications/GraphViz/Graphviz.app/Contents/MacOS/dot -Tpng -oProgram8ext.png Program8ext.dot 

/Applications/GraphViz/Graphviz.app/Contents/MacOS/dot -Tpng -oProgram9.png Program9.dot 
/Applications/GraphViz/Graphviz.app/Contents/MacOS/dot -Tpng -oProgram9int.png Program9int.dot 
/Applications/GraphViz/Graphviz.app/Contents/MacOS/dot -Tpng -oProgram9ext.png Program9ext.dot 

/Applications/GraphViz/Graphviz.app/Contents/MacOS/dot -Tpng -oProgram10.png Program10.dot 
/Applications/GraphViz/Graphviz.app/Contents/MacOS/dot -Tpng -oProgram10int.png Program10int.dot 
/Applications/GraphViz/Graphviz.app/Contents/MacOS/dot -Tpng -oProgram10ext.png Program10ext.dot 

/Applications/GraphViz/Graphviz.app/Contents/MacOS/dot -Tpng -oProgram11.png Program11.dot 
/Applications/GraphViz/Graphviz.app/Contents/MacOS/dot -Tpng -oProgram11int.png Program11int.dot 
/Applications/GraphViz/Graphviz.app/Contents/MacOS/dot -Tpng -oProgram11ext.png Program11ext.dot 
