;(function($){
    
    $.fn.validate = function(opts){
        return $(this).each(function(){
           
            var defaults = {
                errorClass: "ui-validation-error",
                errorMessageClass: "ui-validation-error-message",
                label: undefined,
                completionIcon: undefined,
                appendCompletionIcon: false,
                completionIconClass: "ui-validation-completion",
                completionIconCompleteClass: "ui-validation-complete",
                delayAfterTyping: 500,
                validateOnLoad: false,
                valid: function(inputValue){ return true; },
                errorMessage: function(inputValue){ return "is not valid"; },
                onValidate: function(){},
                onValid: function(){},
                onInvalid: function(){}
            };
            
            var options = $.extend(defaults, opts);
            
            if( options.label != undefined ){
                var err_msg = options.label.find("." + options.errorMessageClass);
                if( err_msg.length <= 0 ){
                    options.label.append(' <span class="' + options.errorMessageClass + '"></span>');
                }
            }
            
            if( options.completionIcon != undefined ){
                var icon = options.completionIcon;
                
                icon.addClass(options.completionIconClass);
            } else if( options.appendCompletionIcon ){
                options.completionIcon = $('<div class="' + options.completionIconClass + '"></div>');
                $(this).before(options.completionIcon);
            }
            
            $(this).bind("blur change", function(){
                $(this).trigger("validate");
            });
            
            $(this).each(function(){
                var input = $(this);
                var timeout = null;
                function trigger_validate(){
                    input.trigger("validate");
                    timeout = null;
                }
            
                $(this).bind("keydown", function(event){
                    var tag;
                    
                    input.each(function(){
                        tag = this.tagName.toLowerCase();
                    });
                
                    if( event.keyCode == 13 && tag == "input" ){
                        setTimeout(function(){
                            $(input).blur();
                        }, 10);
                    } else {
                        clearInterval(timeout);
                        timeout = setTimeout(trigger_validate, options.delayAfterTyping);
                    }
                });
                
                if( options.validateOnLoad ){
                    $(window).load(function(){
                        if( input.val() != "" ) {
                            input.trigger("validate");
                        }
                    });
                }
            });
                
            
            $(this).bind("validate", function(){
                var value = $(this).val();
                
            
                if( options.valid(value) ){
                    $(this).removeClass(options.errorClass);
                    
                    if( options.label != undefined){
                        options.label.find( "." + options.errorMessageClass ).html( "" );
                    }
                    
                    if( options.completionIcon != undefined ){
                        options.completionIcon.addClass(options.completionIconCompleteClass);
                    }
                    
                    options.onValidate();
                    options.onValid();
                    
                    $(this).trigger("valid");
                } else {
                    $(this).addClass(options.errorClass);
                    
                    if( options.label != undefined ){
                        var err_msg = options.label.find( "." + options.errorMessageClass );
                        
                        err_msg.html( options.errorMessage(value) );
                    }
                    
                    if( options.completionIcon != undefined ){
                        options.completionIcon.removeClass(options.completionIconCompleteClass);
                    }
                    
                    options.onValidate();
                    options.onInvalid();
                    
                    $(this).trigger("invalid");
                }
                
                
            });
           
        });
    }
   
    
})(jQuery);  