module Jo
  module ActiveRecord
    extend ActiveSupport::Concern

    included do
      include Jo::Validations
      include Jo::Locale

      def changes
        attribute_metas = self.class.meta.attributes

        changed.inject(HashWithIndifferentAccess.new) do |h, attribute|
          attribute_meta = attribute_metas[attribute.to_sym]

          if attribute_meta && attribute_meta.jo_family?
            if (object = send(attribute))
              if attribute_meta.base?
                obj_changes = object.changes
                h[attribute] = obj_changes if obj_changes.present?
              end

              if attribute_meta.hash? || attribute_meta.array?
                # Tracking changes of hash or array itself.
                h[attribute] = attribute_change(attribute)

                # Tracking changes of the objects inside hash or array.
                if attribute_meta.object_base?
                  object_changes = {}

                  object.each_key_value do |key, value|
                    obj_changes = value.changes
                    object_changes[key] = obj_changes if obj_changes.present?
                  end

                  h["#{attribute}_objects"] = object_changes if object_changes.present?
                end

              end
            end
          else
            # If it is a normal attribute.
            h[attribute] = attribute_change(attribute)
          end

          h
        end
      end
    end

    module ClassMethods
      def meta
        @meta ||= Jo::Meta.new(:class => self, :name => table_name)
      end

      # Turn an AR column to a jo
      # Column name and the Jo::FastBase to parse json for that column
      def jonize_fast(name, clazz, options = {})
        instance = "@#{name}"

        alias_name = options[:as]

        class_eval do
          define_method(name) do
            return instance_variable_get(instance) if instance_variable_defined?(instance)

            object = read_attribute(name)
            object = nil if object.is_a?(String) && object.blank?
            object = object ? JSON::parse(object) : {}
            instance_variable_set(instance, clazz.new(object))
          end

          alias_method alias_name, name if alias_name && alias_name != name
        end
      end

      # Turn an AR column to a jo
      # Column name and the jo class to parse json for that column
      def jonize(name, clazz, options = {})
        name = name.to_sym
        name_before_type_cast = "#{name}_before_type_cast"

        options[:name] = name
        options[:class] ||= clazz

        alias_name = options[:alias] || options[:as]

        attribute_meta = meta.attributes[name]

        # In case we override the attribute.
        if attribute_meta
          attribute_meta.merge!(options)
        else
          attribute_meta = meta.attributes[name] = Jo::Meta.new(options)

          inheritance_column = if attribute_meta.polymorphism?
            options[:inheritance_column] || "#{name}_type_id"
          end

          instance = "@#{name}"
          instance_before_type_cast = "@#{name}_before_type_cast"
          instance_will_change = "#{name}_will_change!"
          instance_changed = "#{name}_changed?"

          class_eval do
            validate_jo_family(name, attribute_meta)

            define_method(name) do
              if instance_variable_defined?(instance)
                instance_variable_get(instance)
              else
                type_casted_object = Jo::Helper.type_cast(send(name_before_type_cast), attribute_meta)
                type_casted_object = Jo::Helper.bind(type_casted_object, attribute_meta, self, name)

                instance_variable_set(instance, type_casted_object)
              end
            end

            define_method("#{name}=") do |object|
              object = Jo::Helper.to_jo(object, attribute_meta)
              type_casted_object = Jo::Helper.type_cast(object, attribute_meta)

              if type_casted_object != send(name)
                respond_to?(instance_will_change) && send(instance_will_change)

                type_casted_object = Jo::Helper.bind(type_casted_object, attribute_meta, self, name)

                instance_variable_set(instance, type_casted_object)
                instance_variable_set(instance_before_type_cast, object)
              end
            end

            define_method(name_before_type_cast) do
              if instance_variable_defined?(instance_before_type_cast)
                instance_variable_get(instance_before_type_cast)
              else
                object = read_attribute(name)

                object = nil if object.is_a?(String) && object.blank?

                object = Jo::Helper.to_jo(object, attribute_meta)

                object = attribute_meta.class.new if object.nil?

                instance_variable_set(instance_before_type_cast, object)
              end
            end

            define_method("type_cast_#{name}_object") do |object|
              Jo::Helper.type_cast_object(object, attribute_meta)
            end

            # Write the jo to column before save if there are changes.
            before_save :if => Proc.new { |model|
              model.respond_to?(instance_changed) && model.send(instance_changed)
            } do |model|
              object = send(name)

              if attribute_meta.polymorphism?
                object.type_id = object.class.type_ids[object.class] if object

                write_attribute("#{inheritance_column}", object && object.type_id)
              end

              object = Jo::Helper.to_serialized_jo(object, attribute_meta)

              write_attribute(name, object.present? ? object.to_json : nil)

              true
            end

            after_save :if => Proc.new { |model|
              model.respond_to?(instance_changed) && model.send(instance_changed)
            } do |model|
              object = send(name)

              if object
                object.saved! if attribute_meta.base?
                object.map_values(&:saved!) if (attribute_meta.array? || attribute_meta.hash?) && attribute_meta.object_base?
              end

              true
            end
          end
        end


        class_eval do
          if alias_name && alias_name != name
            alias_method alias_name, name
            alias_method "#{alias_name}=", "#{name}="
          end
        end

      end


      def jonize_many(name, options = {})
        options[:object_class] ||= :string
        jonize(name, Jo::Array, options)
      end


      def jonize_i18n(name, options = {})
        options[:object_class] ||= :string
        jonize(name, Jo::Hash, options)
        alias_name = options[:alias] || options[:as]

        class_eval do
          jo_locale_accessor name

          if alias_name && alias_name != name
            alias_method "#{alias_name}_i18n", "#{name}_i18n"

            Jo::Locale.underscored_locales.each do |locale|
              alias_name_locale = Jo::Locale.localize(alias_name, locale)
              name_locale = Jo::Locale.localize(name, locale)

              alias_method alias_name_locale, name_locale
              alias_method "#{alias_name_locale}=", "#{name_locale}="
            end
          end

        end
      end

      def jonize_many_i18n(name, options = {})
        options[:object_class] ||= Jo::Array
        jonize_i18n(name, options)
      end

    end
  end
end