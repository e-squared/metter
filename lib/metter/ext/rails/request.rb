module ActionDispatch
  class Request
    # Returns a sorted array based on user preference in HTTP_ACCEPT_LANGUAGE.
    # Browsers send this HTTP header, so don't think this is holy.
    #
    # Example:
    #
    #   request.user_preferred_languages
    #   #=> ['nl-NL', 'nl-BE', 'nl', 'en-US', 'en']
    #
    def accepted_languages
      @accepted_languages ||= env["HTTP_ACCEPT_LANGUAGE"].split(/\s*,\s*/).collect do |language|
        language += ";q=1.0" unless language =~ /;q=\d+\.\d+$/
        language.split(";q=")
      end.sort do |x, y|
        raise "Not correctly formatted" unless x.first =~ /^[a-z\-]+$/i
        y.last.to_f <=> x.last.to_f
      end.map do |language|
        language.first.downcase.gsub(/-[a-z]+$/i) { |suffix| suffix.upcase }
      end
    rescue
      [] # Just rescue anything if the browser messed up badly.
    end

    # Sets the user languages preference, overiding the browser
    #
    def accepted_languages=(languages)
      @accepted_languages = languages
    end

    # Finds the locale specifically requested by the browser.
    #
    # Example:
    #
    #   request.preferred_language_from I18n.available_locales
    #   #=> 'nl'
    #
    def preferred_language_from(locales)
      (accepted_languages & locales).first
    end

    # Returns the first of the user_preferred_languages that is compatible
    # with the available locales. Ignores region.
    #
    # Example:
    #
    #   request.compatible_language_from I18n.available_locales
    #
    def compatible_language_from(locales)
      accepted_languages.map do |language| # en-US
        locales.find do |locale| # en
          language == locale || language.split('-', 2).first == locale.split('-', 2).first
        end
      end.compact.first
    end

    def language_from(locales, default_locale)
      preferred_language_from(locales) || compatible_language_from(locales) || default_locale
    end
  end
end
