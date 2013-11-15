var init = function() {

    var json = {
        id: "root",
        name: "root",
        data: {},
        children: []
    };

    var canvas = new Canvas("mycanvas", {
        injectInto: "infovis",
        width: 900,
        height: 500,
        backgroundColor: "#222"
    });

    var st= new ST(canvas, {
      levelsToShow: 1,
      Node: {
        overridable: true,
        color: "#00b"
      },
      Edge: {
        type: "bezier",
        overridable: true,
        color: "#00b"
      },
      onCreateLabel: function(label, node) {
          label.id = node.id;
          label.innerHTML = node.name;
          label.onclick = function() {
              st.onClick(node.id);
          };
      },
      onBeforePlotNode: function(node) {
          if (node.selected) {
              node.data.$color = "#ff7";
          } else {
              delete(node.data.$color);
          }
      },
      onBeforePlotLine: function(adj) {
          if (adj.nodeFrom.selected && adj.nodeTo.selected) {
              adj.data.$color = "#eed";
              adj.data.$lineWidth = 3;
          } else {
              delete(adj.data.$color)
              delete(adj.data.$lineWidth)
          }
      },
      request: function(nodeId, level, onComplete) {
          var url = "/dirs/" + nodeId + ".json";
          new Ajax.Request(url, {
              method: "GET",
              onSuccess: function(transport) {
                  onComplete.onComplete(nodeId, transport.responseJSON);
              },
              onFailure: function(transport) {
                  alert("wtf?");
              }
          });
      }
    });
    st.loadJSON(json);
    st.compute();
    st.geom.translate(new Complex(-200, 0), "startPos");
    st.onClick(st.root);

    $("switch").observe("change", function(evt) {
        var elem = evt.element();
        var position = $F(elem);
        elem.disable();
        st.switchPosition(position, {
            onComplete: function() {elem.enable();}
        });
    });
};
