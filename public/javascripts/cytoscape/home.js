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
			var netID = extract_netid(event);
			var orig_investigator = determine_current_netid();
			var url = '/cytoscape/' + netID;
			if (netID == orig_investigator){
			  url = '/investigators/' + netID + '/show/1';
			}
			window.location = url;
		}
	}
	
	function extract_netid(event) {
		var netID = event.target.data.tooltiptext.match(/NetID: ([^;: ]+)/)[1];
		return netID;
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