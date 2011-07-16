module Jo
  module Helper
    def self.jo_family?(object)
      object.is_a?(::Jo::Hash) || object.is_a?(::Jo::Array) || object.is_a?(::Jo::Base)
    end

    # def self.to_jo_and_bind(object, meta, parent, attribute_name)
    def self.to_jo(object, meta)
      return if object.nil?

      # convert Hash to Jo::Hash || Array to Jo::Array || Hash to Jo.
      if meta.jo_family?
        object = JSON.parse(object) if object.class == ::String

        unless Helper.jo_family?(object)
          object = meta.class.new(object)

          if meta.hash? || meta.array?
            meta.object_jo_family? && object.map_values! do |value|
              value = meta.object_class.new(value) unless Helper.jo_family?(value)
              value
            end
          end
        end

      end

      object
    end

    def self.to_serialized_jo(object, meta)
      return if object.nil?

      if meta.jo_family?
        if meta.base?
          object = object.to_serialized_jo
        elsif meta.hash? || meta.array?
          object.compact_blank!

          if object.present?
            object = object.map_values(&:to_serialized_jo) if meta.object_base?
            object = object.map_values(&:to_s) if meta.object_date? || meta.object_time?
          end
        end
      end

      object = object.to_s if meta.date?
      object = object.getutc.strftime("%Y-%m-%d %H:%M:%S") if meta.time?

      object
    end

    def self.bind(object, meta, parent, attribute_name)
      return if object.nil?

      if meta.jo_family?
        if (meta.hash? || meta.array?) && meta.object_base?
          object.each_value { |value| value.bind_to(parent, attribute_name) }
        end

        object.bind_to(parent, attribute_name)
      end

      object
    end

    def self.type_cast(object, meta)
      return if object.nil?

      if object.is_a?(String)
        object = object.to_i if meta.integer?
        object = object.to_f if meta.float?
        object = Date.parse(object) if meta.date?
        object = Time.parse(object) if meta.time?

        if meta.boolean? && object[/^(true|false|t|f|yes|no|y|n|1|0)$/i]
          object = object[/^(true|t|yes|y|1)$/i] != nil
        end
      else
        object = object.to_s if meta.string?
      end

      if meta.hash? || meta.array?
         object = object.map_values do |value|
           type_cast_object(value, meta)
        end
      end

      object
    end

    def self.type_cast_object(object, meta)
      if object.is_a?(String)
        object = object.to_i if meta.object_integer?
        object = object.to_f if meta.object_float?
        object = Date.parse(object) if meta.object_date?
        object = Time.parse(object) if meta.object_time?

        if meta.object_boolean? && object[/^(true|false|t|f|yes|no|y|n|1|0)$/i]
          object = object[/^(true|t|yes|y|1)$/i] != nil
        end
      else
        object = object.to_s if meta.object_string?
      end

      if meta.object_jo_family? && (object.class == ::Hash || object.class == ::Array)
        object = meta.object_class.new(object)
      end

      object
    end

  end
end