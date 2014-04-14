module ApplicationHelper
  def title(value = nil)
    if value
      @title = value
    else
      @title || begin
        if action_name == "show"
          name   = controller_name.singularize
          record = instance_variable_get("@#{name}")

          record.display.truncate 100, :separator => " "
        else
          view_name = action_name
          view_name = "new"   if view_name == "create"
          view_name = "edit"  if view_name == "update"

          translate "#{controller_name}.#{view_name}.title"
        end
      end
    end
  end

  def date_name(date, format = :long)
    case date
    when Date.today
      translate :today
    when Date.tomorrow
      translate :tomorrow
    when Date.yesterday
      translate :yesterday
    else
      localize date, :format => format
    end
  end

  def logged_in_as_line
    translate ".logged_in_as_html", :as => link_to(current_user.name, profile_path, :class => "navbar-link", :title => t(".edit_profile"))
  end

  def translate_type(record)
    translate "#{record.class.table_name}.types.#{record.class.name.underscore}"
  end

  alias_method :tt, :translate_type

  def options_for_locales
    Metter.locales.map { |locale| [t(:language, :locale => locale), locale] }
  end
end
