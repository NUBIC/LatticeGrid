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
;(function($){
   
    $.cytoscapeweb = {};
    $.cytoscapeweb.opts = {};
    $.cytoscapeweb.vis = {};
   
    $.fn.cytoscapeweb = function(option_set) {  
        
        var defaults = {
        };
        var options = $.extend(defaults, option_set); 
        
        var return_value = undefined;
        var args = arguments;
        
        this.each(function() {
            
            var id =  $(this).attr("id");
            if( id == undefined ) {
                throw "Cytoscape Web requires its container to have a specified ID.";
            }
            var vis = $.cytoscapeweb.vis[id];
            
            // (option_set) is to get options or existing vis
            if( vis != undefined ) {
                vis = $.cytoscapeweb.vis[id];
                options = $.cytoscapeweb.opts[id];
                
                // get options
                if( typeof option_set == "string" ) {
                    var option_name = option_set;
                    return_value = options[option_name];
                
                // get visualisation
                } else {
                    return_value = vis;
                }
                
            // (option_set) is to set options for vis
            } else {
                // put visualisation in container and save it
                var vis = new org.cytoscapeweb.Visualization(id, options);
                $.cytoscapeweb.vis[id] = vis;
                $.cytoscapeweb.opts[id] = options;               

                return_value = vis;
            }
            
        });
        
        return (return_value != undefined) ? (return_value) : (this.each(function(){}));

    };

    // short name
    $.fn.cw = $.fn.cytoscapeweb;
    
})(jQuery);  