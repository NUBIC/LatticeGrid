var animation_speed = "fast";

$(function(){

	// Make these links open in another page
	$("a[rel=external]").click(function() {
        this.target = "_blank";
	});

    var search_default_text = $("#search_input").find("input").val();
    
    $("#search_input").find("input").blur(function(){
        if( $(this).val() == "" ) {
            $(this).val(search_default_text);
        }
        $("#search").removeClass("focus");
    }).focus(function(){
        if( $(this).val() == search_default_text ) {
            $(this).val("");
        }
        $("#search").addClass("focus");
    });
    
    $("pre").each(function(){
        if( $(this).find("code").length > 0 ){
            var pre = $(this);
            
            var textarea = $('<textarea readonly="true" class="pre_plain">' + $(this).find("code:first").html() + '</textarea>');
            $(this).after(textarea);
            $(textarea).hide();
            
            var link = $('<span class="like_link pre_plain_link"></span>');
            var copy_text = "View as copy ready text";
            var formatted_text = "View as formatted text";
            $(this).before(link);
            
            $(link).text(copy_text);
            $(link).toggle(function(){
                pre.trigger("mouseout");
            
                link.text(formatted_text);
                textarea.show().height( pre.height() ).width( pre.width() );
                textarea.width( textarea.width() - (textarea.outerWidth() - pre.outerWidth()) );
                textarea.height( textarea.height() - (textarea.outerHeight() - pre.outerHeight()) );
                textarea.select();
                
                pre.hide();
            }, function(){
                link.text(copy_text);
                textarea.hide();
                pre.show();
            });
            
        }
    });
    
    function make_pre_expandable(){
        var delay_before_closing_pre = 0;
        $("pre").each(function(){
            $(this).css({
                "overflow": "hidden"
            });
            
            var timeout = undefined;
    
            var normal_width = $(this).width();
    
            var orig_float = $(this).css("float");
            $(this).css("float", "left").css("width", "auto");
            var expanded_width = $(this).width();
            $(this).css("float", orig_float);
            
            if( expanded_width > normal_width ){
                $(this).addClass("collapsed").removeClass("expanded");
            
                $(this).mouseover(function(){
                    if( $(this).is(":visible") ){
                        clearTimeout(timeout);
                        timeout = undefined;
                    
                        $(this).removeClass("collapsed").addClass("expanded");
                        $(this).width(expanded_width);
                    }
                });
                
                $(this).mouseout(function(){
                    var pre = $(this);
                    
                    timeout = setTimeout(function(){
                        if( false /* disable animation for now */ ){
                            pre.animate({width: normal_width}, "fast", function(){
                                pre.addClass("collapsed").removeClass("expanded");
                            });
                        } else {
                            $(pre).width(normal_width);
                            pre.addClass("collapsed").removeClass("expanded");
                        }
                    }, delay_before_closing_pre);

                });
            }
        });
    }
    
    $(window).load(function(){
        make_pre_expandable();
    });

});