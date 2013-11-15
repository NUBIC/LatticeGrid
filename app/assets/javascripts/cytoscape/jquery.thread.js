;(function($){

    $.thread = function(opts){
    
        var defaults = {
            worker: function(params){},
            params: {},
            delay: 100
        };
        var options = $.extend(defaults, opts);
    
        setTimeout(function(){
        
            options.worker( options.params );
        
        }, options.delay);
    
    };

})(jQuery);  