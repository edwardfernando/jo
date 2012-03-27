module Jo
  class Meta

    attr_accessor :name, :class, :object_class, :default, :attributes

    def initialize(options = {})
      options[:attributes] ||= {}
      merge!(options)
      self
    end

    def merge!(options = {})
      options.each { |key, value| send("#{key}=", value) if respond_to?(key) }
    end

    def clone
      Jo::Meta.new(:class => @class, :default => default, :attributes => attributes.clone)
    end

    def default
      # in case default cannot be cloned, e.g. NilClass, Fixnum or Symbol
      @default.clone rescue @default
    end

    def symbol?
      @is_symbol.nil? ? (@is_symbol = @class.is_a?(Symbol)) : @is_symbol
    end

    def object_symbol?
      @is_object_symbol.nil? ? (@is_object_symbol = @object_class.is_a?(Symbol)) : @is_object_symbol
    end

    def class?
      @is_class.nil? ? (@is_class = @class.is_a?(Class)) : @is_class
    end

    def object_class?
      @is_object_class.nil? ? (@is_object_class = @object_class.is_a?(Class)) : @is_object_class
    end

    def date?
      @is_date.nil? ? (@is_date = @class == :date) : @is_date
    end

    def object_date?
      @is_object_date.nil? ? (@is_object_date = @object_class == :date) : @is_object_date
    end

    def time?
      @is_time.nil? ? (@is_time = @class == :time) : @is_time
    end

    def object_time?
      @is_object_time.nil? ? (@is_object_time = @object_class == :time) : @is_object_time
    end

    def integer?
      @is_integer.nil? ? (@is_integer = @class == :integer) : @is_integer
    end

    def object_integer?
      @is_object_integer.nil? ? (@is_object_integer = @object_class == :integer) : @is_object_integer
    end

    def float?
      @is_float.nil? ? (@is_float = @class == :float) : @is_float
    end

    def object_float?
      @is_object_float.nil? ? (@is_object_float = @object_class == :float) : @is_object_float
    end

    def boolean?
      @is_boolean.nil? ? (@is_boolean = @class == :boolean) : @is_boolean
    end

    def object_boolean?
      @is_object_boolean.nil? ? (@is_object_boolean = @object_class == :boolean) : @is_object_boolean
    end

    def string?
      @is_string.nil? ? (@is_string = @class == :string) : @is_string
    end

    def object_string?
      @is_object_string.nil? ? (@is_object_string = @object_class == :string) : @is_object_string
    end

    def jo_family?
      @is_jo_family.nil? ? (@is_jo_family = base? || array? || hash?) : @is_jo_family
    end

    def object_jo_family?
      @is_object_jo_family.nil? ? (@is_object_jo_family = object_base? || object_array? || object_hash?) : @is_object_jo_family
    end

    def base?
      @is_base.nil? ? (@is_base = class? && (@class.ancestors.include?(Jo::Base) || @class.ancestors.include?(Jo::FastBase))) : @is_base
    end

    def object_base?
      @is_object_base.nil? ? (@is_object_base = object_class? && (@object_class.ancestors.include?(Jo::Base) || @object_class.ancestors.include?(Jo::FastBase))) : @is_object_base
    end

    def array?
      @is_array.nil? ? (@is_array = class? && @class.ancestors.include?(Jo::Array)) : @is_array
    end

    def object_array?
      @is_object_array.nil? ? (@is_object_array = object_class? && @object_class.ancestors.include?(Jo::Array)) : @is_object_array
    end

    def hash?
      @is_hash.nil? ? (@is_hash = class? && @class.ancestors.include?(Jo::Hash)) : @is_hash
    end

    def object_hash?
      @is_object_hash.nil? ? (@is_object_hash = object_class? && @object_class.ancestors.include?(Jo::Hash)) : @is_object_hash
    end

    def dirty?
      @is_dirty.nil? ? (@is_dirty = class? && @class.include?(Jo::Dirty)) : @is_dirty
    end

    def object_dirty?
      @is_object_dirty.nil? ? (@is_object_dirty = object_class? && @object_class.include?(Jo::Dirty)) : @is_object_dirty
    end

    def polymorphism?
      @is_polymorphism.nil? ? (@is_polymorphism = class? && @class.include?(Jo::Polymorphism)) : @is_polymorphism
    end

    def object_polymorphism?
      @is_object_polymorphism.nil? ? (@is_object_polymorphism = object_class? && @object_class.include?(Jo::Polymorphism)) : @is_object_polymorphism
    end

  end
end