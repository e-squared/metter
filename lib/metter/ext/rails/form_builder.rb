module ActionView
  module Helpers
    class FormBuilder
      # convenience method
      def template
        @template
      end

      # added method
      def validation_errors
        return "" if object.errors.empty?

        messages = object.errors.full_messages.map { |msg| template.content_tag(:li, msg) }.join

        sentence = I18n.t("errors.template.header",
                          :count => object.errors.count,
                          :resource => object.class.model_name.human)

        html = <<-HTML
          <div class="alert alert-block alert-error alert-invalid">
            <h4>#{sentence}</h4>
            <ul>#{messages}</ul>
          </div>
        HTML

        html.html_safe
      end

      # added to always specify a disable-with option and styles
      def submit_button(value = nil, options = {})
        button value, options.reverse_merge(:data => { :disable_with => I18n.t(:please_wait) }, :class => "btn btn-primary btn-submit")
      end

      # added
      def cancel_button(url = nil, options = {})
        url, options = nil, url if url.is_a?(Hash)

        url ||=
          if object.class.respond_to?(:table_name)
            if object.persisted?
              object
            else
              template.send :"#{object.class.table_name}_path"
            end
          else
            template.send :"#{object.class.name.pluralize.underscore}_path"
          end

        options.reverse_merge! :text => I18n.t(:cancel), :class => "btn btn-cancel"

        template.link_to options.delete(:text), url, options
      end

      # added
      def input(name, options = {}, &block)
        options.reverse_merge! :class => "span6", :args => []

        method = options.delete(:as) || (name.to_s =~ /password/i ? "password_field" : "text_field")

        label_tag = label(name, :class => "control-label")

        input_tag =
          if block_given?
            template.capture(&block)
          else
            send method.to_sym, name, *options.delete(:args), options
          end

        content = label_tag + template.content_tag("div", input_tag, :class => "controls")

        template.content_tag "div", content, :class => "control-group control-input control-#{name}"
      end

      def text_fields(name, options = {})
        values = object.send(name) || []
        values << nil

        button = template.button_tag(template.content_tag("i", nil, :class => "icon-remove"), :title => template.translate(".#{name}_remove"), :class => "btn btn-input-remove")

        inputs = values.map do |value|
          template.content_tag "div", text_field(name, options.merge(:id => nil, :value => value, :multiple => true)) + button, :class => "input-append"
        end

        template.content_tag "div", inputs.join.html_safe + template.button_tag(template.translate(".#{name}_add"), :class => "btn btn-small btn-input-add"), :class => "input-multiple"
      end

      # added
      def buttons(*args)
        options     = args.extract_options!
        submit_text = args.first
        cancel_url  = args.second

        submit_tag = submit_button(submit_text, options[:submit] || {})
        cancel_tag = options[:cancel] == false ? "".html_safe : cancel_button(cancel_url, options[:cancel] || {})
        content    = template.content_tag("div", submit_tag + " ".html_safe + cancel_tag, :class => "controls")

        template.content_tag "div", content, :class => "control-group control-buttons"
      end
    end
  end
end
