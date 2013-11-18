module ActionView # :nodoc:
  require 'pdf/writer'
  class PDFRender
    PAPER = 'US'
    include ApplicationHelper
    include ActionView::Helpers::AssetTagHelper
    include ActionView::Helpers::TextHelper
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::UrlHelper

    def initialize(action_view)
      @action_view = action_view
    end

    # Render the PDF
    def render(template, local_assigns = {})
      @action_view.controller.headers["Content-Type"] ||= 'application/pdf'

      # Retrieve controller variables
      @action_view.controller.instance_variables.each do |v|
        instance_variable_set(v, @action_view.controller.instance_variable_get(v))
      end

      pdf = ::PDF::Writer.new( :paper => PAPER )
      pdf.compressed = true if Rails.env != 'development'
      eval template.source, nil, "#{@action_view.base_path}/#{@action_view.first_render}.#{@action_view.finder.pick_template_extension(@action_view.first_render)}"

      pdf.render
    end

    def self.compilable?
      false
    end

    def compilable?
      self.class.compilable?
    end
  end
end
