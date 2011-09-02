/*
   MooWheel Class
   version 0.2
   Copyright (c) 2008 unwieldy studios
   http://www.unwieldy.net/moowheel/
   
   This library is licensed under an MIT-style license.
   
   Contributions by:
      - Augusto Becciu (http://www.tweetwheel.com)
*/


/*
 * Data:
 * var data = [
 *  { 'id': 1, 'text': "My name", 'imageUrl': "http://domain.com/image.jpg", 'connections': [1, 3, 5] },
 *  { .... },
 *  ....
 * ];
 *
 */

var goptions;
var gcanvas;
var gdata;
var gcontext;
var gwc;

var $defined = function(obj){
    return (obj != undefined);
};

var MooWheel = new Class({
   options: {
      type: 'default',
      center: {
         x: 100,
         y: 100
      },
      width: null,
      height: null,
      lines: {
         color: 'random',
         lineWidth: 2
      },
      imageSize: [24,24],
      radialMultiplier: 3.47,
      hover: true,
      hoverLines: {
         color: 'rgba(255,255,255,255)',
         lineWidth: 3
      },
      onItemClick: function(){}
   },
   
   initialize: function(data, ct, options) {
      this.data = data;
      this.radius = Math.round(this.options.radialMultiplier * this.data.length);
      this.setOptions(options);

      // calculate canvas height/width if necessary
      var hw;
      if (!(this.options.width && this.options.height)) {
        var l = 0;
        for (var i = 0; i < data.length; i++) {
          if (data[i]['text'].length > l)
            l = data[i]['text'].length;
        }
      
        hw = 2 * ((this.radius + (l * 8)) + this.options.imageSize[0]) + 12;
      }
     
      ct.empty();
      
      ct = $(ct);
      var canvas = new Element('canvas', {
        width:  (this.options.width ? this.options.width : hw) + 'px',
        height: (this.options.height ? this.options.height : hw) + 'px'
      });
      ct.adopt(canvas);
      
      if(typeof(G_vmlCanvasManager) != 'undefined') {
        canvas = $(G_vmlCanvasManager.initElement(canvas));
      }

      this.canvas = canvas;

      this.cx = canvas.getContext('2d');
      this.maxCount = 1;

      var canvasPos = this.canvas.getCoordinates();
      
      this.options.center = {x: canvasPos.width / 2, y: canvasPos.height / 2};
      if (this.radius < canvasPos.width / 3 || this.radius < canvasPos.height / 3) {
		this.radius = canvasPos.width / 3
	  }
     
 
      CanvasTextFunctions.enable(this.cx);
            
      if(this.options.hover) {
         this.hoverCanvas = new Element('canvas', {
            'styles': {
               position: 'absolute',
               left: canvasPos.left + 'px',
               top: canvasPos.top + 'px',
               zIndex: 9
            },
            
            width: canvasPos.width + 'px',
            height: canvasPos.height + 'px'
         });
        
         this.hoverCanvas.injectAfter(this.canvas);

         window.addEvent('resize', function() {
            var canvasPos = this.canvas.getCoordinates();
            
            this.hoverCanvas.setStyles({left: canvasPos.left + 'px', top: canvasPos.top + 'px'});
            this.hoverCanvas.width = canvasPos.width;
            this.hoverCanvas.height = canvasPos.height;
         }.bind(this));
  
         if(typeof(G_vmlCanvasManager) != 'undefined') {
             this.hoverCanvas = $(G_vmlCanvasManager.initElement(this.hoverCanvas));
         }
         // karthik singh added August 2011
		 this.hcx = this.hoverCanvas.getContext('2d');
		 CanvasTextFunctions.enable(this.hcx);
      }
      
      this.data.each(function(item) {
        item['connections'].each(function(subitem) {
            if($type(subitem) == 'array' && subitem[1] > this.maxCount)
              this.maxCount = subitem[1];
        }, this);
      }, this);
         
      this.draw();
   },
   
   // define each point on the wheel, including it's position and color
   setPoints: function() {
      this.points = {};
      this.bboxes = [];
      
      this.numDegrees = (360 / this.data.length);
      
      for (var i = 0, j = 0; j < this.data.length; i += this.numDegrees, j++) {
         if (this.data[j]['colors']) continue;

         var item = this.data[j];
         var color = {};
         var lineWidth = {};
         
         // choose a color for the item
         switch(this.options.type) {
            case 'heat':
               for (var q = 0; q < item['connections'].length; q++) {
	                  var is_arr = ($type(item['connections'][q]) == 'array');
	                  var the_id = (is_arr ? item['connections'][q][0] : item['connections'][q])
	                  var the_val = (is_arr && (parseInt(item['connections'][q][1]) == item['connections'][q][1])) ? parseInt(item['connections'][q][1]) : 2
                  color[$type(item['connections'][q]) == 'array' ? item['connections'][q][0] : item['connections'][q]] = ($type(item['connections'][q]) == 'array' ? this.getTemperature('heat', item['connections'][q][1] / this.maxCount) : this.getTemperature('heat', 1 / this.maxCount));
	                  lineWidth[the_id] = is_arr ? Math.floor(8 * (the_val/ this.maxCount)) : 2 ;
	                  lineWidth[the_id] = (lineWidth[the_id]< 1 ? 1 : lineWidth[the_id])
               }
               
               color['__default'] = (this.options.lines.color == 'random' ? "rgba(" + (Math.floor(Math.random() * 195) + 60) + "," + (Math.floor(Math.random() * 195) + 60) + "," + (Math.floor(Math.random() * 195) + 60) + ", 1)" : this.options.lines.color);
            break;
                        
            case 'cold':
               for (var q = 0; q < item['connections'].length; q++) {
                  color[$type(item['connections'][q]) == 'array' ? item['connections'][q][0] : item['connections'][q]] = ($type(item['connections'][q]) == 'array' ? this.getTemperature('cold', (this.maxCount - item['connections'][q][1]) / (this.maxCount - 1 <= 0 ? 1 : this.maxCount - 1)) : this.getTemperature('cold', 1));
               }
               
               color['__default'] = (this.options.lines.color == 'random' ? "rgba(" + (Math.floor(Math.random() * 195) + 60) + "," + (Math.floor(Math.random() * 195) + 60) + "," + (Math.floor(Math.random() * 195) + 60) + ", 1)" : this.options.lines.color);
            break;
            
            case 'default':
               if (this.options.lines.color == 'random')
                  color['__default'] = "rgba(" + (Math.floor(Math.random() * 195) + 60) + "," + (Math.floor(Math.random() * 195) + 60) + "," + (Math.floor(Math.random() * 195) + 60) + ", 1)";
               else
                  color['__default'] = this.options.lines.color;
            break;
         }

         this.data[j]['colors'] = color;
         this.data[j]['lineWidths'] = lineWidth;
      }
   },

   pc: function(x) {
      return Math.round(x/7) * 7;
   },

   // calculate the bounding box of particular text
   calcbbox: function(px, py, i, j) {
      px = Number(px.toFixed(2));
      py = Number(py.toFixed(2));
      i = Number(i.toFixed(2));

      // calculate hover bounding box
      var xc = this.options.center.x, yc = this.options.center.y;

      var m0 = (py - yc) / (px - xc);

      var pr3 = {
        x: px - Math.cos((i+90)*(Math.PI/180))*5,
        y: py - Math.sin((i+90)*(Math.PI/180))*5
      };
      var b3 = pr3.y - m0*pr3.x;
      var dr3;
      if (m0 == Infinity || m0 == -Infinity)
        dr3 = function(x,y) { return Math.abs((x-pr3.x)); };
      else
        dr3 = function(x,y) { return Math.abs(m0*x-y+b3)/Math.sqrt(Math.pow(m0,2)+1); };

      var txtlen = this.cx.measureText('sans','10',this.data[j]['text']);
      txtlen = Number(txtlen.toFixed(2));

      var pr4 = {
        x: px + Math.cos((i+90)*(Math.PI/180))*5,
        y: py + Math.sin((i+90)*(Math.PI/180))*5
      };
      var b4 = pr4.y - m0*pr4.x;
      var dr4;
      if (m0 == Infinity || m0 == -Infinity)
        dr4 = function(x,y) { return Math.abs((x-pr4.x)); };
      else
        dr4 = function(x,y) { return Math.abs(m0*x-y+b4)/Math.sqrt(Math.pow(m0,2)+1); };


      this.bboxes[j] = function(x,y) {

        if (i == 0 && (x-px) < 0)
          return false;
        else if (i > 0 && i < 90 && (x-px) < 0 && (y-py) < 0)
          return false;
        else if (i == 90 && (y-py) < 0)
          return false;
        else if (i > 90 && i < 180 && (x-px) > 0 && (y-py) < 0)
          return false;
        else if (i == 180 && (x-px) > 0)
          return false;
        else if (i > 180 && i < 270 && (x-px) > 0 && (y-py) > 0)
          return false;
        else if (i == 270 && (y-py) > 0)
          return false;
        else if (i > 270 && i < 360 && (x-px) < 0 && (y-py) > 0)
          return false;
              

        var d = Math.sqrt(Math.pow((x-px),2) + Math.pow((y-py),2));
        var d3 = dr3(x,y), d4 = dr4(x,y);

        if (d <= (txtlen+8) && d3 <= 10 && d4 <= 10)
          return true;

        return false;
      };
   },

   drawTheText: function(item, angle, text, hover) {
       //save the canvas
       this.cx.save();
       
       this.cx.translate(this.options.center.x, this.options.center.y);
       this.cx.rotate((angle > 90 && angle < 270 ? angle-180 : angle) * (Math.PI / 180));

       var txtSlice, imgSlice;
       if (angle > 90 && angle < 270) {
         txtSlice = -(this.radius + this.cx.measureText('sans','10',text) + 8);
         imgSlice = txtSlice - 30;
       } else {
         txtSlice = this.radius + 8;
         imgSlice = txtSlice+6+this.cx.measureText('sans','10',text);
       }
       if (hover) {
          this.cx.strokeStyle = 'rgb(10,0,30)';
       }
       this.cx.drawText('sans','10', txtSlice, this.cx.fontAscent('sans','10')/2,
           text);

       if (item['image'])
         this.cx.drawImage($(item['image']), imgSlice, -12, this.options.imageSize[0],
             this.options.imageSize[1]);
        //restore the canvas
        this.cx.restore();
    },
   
   // draw the points onto the canvas
   drawPoints: function() {
      for(var i = 0, j = 0; j < this.data.length; i += this.numDegrees, j++) {
            this.cx.beginPath();
            this.cx.fillStyle = this.cx.strokeStyle = this.data[j]['colors']['__default'];
            
            // solve for the dot location on the large circle
            var x = this.options.center.x + Math.cos(i * (Math.PI / 180)) * this.radius;
            var y = this.options.center.y + Math.sin(i * (Math.PI / 180)) * this.radius;
                                 
            // draw the colored dot
            this.cx.arc(x, y, 4, 0, Math.PI * 2, 0);
            this.cx.fill();
            this.cx.closePath();
          
            this.calcbbox(x, y, i, j); 

            if(!this.points[this.pc(x)])
               this.points[this.pc(x)] = {};
               
            this.points[this.pc(x)][this.pc(y)] = j;

            // draw the text
            this.drawTheText(this.data[j], i, this.data[j]['text']+'');
      }
   },

   // calculate a radian angle
   getAngle: function(idx) {
     return idx * (360 / this.data.length);
   },
   
   getItemIdxById: function(id) {
     if($type(id) == 'array') id = id[0];
     
     for (var i = 0, l = this.data.length; i < l; i++)
      if (this.data[i]['id'] == id)
         return i;
  
     return -1;
   },
   
   // draw the connection lines for a particular item
   drawConnection: function(i, hover) {
      var cx = hover ? this.hoverCanvas.getContext('2d') : this.cx;
      var item = this.data[i];
      var connections = [];
	  if ($defined(item['connections'])) { connections = item['connections'] }
      var angle = this.getAngle(i);
      
      // solve for the line starting point location on the large circle
      var x = this.options.center.x + Math.cos(angle * (Math.PI / 180)) * this.radius;
      var y = this.options.center.y + Math.sin(angle * (Math.PI / 180)) * this.radius;
      
      cx.lineWidth = hover ? this.options.hoverLines.lineWidth : 2;
      
      // draw the bezier curve
      // note: the control points of the curve are the radius / 2
      for(var j = 0; j < connections.length; j++) {
         var itemIdx = this.getItemIdxById(connections[j]);

         cx.strokeStyle = hover ? (item['colors'][connections[j][0]] ? item['colors'][connections[j][0]] : item['colors']['__default']).replace(/, \d\.?\d+?\)/, ',1)') :
                                  (item['colors'][connections[j][0]] ? item['colors'][connections[j][0]] : item['colors']['__default']);

         cx.lineWidth = item['lineWidths'][connections[j][0]] ? item['lineWidths'][connections[j][0]] : cx.lineWidth;
         cx.lineWidth = hover ? cx.lineWidth+2 : cx.lineWidth;
         cx.beginPath();
         cx.moveTo(x, y);
         rpos = this.getAngle(itemIdx);
         x2 = this.options.center.x + Math.cos(rpos * (Math.PI / 180)) * this.radius;
         y2 = this.options.center.y + Math.sin(rpos * (Math.PI / 180)) * this.radius;
         cp1x = this.options.center.x + Math.cos(angle * (Math.PI / 180)) * (this.radius / 1.5);
         cp1y = this.options.center.y + Math.sin(angle * (Math.PI / 180)) * (this.radius / 1.5);
         cp2x = this.options.center.x + Math.cos(rpos * (Math.PI / 180)) * (this.radius / 1.5);
         cp2y = this.options.center.y + Math.sin(rpos * (Math.PI / 180)) * (this.radius / 1.5);
         cx.bezierCurveTo(cp1x, cp1y, cp2x, cp2y, x2, y2);
         cx.stroke();
         cx.closePath();
      }
      
      if(hover) return;
      
      if(this.data[i+1]) {
         var self = this;
         setTimeout(function() { self.drawConnection(i+1); }, 10);
      } else {
         this.drawPoints();
      }
   },
   
   // draw the entire MooWheel
   draw: function() {
      if(this.data) {
         this.setPoints();
         this.drawConnection(0);
      }

      if(this.options.hover) {
         $(this.hoverCanvas).addEvent('mousemove', function(e) {
            e = new Event(e);
            
            var pos = $(this.hoverCanvas).getCoordinates();
           
            // convert page coordinates to canvas coordinates 
            var mpos = {x: (e.page.x - pos.left),
                        y: (e.page.y - pos.top)};

            var test = function(point) {
               var cpoint = {x:this.pc(point.x), y:this.pc(point.y)};

               if ($defined(this.points[cpoint.x]) && $defined(this.points[cpoint.x][cpoint.y]))
                  return this.points[cpoint.x][cpoint.y];

               for (var i = 0, l = this.bboxes.length; i < l; i++) {
                  var bbox = this.bboxes[i];
                  if (bbox(point.x,point.y) === true)
                    return i;
               }

               return false;

            }.bind(this);
            
            var conn = test(mpos);
            if(conn !== false) {
               if(this.lastMouseOver == conn)
                  return;
                   
 
               this.canvas.setStyle('opacity', '0.5');
               this.drawConnection(conn, true);
               angle = conn * this.numDegrees;
               this.drawTheText(this.data[conn], angle, this.data[conn]['text']+'');

               this.lastMouseOver = conn;
               this.hoverCanvas.setStyle('cursor', 'pointer');
            } else if($defined(this.lastMouseOver)) {
               var cx = this.hoverCanvas.getContext('2d');
               cx.clearRect(0, 0, pos.width, pos.height);
               cx.save();
   
               this.lastMouseOver = null;
               
               this.canvas.setStyle('opacity', '1.0'); 
               this.hoverCanvas.setStyle('cursor', 'default');
            }
         }.bind(this));

         $(this.hoverCanvas).addEvent('click', function(e) {
            if (! this.lastMouseOver) return false;
            this.options.onItemClick(this.data[this.lastMouseOver], e);
         }.bind(this));
      }
   },
   
   // get the brightness/color of a particular line when heat/cold maps are used
   getTemperature: function(type, percent) {
	  if (percent < 0.05) percent = 0.05;
	  if (percent > 1.0 ) percent = 1.0
      if(type == 'heat') {
         var p = {r: percent / 0.33, y: (percent - 0.33) / 0.33, w: (percent - 0.66) / 0.66};
   
         var r = Math.round(p.r * 255 > 255 ? 255 : p.r * 255);
         var y = Math.round(p.y * 255 > 255 ? 255 : p.y * 255);
         var w = Math.round(p.w * 255 > 255 ? 255 : p.w * 255);
         
         return 'rgba(' + (r < 0 ? 0 : r) + ',' + (y < 0 ? 0 : y) + ',' + (w < 0 ? 0 : w) + ', ' + (percent * 0.8 + 0.2) + ')';
      } else if(type == 'cold') {         
         var r = Math.round(percent * 255);
         var g = Math.round(130 + (percent * 125));
         
         return 'rgba(' + r + ',' + g + ',255, ' + (percent * 0.8 + 0.2) + ')';
      }
   }
});
MooWheel.implement(new Options);

// helper class for AJAX/JSON-based wheel information retrieval
MooWheel.Remote = new Class({
    
    Extends: MooWheel,

    initialize: function(data, ct, options) {

        if (options && options.url) {
			gcontext = this;
			goptions = options;
			gcanvas = ct;
            new Request.JSON({
              url: options.url,
              onComplete: function(wheelData) {
                  gdata = wheelData;

                  // hack to make this.parent work within callback
                  //arguments.callee._parent_ = this.initialize._parent_;
                  //alert(this.parent)
                  //this.parent(data, ct, options);
				setTimeout("startGraph()",10);
              
              }.bind(this)
            }).get();
        } else {
          this.parent(data, ct, options);
        }
    }
});

function startGraph() {
	// gcontext should have the 'this' before the Request JSON was called
	gwc = new MooWheel(gdata, gcanvas, goptions);
}

