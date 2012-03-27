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

    def date?
      @date.nil? ? (@date = @class == :date) : @date
    end

    def object_date?
      @object_date.nil? ? (@object_date = @object_class == :date) : @object_date
    end

    def time?
      @time.nil? ? (@time = @class == :time) : @time
    end

    def object_time?
      @object_time.nil? ? (@object_time = @object_class == :time) : @object_time
    end

    def integer?
      @integer.nil? ? (@integer = @class == :integer) : @integer
    end

    def object_integer?
      @object_integer.nil? ? (@object_integer = @object_class == :integer) : @object_integer
    end

    def float?
      @float.nil? ? (@float = @class == :float) : @float
    end

    def object_float?
      @object_float.nil? ? (@object_float = @object_class == :float) : @object_float
    end

    def boolean?
      @boolean.nil? ? (@boolean = @class == :boolean) : @boolean
    end

    def object_boolean?
      @object_boolean.nil? ? (@object_boolean = @object_class == :boolean) : @object_boolean
    end

    def string?
      @string.nil? ? (@string = @class == :string) : @string
    end

    def object_string?
      @object_string.nil? ? (@object_string = @object_class == :string) : @object_string
    end

    def jo_family?
      @jo_family.nil? ? (@jo_family = base? || array? || hash?) : @jo_family
    end

    def object_jo_family?
      @object_jo_family.nil? ? (@object_jo_family = object_base? || object_array? || object_hash?) : @object_jo_family
    end

    def base?
      @base.nil? ? (@base = @class.ancestors.include?(Jo::Base) || @class.ancestors.include?(Jo::FastBase)) : @base
    end

    def object_base?
      @object_base.nil? ? (@object_base = @object_class.ancestors.include?(Jo::Base) || @object_class.ancestors.include?(Jo::FastBase)) : @object_base
    end

    def array?
      @array.nil? ? (@array = @class.ancestors.include?(Jo::Array)) : @array
    end

    def object_array?
      @object_array.nil? ? (@object_array = @object_class.ancestors.include?(Jo::Array)) : @object_array
    end

    def hash?
      @hash.nil? ? (@hash = @class.ancestors.include?(Jo::Hash)) : @hash
    end

    def object_hash?
      @object_hash.nil? ? (@object_hash = @object_class.ancestors.include?(Jo::Hash)) : @object_hash
    end

    def dirty?
      @dirty.nil? ? (@dirty = @class.include?(Jo::Dirty)) : @dirty
    end

    def object_dirty?
      @object_dirty.nil? ? (@object_dirty = @object_class.include?(Jo::Dirty)) : @object_dirty
    end

    def polymorphism?
      @polymorphism.nil? ? (@polymorphism = @class.include?(Jo::Polymorphism)) : @polymorphism
    end

    def object_polymorphism?
      @object_polymorphism.nil? ? (@object_polymorphism = @object_class.include?(Jo::Polymorphism)) : @object_polymorphism
    end

  end
end