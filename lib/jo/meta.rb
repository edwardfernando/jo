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

    [:date, :time, :integer, :float, :boolean, :string].each do |type|
      define_method("#{type}?") do
        eval("@#{type}") || instance_variable_set("@#{type}", @class == type)
      end

      define_method("object_#{type}?") do
        eval("@object_#{type}") || instance_variable_set("@object_#{type}", @object_class == type)
      end
    end

    def jo_family?
      @jo_family ||= base? || array? || hash?
    end

    def object_jo_family?
      @object_jo_family ||= object_base? || object_array? || object_hash?
    end

    [:base, :array, :hash].each do |type|
      define_method("#{type}?") do
        value = eval("@#{type}")
        unless value
          value = if @class.is_a?(Symbol) || @class.nil?
            false
          else
            eval("#{@class} <= Jo::#{type.to_s.classify}")
          end
          instance_variable_set("@#{type}", value)
        end
        value
      end

      define_method("object_#{type}?") do
        value = eval("@object_#{type}")
        unless value
          value = if @object_class.is_a?(Symbol) || @object_class.nil?
            false
          else
            eval("#{@object_class} <= Jo::#{type.to_s.classify}")
          end
          instance_variable_set("@object_#{type}", value)
        end
        value
      end
    end

    def dirty?
      @jorty ||= @class.include?(Jo::Dirty)
    end

    def polymorphism?
      @jo ||= @class.include?(Jo::Polymorphism)
    end

    def object_dirty?
      @object_dirty ||= @objet_class && @objet_class.include?(Jo::Dirty)
    end

    def object_polymorphism?
      @object_polymorphism ||= @object_class && @object_class.include?(Jo::Polymorphism)
    end

  end
end