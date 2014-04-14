module LinkHelper
  def brand_link
    link_to t(:app_name), root_path, :class => "brand", :title => t(".home_page")
  end

  def nav_link(name, text = nil, options = {})
    route   = send(:"#{name}_path")
    title   = text || t(".nav.#{name}")


    active  =
      case name
      when :profile
        controller_name == "profile" && ["edit", "update"].include?(action_name)
      when :contact
        controller_name == "contactings" && ["new", "create"].include?(action_name)
      else
        controller_name == name.to_s || controller_name == "static" && action_name == name.to_s
      end

    content_tag "li", link_to(title, route, options.merge(:class => "nav-#{name}")), :class => ("active" if active)
  end

  def logout_link
    nav_link :logout, content_tag(:i, nil, :class => "icon-off icon-white"), :method => :delete, :title => t(".nav.logout")
  end

  def new_link(name, options = {})
    options.reverse_merge!(
      :text   => t(".new_#{name}"),
      :url    => send(:"new_#{name}_path"),
      :class  => "btn"
    )

    link_to options.delete(:text), options.delete(:url), options
  end

  def show_link(record, options = {})
    name = record.class.base_class.name.underscore

    options.reverse_merge!(
      :text   => record.display,
      :url    => send(:"#{name}_path", record),
      :class  => "link-show"
    )

    link_to options.delete(:text), options.delete(:url), options
  end

  def edit_link(record, options = {})
    name = record.class.base_class.name.underscore

    options.reverse_merge!(
      :text   => t(".edit_#{name}"),
      :url    => send(:"edit_#{name}_path", record),
      :class  => "btn btn-small btn-edit"
    )

    link_to options.delete(:text), options.delete(:url), options
  end

  def delete_link(record, options = {})
    name = record.class.base_class.name.underscore

    options.reverse_merge!(
      :text   => t(".delete_#{name}"),
      :url    => send(:"#{name}_path", record),
      :method => :delete,
      :class  => "btn btn-small btn-delete",
      :data   => { :confirm => t(".delete_confirm") }
    )

    link_to options.delete(:text), options.delete(:url), options
  end
end
