module Locale
  extend ActiveSupport::Concern

  included do
    before_action :set_locale

    helper_method :locale, :available_locales, :force_locale_url
  end

  private
    def locale
      @locale ||= param_locale || cookie_locale || user_locale || request_locale
    end

    def force_locale_url(locale)
      path = request.fullpath.sub(/([\?&])locale=/, '\1old_locale=')
      sep  = path.include?('?') ? '&' : '?'

      "#{path}#{sep}locale=#{locale}"
    end

    def set_locale
      I18n.locale = locale
    end

    def available_locales
      Metter.locales
    end

    def locale_valid?(locale)
      locale.present? && available_locales.include?(locale)
    end

    def param_locale
      locale_valid?(params[:locale]) && (cookies.permanent[:locale] = params[:locale])
    end

    def cookie_locale
      locale_valid?(cookies[:locale]) && cookies[:locale]
    end

    def user_locale
      if controller_name != "session" && respond_to?(:current_user, true)
        user = send(:current_user)

        locale = user.respond_to?(:locale) && user.locale
        locale = locale.split(/_/).first if locale.present?

        locale_valid?(locale) && locale
      else
        nil
      end
    end

    def request_locale
      request.language_from available_locales, I18n.default_locale
    end
end
