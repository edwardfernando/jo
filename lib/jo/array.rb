module Jo
  class Array < ::Array
    include Jo::Dirty

    alias_method :each_value, :each

    alias_method :map_values!, :map!

    def each_key_value
      each_with_index { |value, index| yield(index, value) }
    end

    def map_values
      array = self.class.new
      self.each { |value| array << yield(value) }
      array
    end

    def compact_blank!
      self.delete_if { |value| value != false && value.blank? }
    end

    def []=(index, object)
      if binded?
        type_casted_object = type_cast_object(object)

        if type_casted_object != self[index]
          will_change!

          super(index, type_casted_object)
          objects_before_type_cast[index] = object
        end
      else
        super(index, object)
      end
    end

    def << object
      if binded?
        will_change!
        super(type_cast_object(object))
        objects_before_type_cast << object
      else
        super(object)
      end
    end

    [:clear, :delete_at].each do |name|
      define_method(name) do |*args|
        return if (count = size) == 1

        if binded?
          super(*args)
          objects_before_type_cast.send(name, *args)

          will_change! if count != size
        else
          super(*args)
        end
      end
    end

    def method_missing(method, *args, &block)
      # Support find_by, e.g. find_by_id, find_by_code, return the object(s) that satisfy the conditions
      # find_by_id(1, 2, 3, 4), find_all_by_code('abc', 'xyz')
      if match = /find_(all_by|by)_([_a-zA-Z]\w*)/.match(method.to_s)
        finder = match.captures.first == 'all_by' ? :all : :first

        attribute_name = match.captures.last

        case finder
        when :first
          return self.find { |object| args.include?(object.send(attribute_name)) }
        when :all
          return self.select { |object| args.include?(object.send(attribute_name)) }
        end
      end

      super
    end
  end
end
