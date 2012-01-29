
# Provides a tag for embedding sparkline graphs into your Rails app.
# 
#
# http://omnipotent.net/jquery.sparkline/
#Bar chart with inline data: <span class="inlinebarchart" values="1,3,4,5,3,5"></span>
#
# To use, load it in your controller with
#
#   helper :sparklines
#
# AUTHOR
#
# Geoffrey Grosenbach[mailto:boss@topfunky.com]
#
# http://topfunky.com
# 
# License
#
# This code is licensed under the MIT license.
#
module SparklinesHelper

	# Call with an array of data and a hash of params for the Sparklines module.
	# You can also pass :class => 'some_css_class' ('sparkline' by default).
	def sparkline_tag(results=[], options={})		
		url = { :controller => 'sparklines',
			:results => results.join(',') }
		options = url.merge(options)
		
		"<img src=\"#{ url_for options }\" class=\"#{options[:class] || 'sparkline'}\" alt=\"Sparkline Graph\" />"
	end
	
	# Call with an array of data and a hash of params for the Sparklines module.
  #/** This code runs when everything has been loaded on the page */
  # /* Inline sparklines take their values from the contents of the tag */
  # /* The second argument gives options such as chart type */
	def sparkline_barchart_setup(options={})
	  return if defined?(@barchart_setup)
	  options["barSpacing"] ||= 1
	  options["barWidth"] ||= 1
	  @barchart_setup=1
    out="<script type='text/javascript'>
      jQuery.noConflict();
      jQuery(function() {
        jQuery('.inlinebarchart').sparkline('html', {type: 'bar', barColor: 'darkgrey', zeroColor: 'red', barWidth: #{options['barWidth']}, barSpacing: #{options['barSpacing']}} );
        });
      </script>"
    out
  end

	def js_sparkline_barchart(id, data, options={})
	  options["barSpacing"] ||= 1
	  options["barWidth"] ||= 1
    out="<script type='text/javascript'>
    jQuery('.#{id}').sparkline([#{data}], {type: 'bar', barColor: 'darkgrey', zeroColor: 'red', barWidth: #{options['barWidth']}, barSpacing: #{options['barSpacing']}} );
     </script>"
    out
  end

end
