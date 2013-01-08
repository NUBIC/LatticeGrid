/*
  This file is part of Cytoscape Web.
  Copyright (c) 2009, The Cytoscape Consortium (www.cytoscape.org)

  The Cytoscape Consortium is:
    - Agilent Technologies
    - Institut Pasteur
    - Institute for Systems Biology
    - Memorial Sloan-Kettering Cancer Center
    - National Center for Integrative Biomedical Informatics
    - Unilever
    - University of California San Diego
    - University of California San Francisco
    - University of Toronto

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
*/

/*
 * Just some visual style samples...
 */
$(function(){

    window.DELAY_BEFORE_HIDING_LOADER = 200; // otherwise, you see the cytoweb fade in from grey
    window.MIN_FLASH_VERSION = 10;


	window.GRAPH_STYLES = { };
	window.LAYOUTS = { };
	window.LAYOUT_NAMES = {};
    window.OPTIONS = {};

    OPTIONS = {
        panZoomControlVisible: true,
		edgesMerged: false,
		nodeLabelsVisible: true,
		edgeLabelsVisible: true,
		nodeTooltipsEnabled: true,
		edgeTooltipsEnabled: true,
		swfPath: swfPath,
		flashInstallerPath: flashInstallerPath
    };

    LAYOUT_NAMES["ForceDirected"] = "Force Directed";
    LAYOUT_NAMES["Circle"] = "Circle";
    LAYOUT_NAMES["Radial"] = "Radial";
    LAYOUT_NAMES["Tree"] = "Tree";
	// layout options:
	//LAYOUTS["ForceDirected"] = { angleWidth: 180, radius: 80, fitToScreen: false, gravitation: -5000, mass: 3, tension: 0.15, restLength: "auto", drag: 0.4, minDistance: 10, maxDistance: 1000,  weightAttr: "", weightNorm: ["linear","invlinear","log"], iterations: 400, maxTime: 30000, autoStabilize: true };
	//LAYOUTS["ForceDirected"] = { fitToScreen: false, gravitation: -1000, mass: 40, tension: 2, restLength: 15, drag: 0.4, minDistance: 5, maxDistance: 100,  weightAttr: "weight", weightNorm: "log", iterations: 400, maxTime: 10000, autoStabilize: true, seed: 500 };
	LAYOUTS["ForceDirected"] = { fitToScreen: false, gravitation: -2000, mass: 30, tension: 0.30, restLength: 25, drag: 0.4, minDistance: 5, maxDistance: 100,  weightAttr: "weight", weightNorm: "log", iterations: 400, maxTime: 10000, autoStabilize: true, seed: 500 };
    LAYOUTS["Circle"] = { angleWidth: 360, tree: false };
    LAYOUTS["Radial"] = { radius: 300, angleWidth: 360 };
    //LAYOUTS["Tree"] = { orientation: ["topToBottom","bottomToTop","leftToRight","rightToLeft"], depthSpace: 50, breadthSpace: 30, subtreeSpace: 5 };
    LAYOUTS["Tree"] = { orientation: "leftToRight", depthSpace: 50, breadthSpace: 30, subtreeSpace: 5 };
	

	var elementColorMapper = {
	        attrName: "element_type",
	        entries: [ { attrValue: "Award", value: "#1D1" },
	                   { attrValue: "Publication", value: "#22F" },
	                   { attrValue: "Abstract", value: "#22F" },
	                   { attrValue: "Org", value: "#AAA" },
	                   { attrValue: "Investigator", value: "#664" },
	                   { attrValue: "Study", value: "#E22" } ]
	};
	
	/*---- DEFAULT -----------------------------------------------------------------------------------*/
	
	GRAPH_STYLES["Default"] = { };
	
	/*---- SIMPLE ------------------------------------------------------------------------------------*/
	
	GRAPH_STYLES["Cytoscape"] = {
			global: {
				backgroundColor: "#ccccff",
				selectionLineColor: "#f6222b",
				selectionLineOpacity: 0.8,
				selectionLineWidth: 1,
				selectionFillOpacity: 0
			},
			nodes: {
				size: 20,
				color: "#ff9999",
				borderColor: "#666666",
				borderWidth: 1.5,
				opacity: 1,
				labelFontSize: 12,
				labelHorizontalAnchor: "center",
				labelGlowOpacity: 0,
				selectionOpacity: 1,
				selectionColor: "#ffff00",
				selectionBorderWidth: 1.5,
				selectionGlowOpacity: 0
			},
			edges: {
				color: "#0000ff",
				width: 1.5,
				mergeWidth: 1.5,
				opacity: 1,
				selectionColor: "#f6222b",
				selectionOpacity: 1,
				selectionGlowOpacity: 0
			}
	};
	
	/*---- CIRCLES -----------------------------------------------------------------------------------*/
	
	var nodeColorMapper = {
			attrName: "source",
			entries: [ { attrValue: "true",  value: "#838fa6" },
			           { attrValue: "false", value: "#fdfdfa" } ]
	};
	var edgeColorMapper = {
			attrName: "network",
			entries: [ { attrValue: "2",  value: "#9e7ba5" },
			           { attrValue: "14", value: "#717cff" },
			           { attrValue: "15", value: "#73c6cd" },
			           { attrValue: "16", value: "#92d17b" },
			           { attrValue: "24", value: "#c67983" },
			           { attrValue: "25", value: "#e4e870" } ]
	};
	
	GRAPH_STYLES["Circles"] = {
			global: {
				backgroundColor: "#fafafa",
				tooltipDelay: 400
			},
			nodes: {
				shape: "ELLIPSE",
				color: { defaultValue: "#fbfbfb", discreteMapper: nodeColorMapper },
				opacity: 1,
				size: { defaultValue: 12, continuousMapper: { attrName: "weight", minValue: 12, maxValue: 36 } },
				borderColor: "#000000",
				tooltipText: "<b>${label}</b> [weight: ${weight}]",
				tooltipFontColor: {
					defaultValue: "#333333",
					discreteMapper: {
						attrName: "source",
						entries: [ { attrValue: "true",  value: "#ffffff" },
						           { attrValue: "false", value: "#333333" } ]
					}
				},
				tooltipBackgroundColor: { defaultValue: "fafafa", discreteMapper: nodeColorMapper },
				labelHorizontalAnchor: "left",
				selectionBorderColor: "#cccc00",
				selectionBorderWidth: 2,
				hoverGlowColor: "#aae6ff",
				hoverGlowOpacity: 0.6,
				labelGlowColor: "#ffffff",
	            labelGlowOpacity: 1,
	            labelGlowBlur: 2,
	            labelGlowStrength: 20
			},
			edges: {
				color: { defaultValue: "#999999", discreteMapper: edgeColorMapper },
				width: { defaultValue: 1, continuousMapper: { attrName: "weight", minValue: 1, maxValue: 4 } },
				mergeWidth: { defaultValue: 1, continuousMapper: { attrName: "weight", minValue: 1, maxValue: 4 } },
				opacity: 1,
				label: { passthroughMapper: { attrName: "id" } },
				labelFontSize: 10,
	            labelFontColor: { defaultValue: "#333333", discreteMapper: edgeColorMapper },
	            labelFontWeight: "bold",
				tooltipText: "<b>weight:</b> ${weight}",
				mergeTooltipText: "<b>weight:</b> ${weight}",
				tooltipFontColor: "#000000",
				tooltipBackgroundColor: { defaultValue: "#fafafa", discreteMapper: edgeColorMapper },
				tooltipBorderColor: { defaultValue: "#fafafa", discreteMapper: edgeColorMapper },
	            labelGlowOpacity: 1,
				curvature: 58
			}
	};
	
	/*---- RECTANGLES --------------------------------------------------------------------------------*/
	
	GRAPH_STYLES["Rectangles"] = {
			global: {
				backgroundColor: "#D6E9F8"
			},
			nodes: {
				shape: "RECTANGLE",
				color: "#fefefe",
				borderColor:"#374A70",
				labelFontColor: "#374A70",
				labelHorizontalAnchor: "center",
				labelVerticalAnchor: "bottom",
				labelGlowColor: "#ffffff",
	            labelGlowOpacity: 0,
	            labelGlowBlur: 2,
	            labelGlowStrength: 20,
				selectionGlowOpacity: 0,
				selectionColor: "#ffff00",
				tooltipBackgroundColor: "#ffffff",
				tooltipBorderColor: "#374A70",
				tooltipFontColor: "#374A70"
			},
			edges: {
				color: "#374A70",
				mergeColor: "#ffffff",
				mergeOpacity: { defaultValue: 0.2, continuousMapper: { attrName: "weight", minValue: 0.2, maxValue: 1 } },
				width: 3,
				mergeWidth: 4,
				sourceArrowShape: "circle",
				targetArrowShape: "diamond",
				tooltipBackgroundColor: "#ffffff",
				tooltipBorderColor: "#374A70",
				tooltipFontColor: "#374A70",
				selectionGlowOpacity: 0,
				selectionColor: "#ff0000",
				curvature: 32
			}
	};
	
	/*---- TRIANGLES ---------------------------------------------------------------------------------*/
	
	GRAPH_STYLES["Triangles"] = {
			global: {
				backgroundColor: "#f5f5f5"
			},
			nodes: {
				shape: "TRIANGLE",
				color: "#a5a5a5",
				borderColor: "#999999",
				opacity: 1,
				label: "NODE",
				labelFontName: "_serif",
				labelFontSize: 14,
				labelHorizontalAnchor: "right",
				labelGlowOpacity: 0,
				selectionGlowOpacity: 0,
				selectionColor: "#ff0000",
				hoverBorderWidth: 2,
				hoverBorderColor: "#000000"
			},
			edges: {
				opacity: 1,
				color: { defaultValue: "#999999", discreteMapper: edgeColorMapper },
				width: 2,
				mergeWidth: 2,
				label: { passthroughMapper: { attrName: "weight" } },
				labelFontColor: { defaultValue: "#333333", discreteMapper: edgeColorMapper },
				labelFontSize: 12,
				selectionGlowOpacity: 0,
				selectionColor: "#ff0000"
			}
	};
	
	/*---- DIAMONDS ----------------------------------------------------------------------------------*/
	
	GRAPH_STYLES["Diamonds"] = {
			global: {
				backgroundColor: "#000033"
			},
			nodes: {
				shape: "DIAMOND",
				color: "#6666ee",
				borderColor: "#eeeeff",
				labelFontName: "_typewriter",
				labelFontColor: "#f5f5ff",
				labelFontSize: 14,
				labelHorizontalAnchor: "center",
				labelVerticalAnchor: "top",
				labelGlowOpacity: 0,
				selectionGlowOpacity: 0,
				selectionColor: "#ffce81"
			},
			edges: {
				color: { defaultValue: "#999999", discreteMapper: edgeColorMapper },
				width: 2,
				selectionGlowOpacity: 0,
				selectionColor: "#ffce81"
			}
	};
	
	/*---- GRADIENT ----------------------------------------------------------------------------------*/
	
	GRAPH_STYLES["Gradient"] = {
		global: {
			backgroundColor: "#fafafa",
			tooltipDelay: 400
		},
			nodes: {
				opacity: 1,
				//width: { continuousMapper: { attrName: "weight", minValue: 5, maxValue: 35, minAttrValue: 10, maxAttrValue: 200 } },
				//height: { continuousMapper: { attrName: "weight", minValue: 5, maxValue: 35, minAttrValue: 10, maxAttrValue: 200 } },
				size: { continuousMapper: { attrName: "weight", minValue: 10, maxValue: 35, minAttrValue: 100, maxAttrValue: 1500 } },
				color: { continuousMapper: { attrName: "weight", minValue: "#669966", maxValue: "#99ff00", minAttrValue: 10, maxAttrValue: 1500 } },
				borderWidth: { defaultValue: 1, continuousMapper: { attrName: "weight", minValue: 1, maxValue: 6, minAttrValue: 10, maxAttrValue: 1500 } },
				borderColor: { continuousMapper: { attrName: "weight", minValue: "#225588", maxValue: "#003366" } },
				shape: {
					defaultValue: "ELLIPSE",
					discreteMapper: {
						attrName: "depth",
						entries: [ { attrValue: 0, value: "OCTAGON"},
						           { attrValue: 1, value: "ELLIPSE"},
						           { attrValue: 2, value: "OCTAGON"} ]
					}
				},
				labelFontSize: { continuousMapper: { attrName: "weight", minValue: 12, maxValue: 18 } },
				labelFontColor: { continuousMapper: { attrName: "weight", minValue: "#506070", maxValue: "#000", minAttrValue: 100, maxAttrValue: 3000 } },
				labelVerticalAnchor: "middle",
				labelFontWeight: "bold",
				labelHorizontalAnchor: {
					defaultValue: "left",
					discreteMapper: {
						attrName: "source",
						entries: [ { attrValue: "true",  value: "right" },
						           { attrValue: "false", value: "left" } ]
					}
				},
				labelGlowOpacity: 0.6,
				labelGlowBlur: 6,
				labelGlowStrength: 200,
				tooltipText: "<b>${label}</b><br/>${tooltiptext}",
				tooltipFontColor: {
					defaultValue: "#191970",
					discreteMapper: {
						attrName: "source",
						entries: [ { attrValue: "true",  value: "#191970" },
						           { attrValue: "false", value: "#333333" } ]
					}
				},
				tooltipFontSize: 12,
				tooltipBackgroundColor: { defaultValue: "#f0f0f0", discreteMapper: nodeColorMapper },
				selectionGlowColor: "#ff0000"
			},
			edges: {
				opacity: { continuousMapper: { attrName: "weight", minValue: 0.3, maxValue: 1 } },
//				color: { continuousMapper: { attrName: "weight", minValue: "#aaaaaa", maxValue: "#333333" } },
				color: { defaultValue: "#999999", discreteMapper: elementColorMapper },
				width: { defaultValue: 1, continuousMapper: { attrName: "weight", minValue: 1, maxValue: 8, minAttrValue: 5, maxAttrValue: 150 } },
				mergeWidth: { defaultValue: 1, continuousMapper: { attrName: "weight", minValue: 1, maxValue: 6 } },
				labelFontSize: 14,
				labelFontColor: "#000000",
				labelFontName: "Arial",
				labelGlowOpacity: 0.7,
				labelGlowBlur: 6,
				labelGlowStrength: 200,
				tooltipText: "${tooltiptext}",
				mergeTooltipText: "${tooltiptext}",
				tooltipFontColor: "#006",
				tooltipFontSize: 10,
				tooltipBackgroundColor: { defaultValue: "#f0f0f0", discreteMapper: edgeColorMapper },
				tooltipBorderColor: { defaultValue: "#fafafa", discreteMapper: edgeColorMapper },
				selectionGlowColor: "#ff0000",
				sourceArrowShape: "none",
				targetArrowShape: "none"
			}
	};
	
	/*---- SHAPES ------------------------------------------------------------------------------------*/
	
	var arrowColors = [ { attrValue: "T",  value: "#33cc33" },
			            { attrValue: "delta", value: "#ff0000" },
			            { attrValue: "diamond", value: "#aaaa00" },
			            { attrValue: "circle", value: "#00ff00" } ];
	var nodeImages = [ { attrValue: "ELLIPSE",  value: "proxy_googlechart/cht%3Dp3%26chd%3Dt%3A60%2C40%26chs%3D250x100%26chl%3DHello%7CWorld" },
	               { attrValue: "OCTAGON", value: "proxy_googlechart/chxt=x,y&chs=300x300&cht=r&chco=FF0000&chd=t:63,64,67,73,77,81,85,86,85,81,74,67,63&chls=2,4,0&chm=B,FF000080,0,0,0" },
	               { attrValue: "RECTANGLE", value: "proxy_googlechart/cht%3Dp3%26chd%3Dt%3A60%2C40%26chs%3D250x100%26chl%3DHello%7CWorld" },
	               { attrValue: "ROUNDRECT", value: "proxy_googlechart/chxr%3D0%2C0%2C160%26chxt%3Dx%26chbh%3Da%26chs%3D250x250%26cht%3Dbhs%26chco%3D4D89F9%2CC6D9FD%26chds%3D0%2C160%2C0%2C160%26chd%3Dt%3A10%2C50%2C60%2C80%2C40%2C60%2C30%7C50%2C60%2C100%2C40%2C30%2C40%2C30" } ];
	
	GRAPH_STYLES["Shapes"] = {
			nodes: {
				size: 32,
				selectionColor: "#aaaaff",
				selectionOpacity: 1,
				hoverOpacity: 1,
        		image: {
					discreteMapper:  {
						attrName: "shape",
						entries: nodeImages
					}
				},
				shape: { passthroughMapper: { attrName: "shape" } }
			},
			edges: {
				width: { defaultValue: 1, continuousMapper: { attrName: "weight", minValue: 1, maxValue: 8 } },
				color: "#aaaaff",
				style: { defaultValue: "SOLID", passthroughMapper: { attrName: "lineStyle" } },
				mergeWidth: { defaultValue: 2, continuousMapper: { attrName: "weight", minValue: 2, maxValue: 8 } },
				mergeColor: { defaultValue: "#0000ff", continuousMapper: { attrName: "weight", minValue: "#0000ff", maxValue: "#00ff00" } },
				mergeOpacity: 0.6,
				sourceArrowShape: { passthroughMapper: { attrName: "sourceArrowShape" } },
				sourceArrowColor: "#6666ff",
				targetArrowShape: { passthroughMapper: { attrName: "targetArrowShape" } },
				targetArrowColor: {
					defaultValue: null,
					discreteMapper:  {
						attrName: "targetArrowShape",
						entries: arrowColors
					}
				},
				curvature: 36
			}
	};
	
	/*---- NODELESS ----------------------------------------------------------------------------------*/
	
	GRAPH_STYLES["Green Phosphorus"] = {
			global: {
				backgroundColor: "#000000",
				selectionLineColor: "#00aa00",
				selectionFillColor: "#006600"
			},
			nodes: {
				size: 1,
				opacity: 1,
				color: "#000000",
				borderColor: "#000000",
				labelFontSize: 12,
				labelFontColor: "#00ff00",
				labelHorizontalAnchor: "center",
				labelVerticalAnchor: "middle",
				labelFontWeight: {
					defaultValue: "normal",
					discreteMapper: {
						attrName: "source",
						entries: [ { attrValue: "true",  value: "bold" },
						           { attrValue: "false", value: "normal" } ]
					}
				},
				labelFontSize: {
					defaultValue: 12,
					discreteMapper: {
					attrName: "source",
					entries: [ { attrValue: "true",  value: 16 },
					           { attrValue: "false", value: 12 } ]
					}
				},
				labelFontName: "_typewriter",
				tooltipBackgroundColor: "#00ff00",
				selectionGlowOpacity: 0.2,
				selectionGlowColor: "#33ff33",
				labelGlowOpacity: 0
			},
			edges: {
				color: "#006600",
				mergeColor: "#006600",
				tooltipBackgroundColor: "#00ff00",
				sourceArrowShape: {
		            defaultValue: "none",
		            discreteMapper: { attrName: "directed",
		                              entries: [ { attrValue: "true",  value: "delta" },
		                                         { attrValue: "false", value: "none" } ]
		            }
		        },
		        targetArrowShape: {
		        	defaultValue: "none",
		        	discreteMapper: { attrName: "directed",
			        	              entries: [ { attrValue: "true",  value: "T" },
			        	                         { attrValue: "false", value: "none" } ]
			        }
		        },
				selectionGlowOpacity: 0.2,
				selectionGlowColor: "#33ff33"
			}
	};
	
	/*---- DARK --------------------------------------------------------------------------------------*/
	
	GRAPH_STYLES["Dark"] = {
			global: {
				backgroundColor: "#000000",
				selectionLineColor: "#ffffff",
				selectionLineOpacity: 0.5,
				selectionLineWidth: 1,
				selectionFillColor: "#fefefe",
				selectionFillOpacity: 0.1
			},
			nodes: {
				opacity: 0.6,
				size: { defaultValue: 12, continuousMapper: { attrName: "weight", minValue: 12, maxValue: 36 } },
				labelFontColor: "#ffffff",
				tooltipFontColor: "#ffffff",
				tooltipBackgroundColor: "#000000",
				tooltipBorderColor: "#999999",
				labelFontStyle: {
					defaultValue: "normal",
					discreteMapper: {
						attrName: "source",
						entries: [ { attrValue: "true",  value: "italic" },
						           { attrValue: "false", value: "normal" } ]
					}
				},
				labelGlowOpacity: 0,
				hoverOpacity: 1,
				selectionOpacity: 1,
				selectionGlowColor: "#ffffaa"
			},
			edges: {
				opacity: 0.6,
				color: { defaultValue: "#999999", discreteMapper: edgeColorMapper },
				width: { defaultValue: 1, continuousMapper: { attrName: "weight", minValue: 1, maxValue: 4 } },
				mergeWidth: { defaultValue: 1, continuousMapper: { attrName: "weight", minValue: 2, maxValue: 6 } },
				labelFontColor: "#ffffff",
				tooltipFontColor: "#ffffff",
				tooltipBackgroundColor: "#000000",
				tooltipBorderColor: "#999999",
				selectionGlowColor: "#ffffaa",
				hoverOpacity: 1,
				selectionOpacity: 1
			}
	};

});