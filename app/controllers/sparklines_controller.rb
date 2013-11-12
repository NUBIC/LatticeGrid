
# Handles requests for sparkline graphs.
#
# You shouldn't need to edit or extend this, but you can read
# the documentation for SparklinesHelper to see how to call it from
# another view.
#
# AUTHOR
# 
# Geoffrey Grosenbach[mailto:boss@topfunky.com]
#
# http://topfunky.com
#
class SparklinesController < ApplicationController
  skip_before_filter  :find_last_load_date 
  skip_before_filter  :handle_year
  skip_before_filter  :get_organizations
  skip_before_filter  :handle_pagination
  skip_before_filter  :define_keywords 

  require "net/http"
  require "uri"
  require 'cgi'
 
  require 'cache_utilities'
	layout nil

	def index
	  
	  send_file(public_path()+'/images/sparkline.png', :type => 'image/png', :filename => "sparkline.png" )
		# Make array from comma-delimited list of data values
		#ary = []
		#params['results'].split(',').each do |s|
		#	ary << s.to_i
		#end
		
		#send_data( Sparklines.plot( ary, params ), 
		#			:disposition => 'inline',
		#			:type => 'image/png',
		#			:filename => "spark_#{params[:type]}.png" )
	end

  def proxy_googlechart
    #chart.apis.google.com
    logger.warn "params = #{params.inspect}"
#    begin
#      the_params = Hash[params[:id].split("&").collect{|item| item.split("=") }] unless params[:id].blank?
#    end
#    the_params = Hash[ "chs=300x300&cht=p&chd=e0:U-gh..b".split("&").collect{|item| item.split("=") }]
#    response = http_get("chart.apis.google.com", "chart", the_params)
    response = get_google_content("http://chart.apis.google.com/chart?chs=300x300&cht=p&chd=e0:U-gh..b")    
    send_data response, :type => 'image/png', :disposition => 'inline'
  end
  
  private

  def http_get(domain,path,tparams)
    path = path + "?" + tparams.collect { |k,v| "#{k}=#{CGI::escape(v.to_s)}" }.join('&') unless tparams.nil?
    logger.warn "path = #{path}"
    http = Net::HTTP.new("chart.apis.google.com")
    return Net::HTTP.get(domain, path)
  end
  
  def get_google_content(requested_url)
    url = URI.parse(requested_url)
    full_path = (url.query.blank?) ? url.path : "#{url.path}?#{url.query}"
    logger.warn "full_path = #{full_path}"
    the_request = Net::HTTP::Get.new(full_path)

    the_response = Net::HTTP.start(url.host, url.port) { |http|
      http.request(the_request)
    }

    raise "Response was not 200, response was #{the_response.code}" if the_response.code != "200"
    return the_response.body
  end
  
end
