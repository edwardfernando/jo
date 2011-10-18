module Jo
  class Hash < ::Hash
    include Jo::Dirty

    alias_method :each_key_value, :each

    def initialize(objects = nil)
      objects.each { |key, value| self[key.to_sym] = value } if objects.is_a?(::Hash) && objects.present?
    end

    def map_values
      hash = self.class.new
      self.each { |key, value| hash[key] = yield(value) }
      hash
    end

    def map_values!
      self.each { |key, value| self[key] = yield(value) }
    end

    def compact_blank!
      self.delete_if { |key, value| value != false && value.blank? }
    end

    def merge!(objects)
      objects.each do |key, object|
        self[key] = object
      end
    end

    def []=(key, object)
      if binded?
        type_casted_object = type_cast_object(object)

        if type_casted_object != self[key]
          will_change!

          super(key, type_casted_object)
          objects_before_type_cast[key] = object
        end
      else
        super(key, object)
      end
    end

    def clear
      return if (count = self.size) == 0

      if binded?
        super
        objects_before_type_cast.clear

        will_change! if count != self.size
      else
        super
      end
    end

    def delete_if(&block)
      return if (count = self.size) == 0

      if binded?
        each do |key, value|
          if block.call(key, value) == true
            delete(key)
            objects_before_type_cast.delete(key)
          end
        end

        will_change! if count != self.size
      else
        super(&block)
      end
    end

  end
end