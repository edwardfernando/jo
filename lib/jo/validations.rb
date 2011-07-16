module Jo
  module Validations
    extend ActiveSupport::Concern

    module ClassMethods
      def validates_numericality_of_values(*attrs)
        numericality_validator_options = attrs.last.is_a?(::Hash) ? attrs.pop : {}
        numericality_validator_options[:attributes] = attrs

        validator = ActiveModel::Validations::NumericalityValidator.new(numericality_validator_options)

        validates_each attrs do |model, attribute_name, objects|
          attribute_meta = meta.attributes[attribute_name]
          objects = model.send("#{attribute_name}_before_type_cast")

          attribute_meta.array? && objects.each_with_index do |object, index|
            validator.validate_each(model, "#{attribute_name}:#{index}", object)
          end

          attribute_meta.hash? && objects.each do |key, object|
            validator.validate_each(model, "#{attribute_name}:#{key}", object)
          end
        end
      end

      def validates_boolean_of(*attrs)
        validates_inclusion_of attrs, :in => [true, false]
      end

      def validate_jo_family(name, meta)
        class_eval do
          validate "validate_#{name}"

          define_method("validate_#{name}") do
            object = send(name)

            if object.present?
              self.errors.merge!(object.errors) if meta.base? && object.invalid?

              if (meta.array? || meta.hash?) && meta.object_base?
                object.each_value { |value| self.errors.merge!(value.errors) if value.invalid? }
              end
            end

          end
        end
      end

    end

  end
end