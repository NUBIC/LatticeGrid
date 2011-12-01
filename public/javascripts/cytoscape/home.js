$(function(){
    
  // id of Cytoscape Web container div
   var div_id = "content";

  // id of place to show the Flash loader info
var loader_div_id = "loader";

if( FlashDetect.versionAtLeast(MIN_FLASH_VERSION) ) {
	$("#"+loader_div_id).show();

	
   // init and draw
	vis = new org.cytoscapeweb.Visualization(div_id, OPTIONS);

	vis.ready(function(){
		setTimeout(function(){
			$("#"+loader_div_id).hide();
		}, DELAY_BEFORE_HIDING_LOADER);
		// following section by Karthik Singh, July 2011
				// add a listener for when nodes and edges are clicked
	  vis.addListener("click", "nodes", function(event) {
		  handle_click(event);
	  })
	  .addListener("click", "edges", function(event) {
		  handle_click(event);
	  });

			
	function handle_click(event) {
		var target = event.target;
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
		var text = event.target.data.tooltiptext;
		var id = event.target.data.tooltiptext.match(/(NetID|username|id|STU): ([^;: ]+)/)[2];
		return id;
	} 
	function get_target_prefix(event) {
		var text = event.target.data.tooltiptext;
		var id = event.target.data.tooltiptext.match(/(NetID|username|id|STU): /)[1];
		var prefix;
		if (id.search(/NetID|username/) == 0) {
			prefix = '/cytoscape/'
		} else if ( id.search(/STU/) == 0) {
			prefix = '/studies/'
		} else {
			prefix = '/awards/'
		}
		return prefix;
	} 
	function get_target_suffix() {
		var text = window.location.href.match(/cytoscape\/[^;:\/ ]+(.*)/)[1];
		var suffix = '';
		if (text.search(/awards/) > 0) {
			suffix = '/awards'
		} else if (text.search(/studies/) > 0) {
			suffix = '/studies'
		}
		return suffix;
	}
	
	function determine_current_netid() {
		var netID = window.location.href.match(/cytoscape\/([^;:\/ ]+)/)[1];
		return netID;
	}
});

//	    $.get("/file/example_graphs/sample2.graphml", function(data){
//		    OPTIONS.network = data;
// Gradient is very cool! Circles isn't bad either		    
//			vis.draw({network: data, layout: layout, visualStyle: GRAPH_STYLES["Gradient"]});
//			//vis.draw({network: data, layout: layout, visualStyle: GRAPH_STYLES["Circles"]});
//		})
	    
	    $.getJSON(cytoscapeGraphURL, function(data){
		    OPTIONS.network = data;
		    OPTIONS.layout = {name: "Radial", options: LAYOUTS["Radial"]};
		    OPTIONS.visualStyle = GRAPH_STYLES["Gradient"];
// Gradient is very cool! Circles isn't bad either		    
			vis.draw(OPTIONS);
			//cytoscapeLoaded();
			setItemCheckStatus("#nodeLabelsVisibleCheckbox",OPTIONS['nodeLabelsVisible']);
			setItemCheckStatus("#edgeLabelsVisibleCheckbox",OPTIONS['edgeLabelsVisible']);
			setSelectedLayout(OPTIONS.layout['name']);
			//vis.draw({network: data, layout: layout, visualStyle: GRAPH_STYLES["Circles"]});
		})
    }

});