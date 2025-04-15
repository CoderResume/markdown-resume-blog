class ApplicationController < ActionController::Base
  include Authentication

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  around_action :switch_locale

  helper_method :default_locale?, :theme_file_name

  def raise_404(message = "Not Found")
    raise ActionController::RoutingError.new(message)
  end

  def default_locale?
    I18n.locale == I18n.default_locale
  end

  def current_locale
    if @current_locale.nil?
      @current_locale = Locale.find_by(key: I18n.locale)
      return @current_locale
    end

    @current_locale
  end

  def theme_file_name
    enabled_theme = Theme.enabled

    if enabled_theme.present?
      return "theme-#{enabled_theme.color}"
    end

    "theme-1"
  end

  private

  def switch_locale(&action)
    locale = extract_locale_from_subdomain || I18n.default_locale
    I18n.with_locale(locale, &action)
  end

  # Get locale code from request subdomain (like http://it.application.local:3000)
  # You have to put something like:
  #   127.0.0.1 it.application.local
  # in your /etc/hosts file to try this out locally
  #
  # Additionally, you need to add the following configuration to your config/environments/development.rb:
  #   config.hosts << 'it.application.local:3000'
  def extract_locale_from_subdomain
    subdomain = request.subdomains.first

    if subdomain.present?
      subdomain_record = Subdomain.find_by(value: subdomain)
      if subdomain_record.present?
        return subdomain_record.locale.key.to_sym
      end
    end

    nil
  end
end
