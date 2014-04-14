module TagHelper
  def flash_tags
    html = ""

    close_button_html = content_tag(:button, "&times;".html_safe, :type => "button", :class => "close", :"data-dismiss" => "alert")

    if notice.present?
      html << content_tag(:div, close_button_html + notice, :class => "alert alert-block alert-info")
    end

    if alert.present?
      html << content_tag(:div, close_button_html + alert, :class => "alert alert-block alert-error")
    end

    html.html_safe
  end

  def nonce_meta_tag
    tag "meta", :name => "nonce", :content => create_nonce
  end

  def headline_tag(*breadcrumbs, &block)
    content = []

    if breadcrumbs.present?
      last_breadcrumb = breadcrumbs.pop

      breadcrumbs.each do |breadcrumb|
        if breadcrumb.is_a?(ActiveRecord::Base)
          content << link_to(breadcrumb.display, breadcrumb)
        else
          content << breadcrumb.to_s
        end

        content << " &raquo; "
      end

      if last_breadcrumb.is_a?(ActiveRecord::Base)
        content << link_to(last_breadcrumb.display, last_breadcrumb)
        content << " &raquo; "
        content << t(".headline")
      else
        content << (last_breadcrumb || t(".headline"))
      end
    elsif action_name == "show"
      name   = controller_name.singularize
      record = instance_variable_get("@#{name}")

      content << record.display.truncate(40, :separator => " ")
    elsif %w(edit update).include?(action_name)
      name   = controller_name.singularize
      record = instance_variable_get("@#{name}")

      content << link_to(record.display.truncate(30, :separator => " "), send(:"#{name}_path", record))
      content << " &raquo; "
      content << t(".headline")
    else
      content << t(".headline")
    end

    if block_given?
      content << content_tag("span", capture(&block), :class => "pull-right")
    end

    content_tag "h2", content.join.html_safe
  end

  def time_tag(time, options = {})
    options.reverse_merge! :format => :long

    if options[:format] == :time_only
      content_tag "time", l(time, :format => :time), :datetime => time
    else
      content_tag "time", time_ago_in_words(time), :datetime => time, :title => l(time, :format => options[:format])
    end
  end

  def not_assigned
    content_tag "span", t(:not_assigned), :class => "not-assigned"
  end

  def pagination_for(records, options = {})
    content_tag "div", content_tag("div", page_entries_info(records, :entry_name => "entry"), :class => "pageinfo") + paginate(records), :class => "paginated"
  end
end
