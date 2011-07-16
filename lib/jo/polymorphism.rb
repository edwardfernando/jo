module Jo
  module Polymorphism
    extend ActiveSupport::Concern

    included do
      attribute :type_id, :integer

      validates_each :type_id do |base, attribute, value|
        base_class = base.class

        if base_class.types[base.type_id].nil?
          base.errors.add attribute, "#{base.type_id} is not in #{base_class}.types"
        end
      end

      class << self
        alias_method :new_without_polymorphism, :new

        def new(object = {})
          # if there is type_id information, we create object from that polymorphic class.
          type_id = object['type_id'] || object[:type_id]

          if self.meta.polymorphism?
            if type_id
              polymorphic_class = self.types[type_id.to_i]

              return polymorphic_class.new(object) if polymorphic_class && polymorphic_class != self
            else
              object[:type_id] = self.type_ids[self]
            end
          end

          self.new_without_polymorphism(object)
        end
      end
    end

    module ClassMethods
      # types => { :id => :polymorphic_class }
      def types(types = nil)
        if types
          @types = types
        else
          @types ||= self.superclass.meta.polymorphism? ? self.superclass.types.clone : {}
        end
      end

      # types => { :id => :polymorphic_class }
      # Return self (Class) it self so that we can have nice code:
      # jonize_many :jo_room_rates, :object_class => NewRoomRate.with_types(1 => ::RecentRoomRate, 2 => ::IndicativeRoomRate, 3 => ::LiveRoomRate)
      def with_types(types)
        @types = types
        self
      end

      def type_ids
        @type_ids ||= types.inject({}) { |type_ids, values| type_ids[values[1]] = values[0]; type_ids }
      end
    end

  end
end