(function() {
  function Tree(x, y, r, b) {
    this.x = x;
    this.y = y;
    this.r = r;
    this.b = b;
    this.children = null;
  }

  var minBoxSize = 1;

  function makeTree(shape, x, y, r, b) {
    if (contains(shape, x, y, r, b)) {
      return new Tree(x, y, r, b);
    } else if (intersects(shape, x, y, r, b)){
      var cx = (x + r) >> 1,
          cy = (y + b) >> 1,
          tree = new Tree(x, y, r, b);
      if (r - x > minBoxSize || b - y > minBoxSize) {
        var children = [],
            c0 = makeTree(shape,  x,  y, cx, cy),
            c1 = makeTree(shape, cx,  y,  r, cy),
            c2 = makeTree(shape,  x, cy, cx,  b),
            c3 = makeTree(shape, cx, cy,  r,  b);
        if (c0) children.push(c0);
        if (c1) children.push(c1);
        if (c2) children.push(c2);
        if (c3) children.push(c3);
        if (children.length) tree.children = children;
      }
      return tree;
    }
    return null;
  }

  function contains(shape, x, y, r, b) {
    if (x < shape.x || y < shape.y || r >= shape.r || b >= shape.b) return false;
    x -= shape.x;
    y -= shape.y;
    r -= shape.x;
    b -= shape.y;
    var w = shape.r - shape.x,
        sprite = shape.sprite;
    for (var j=y; j<b; j++) {
      for (var i=x; i<r; i++) if (!sprite[j * w + i]) return false;
    }
    return true;
  }

  function intersects(shape, x, y, r, b) {
    x = Math.max(0, x - shape.x);
    y = Math.max(0, y - shape.y);
    r = Math.min(shape.r, r) - shape.x;
    b = Math.min(shape.b, b) - shape.y;
    var w = shape.r - shape.x,
        sprite = shape.sprite;
    for (var j=y; j<b; j++) {
      for (var i=x; i<r; i++) if (sprite[j * w + i]) return true;
    }
    return false;
  }

  function overlaps(tree, otherTree, aox, aoy, box, boy) {
    if (rectCollide(tree, otherTree, aox, aoy, box, boy)) {
      if (tree.children == null) {
        if (otherTree.children == null) return true;
        else for (var i=0, n=otherTree.children.length; i<n; i++) {
          if (overlaps(tree, otherTree.children[i], aox, aoy, box, boy)) return true;
        }
      } else for (var i=0, n=tree.children.length; i<n; i++) {
        if (overlaps(otherTree, tree.children[i], box, boy, aox, aoy)) return true;
      }
    }
    return false;
  }

  function rectCollide(a, b, aox, aoy, box, boy) {
    return aoy + a.b > boy + b.y
        && aoy + a.y < boy + b.b
        && aox + a.r > box + b.x
        && aox + a.x < box + b.r;
  }

  var w = 960,
      h = 270,
      p = 5;

  var canvas = document.createElement("canvas");
  canvas.width = 1;
  canvas.height = 1;
  var ratio = Math.sqrt(canvas.getContext("2d").getImageData(0, 0, 1, 1).data.length >> 2);
  canvas.width = 160;
  canvas.height = 210;
  var c = canvas.getContext("2d");
  c.strokeStyle = "#f00";

  var vis = d3.select("#bbtree").append("svg")
      .attr("width", w)
      .attr("height", h)
      .attr("pointer-events", "all")
    .append("g")
      .attr("transform", "translate(5,5)");

  var glyphs = d3.range(2).map(function(d, i) {
    d += "";
    return {
      text: d,
      code: d.charCodeAt(0),
      tree: glyphTree(d),
      position: [i * 160, 30]
    };
  });

  update();

  function glyphTree(d) {
    return makeTree({sprite: sprite(c, d, 180, 150, 150, 200), x: 0, y: 0, r: 150, b: 200}, 0, 0, 150, 200);
  }

  function update() {
    var g = vis.selectAll("g")
        .data(glyphs);
    g.enter().append("g")
        .attr("transform", function(d) { return "translate(" + d.position + ")"; })
        .on("click", function(d) {
          d.code = 32 + ((d.code - 32 + 1) % (0x7f - 32) || 9699);
          d.text = String.fromCharCode(d.code);
          d.tree = glyphTree(d.text);
          update();
        })
        .call(d3.behavior.drag()
          .origin(function(d) { return {x: d.position[0], y: d.position[1]}; })
          .on("drag", function(d) {
            d.position = [Math.max(0, Math.min(w - canvas.width, d3.event.x)), Math.max(0, Math.min(h - canvas.height, d3.event.y))];
            d3.select(this)
                .attr("transform", function(d) { return "translate(" + d.position + ")"; });
            collide();
          })
        )
      .append("text")
        .attr("x", 150 / 2)
        .attr("y", 150)
        .attr("text-anchor", "middle")
        .style("font-size", "180px")
        .style("font-family", "serif")
        .attr("pointer-events", "all")
    g.select("text").text(function(d) { return d.text; });

    var rect = g.selectAll("rect")
        .data(function(d) { return flatten(d.tree); });
    rect.enter().append("rect");
    rect.exit().remove();
    rect.attr("width", function(d) { return d.r - d.x; })
        .attr("height", function(d) { return d.b - d.y; })
        .attr("x", function(d) { return d.x; })
        .attr("y", function(d) { return d.y; })
        .style("stroke-width", function(d) { return 2 - d.depth / 2; });
  }

  function collide() {
    var a = glyphs[0],
        b = glyphs[1];
    vis.classed("collide", overlaps(a.tree, b.tree, a.position[0], a.position[1], b.position[0], b.position[1]));
  }

  function sprite(c, text, s, dy, w, h) {
    c.clearRect(0, 0, w + 2 * p, h + 2 * p);
    c.save();
    c.fillStyle = "#000";
    c.textAlign = "center";
    c.font = ~~(s / ratio) + "px serif";
    c.translate(p + (w >> 1) / ratio, p + dy / ratio);
    c.fillText(text, 0, 0);
    c.restore();
    var pixels = c.getImageData(p, p, w / ratio, h / ratio).data,
        sprite = [];
    for (var i = w * h; --i >= 0;) sprite[i] = pixels[(i << 2) + 3];
    return sprite;
  }

  function flatten(root) {
    var nodes = [];

    recurse(root, 0);

    return nodes;

    function recurse(node, depth) {
      node.depth = depth;
      if (node.children) node.children.forEach(function(d) { recurse(d, depth + 1); });
      nodes.push(node);
    }