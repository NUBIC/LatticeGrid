$(function(){

  // id of Cytoscape Web container div
   var div_id = "content";

  // id of place to show the Flash loader info
  var loader_div_id = "loader";

  if( FlashDetect.versionAtLeast(MIN_FLASH_VERSION) ) {
    $("#"+loader_div_id).show();

    // init and draw
    vis = new org.cytoscapeweb.Visualization(div_id, OPTIONS);

    var props = {
      labelFontSize: 16,
      labelFontColor: "#ff0000",
      labelFontWeight: "bold"
    };

      // Create a mapper:
    var colorMapper = {
      attrName: "element_type",
      entries: [ { attrValue: "Award", value: "#ff5555" },
                 { attrValue: "Publication", value: "#55ff55" },
                 { attrValue: "Org", value: "#ffff55" },
                 { attrValue: "Investigator", value: "#55ffff" },
                 { attrValue: "Study", value: "#ffff55" } ]
    };

    // Set the mapper to a Visual Style;
    var element_style = {
      nodes: {
        color: { discreteMapper: colorMapper }
      }
    };

    // 1. First, create a function and add it to the Visualization object.
    vis["customEdgeColor"] = function (data) {
      var value = data["element_type"];
      var color = data["color"];
      switch(value) {
        case "Award":
          color = "#ff5555"
          break;
        case "Publication":
          color = "#55ff55"
          break;
        case "Org":
          color = "#ffff55"
          break;
        case "Investigator":
          color = "#55ffff"
          break;
        case "Study":
          color = "#ffff55"
          break;
      }
      return color;
    };

    // 2. Now create a new visual style (or get the current one) and register
    //    the custom mapper to one or more visual properties:
    //  element_style = vis.visualStyle();
    //  element_style.edges.color = { customMapper: { functionName: "customEdgeColor" } },
    // Set the new style to the Visualization:
    //    vis.visualStyle().edges.color = { customMapper: { functionName: "customEdgeColor" } };

    // 3. Finally set the visual style again:
    //  vis.visualStyle(element_style);

    vis.ready(function() {
      setTimeout(function() {
        $("#"+loader_div_id).hide();
      }, DELAY_BEFORE_HIDING_LOADER);
      // following section by Karthik Singh, July 2011
      // add a listener for when nodes and edges are clicked
      vis.addListener("click", "nodes", function(event) {
        handle_click(event);
      })
      vis.addListener("select", "nodes", function(event) {
        handle_select(event);
      })
      vis.addListener("deselect", "nodes", function(event) {
        handle_select(event);
      })
      vis.addListener("click", "edges", function(event) {
        handle_click(event);
      });

      function handle_select(event) {
        var target = event.target;
        var selected = vis.selected();
        var msg = "event.group = " + event.group + "\n";
        var bypass = { nodes: { }, edges: { } };
        vis.visualStyleBypass(null);
        // Change the labels of selected nodes and edges:
        for (var i=0; i < selected.length; i++) {
            var obj = selected[i];

            // obj.group is either "nodes" or "edges"...
            bypass[obj.group][obj.data.id] = props;
        }

        vis.visualStyleBypass(bypass);
      }

      function handle_click(event) {
        var target = event.target;
        var selected = vis.selected();
        var msg = "event.group = " + event.group + "\n";
        for (var i in target.data) {
          var variable_name = i;
          var variable_value = target.data[i];
          msg += "event.target.data." + variable_name + " = " + variable_value + "\n";
          var target_id = extract_id(event);
          var prefix = get_target_prefix(event)
          var suffix = "";
          if (prefix.search(/cytoscape/i) >=0 ) {
            suffix = get_target_suffix(event);
          }
          var orig_investigator = determine_current_netid();
          var url = prefix + target_id + suffix;
          if (target_id == orig_investigator){
            url = '/investigators/' + target_id + '/show/1';
          }
          window.location = url;
        }

      }

      function extract_id(event) {
        var id = '';
        if (event.target.data.tooltiptext.search(/(NetID|username|id|STU): /) >= 0) {
          id = event.target.data.tooltiptext.match(/(NetID|username|id|STU): ([^;: ]+)/)[2];
        }
        return id;
      }

      function get_target_prefix(event) {
        var prefix = "";
        if (event.target.data.tooltiptext.search(/(NetID|username|id|STU): /) >= 0) {
          var id = event.target.data.tooltiptext.match(/(NetID|username|id|STU): /)[1];
          if (id.search(/NetID|username/) == 0) {
            prefix = '/cytoscape/'
          } else if ( id.search(/STU/) == 0) {
            prefix = '/studies/'
          } else {
            prefix = '/awards/'
          }
        }
        return prefix;
      }

      function get_target_suffix() {
        var suffix = '';
        if ( window.location.href.search(/cytoscape\/[^;:\/ ]+/) >= 0 ) {
          var text = window.location.href.match(/cytoscape\/[^;:\/ ]+(.*)/)[1];
          if (text.search(/awards/) > 0) {
            suffix = '/awards'
          } else if (text.search(/studies/) > 0) {
            suffix = '/studies'
          }
        }
        return suffix;
      }

      function determine_current_netid() {
        var netID = "";
        if ( window.location.href.search(/cytoscape\/[^;:\/ ]+/)  >= 0) {
          netID =window.location.href.match(/cytoscape\/([^;:\/ ]+)/)[1];
        }
        return netID;
      }
    });

    $.getJSON(cytoscapeGraphURL, function(data){
      OPTIONS.network = data;
      OPTIONS.layout = {name: "Radial", options: LAYOUTS["Radial"]};
      OPTIONS.visualStyle = GRAPH_STYLES["Gradient"];
      // Gradient is very cool! Circles isn't bad either
      // vis.draw({network: data, layout: layout, visualStyle: GRAPH_STYLES["Circles"]});
      vis.draw(OPTIONS);
      // cytoscapeLoaded();
      setItemCheckStatus("#nodeLabelsVisibleCheckbox",OPTIONS['nodeLabelsVisible']);
      setItemCheckStatus("#edgeLabelsVisibleCheckbox",OPTIONS['edgeLabelsVisible']);
      setSelectedLayout(OPTIONS.layout['name']);
      if (typeof callWhenLoaded === "function") {
        callWhenLoaded();
      }
    });
  }

});