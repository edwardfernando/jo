module Jo
  class Base
    include Enumerable
    include ActiveModel::Validations

    include Jo::Dirty
    include Jo::Validations
    include Jo::Locale

    def initialize(objects = {})
      @attributes = {} # to hold all values.
      # @attributes_before_type_cast = {} #values before type cast.

      unless objects.nil?
        self.class.meta.attributes.each do |name, attribute_meta|
          object = objects["#{name}"]
          object = objects[name] if object.nil?
          object = attribute_meta.default if object.nil?

          next if object.nil?

          object = Jo::Helper.to_jo(object, attribute_meta)

          type_casted_object = Jo::Helper.type_cast(object, attribute_meta)
          type_casted_object = Jo::Helper.bind(type_casted_object, attribute_meta, self, name)
          instance_variable_set("@#{name}", type_casted_object);

          @attributes[name] = object
        end
      end
    end

    def merge!(objects = {})
      return if objects.blank?

      self.class.meta.attributes.each do |name, attribute_meta|
        object = objects["#{name}"]
        object = objects[name] if object.nil?

        next if object.nil?

        send("#{name}=", object)
      end
      self
    end

    def inspect
      "#<#{self.class}: #{@attributes.inspect}>"
    end

    def present?
      @attributes.present?
    end

    def each
      @attributes.each { |key, value| yield(key, value) }
    end

    def each_value
      @attributes.values.each { |value| yield(value) }
    end

    def [](name)
      send(name)
    end

    def []=(name, value)
      send("#{name}=", value)
    end

    # It's better to use the hash to do hash#to_json and hash#blank?.
    # If you call object#to_json and object#blank? directly it might result in an wanted object.
    def to_serialized_jo
      serialized_jo = {}

      @attributes.each_key do |name|
        object = send(name)
        attribute_meta = self.class.meta.attributes[name]

        object = Jo::Helper.to_serialized_jo(object, attribute_meta)

        # false is blank but we still need to serialize it.
        serialized_jo[name] = object if object == false || object.present?
      end

      serialized_jo
    end

    def saved!
      @previously_changed = changes
      self.changed_attributes.clear
      attribute_metas = self.class.meta.attributes

      @attributes.each_key do |name|
        object = send(name)
        attribute_meta = attribute_metas[name]

        if attribute_meta.jo_family? && object.present?
          object.saved! if attribute_meta.base?
          object.map(&:saved!) if (attribute_meta.array? || attribute_meta.hash?) && attribute_meta.object_base?
        end
      end
    end

    def read_attribute_for_validation(name)
      send(name) if respond_to? name
    end

    def self.meta
      # Clone from the superclass.attributes in case of inheritance.
      unless @meta
        @meta ||= (self == Jo::Base) ? Jo::Meta.new : self.superclass.meta.clone
        @meta.merge!(:class => self, :name => self.to_s.underscore)
      end
      @meta
    end

    # Define an attribute for your jo.
    # Name of the attribute.
    # Class - enforce class for the attribute.
    def self.attribute(name, clazz = :string, options = {})
      name = name.to_sym
      options[:name] = name
      options[:class] ||= clazz

      attribute_meta = meta.attributes[name]

      # In case we override the attribute.
      if attribute_meta
        attribute_meta.merge!(options)
      else
        attribute_meta = meta.attributes[name] = Jo::Meta.new(options)

        # To register new attributes for ActiveModel to track changes.
        define_attribute_method name

        validate_jo_family(name, attribute_meta) if attribute_meta.jo_family?

        instance = "@#{name}"

        class_eval do
          define_method(name) do
            if instance_variable_defined?(instance)
              instance_variable_get(instance)
            else
              type_casted_object = Jo::Helper.type_cast(@attributes[name], attribute_meta)
              instance_variable_set(instance, Jo::Helper.bind(type_casted_object, attribute_meta, self, name))
            end
          end

          define_method("#{name}=") do |object|
            object = Jo::Helper.to_jo(object, attribute_meta)
            typed_cast_object = Jo::Helper.type_cast(object, attribute_meta)

            if typed_cast_object != send(name)
              will_change!
              send("#{name}_will_change!")
              typed_cast_object = Jo::Helper.bind(typed_cast_object, attribute_meta, self, name)
              instance_variable_set(instance, typed_cast_object)
              @attributes[name] = object
            end
          end

          define_method("#{name}_before_type_cast") do
            @attributes[name]
          end

          define_method("type_cast_#{name}_object") do |object|
            Jo::Helper.type_cast_object(object, attribute_meta)
          end

        end
      end
    end

    def self.attribute_i18n(name, options = {})
      options[:object_class] ||= :string
      options[:default] ||= Jo::Hash.new

      attribute_meta = meta.attributes[name]

      if attribute_meta
        attribute_meta.merge!(options) # merge the options to override old attribute meta.
      else
        attribute(name, Jo::Hash, options)

        class_eval do
          jo_locale_accessor name
        end
      end
    end

    def self.has_many(name, options = {})
      options[:object_class] ||= :string
      options[:default] ||= Jo::Array.new

      # Check if the attribute is declared or not.
      attribute_meta = meta.attributes[name]
      if attribute_meta
        attribute_meta.merge!(options) # merge the options to override old attribute meta.
      else
        attribute(name, Jo::Array, options)
      end
    end

  end
end
