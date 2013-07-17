module Jo
  module Locale
    extend ActiveSupport::Concern

    module ClassMethods
      def jo_locale_accessor(name)
        define_method("#{name}_i18n") do
          locale = defined?(I18n) ? I18n.locale.to_sym : :en
          locale = :en unless Jo::Locale.support?(locale)

          # Fallback to English.
          send("#{name}_#{Jo::Locale.underscore(locale)}") || send("#{name}_en")
        end

        # Accessors for each locale.
        Jo::Locale.locales.each do |locale|
          name_locale = Jo::Locale.localize(name, locale)

          define_method(name_locale) do
            send(name)[locale]
          end

          define_method("#{name_locale}=") do |object|
            send(name)[locale] = object
          end
        end

        # Locale aliases.
        Jo::Locale.aliases.each do |locale, aliases|
          locale = Jo::Locale.localize(name, locale)

          aliases.each { |a| alias_method Jo::Locale.localize(name, a), locale }
        end
      end
    end

    def self.set_locales(*locales)
      @locales = locales
    end


    def self.locales
      @locales ||= [:en, :'zh-cn']
    end

    def self.underscored_locales
      @underscored_locales ||= locales.collect{ |locale| underscore(locale) }
    end


    # :locale => array of aliases
    def self.aliases
      @aliases ||= {
        :'zh-tw' => [:'zh-hk']
      }
    end

    def self.supported_aliases
      @supported_aliases ||= aliases.values.flatten
    end


    def self.support?(locale)
      locales.include?(locale) || supported_aliases.include?(locale)
    end


    def self.localize(string, locale = nil)
      if locale
        "#{string}_#{underscore(locale)}".to_sym
      else
        underscored_locales.collect{ |locale| localize(string, locale) }
      end
    end


    # Convert a locale to underscored locale
    def self.underscore(locale)
      "#{locale}".gsub(/-/, '_').to_sym
    end

  end
end