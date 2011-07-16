module Jo
  module Dirty
    extend ActiveSupport::Concern

    included do
      include ActiveModel::Dirty
    end

    def bind_to(parent, attribute_name)
      @parent = parent
      @attribute_name = attribute_name
    end

    def binded?
      @parent && @attribute_name
    end

    def will_change!
      if binded?
        @parent.send('will_change!') if @parent.class.meta.jo_family?
        @parent.send("#{@attribute_name}_will_change!")
      end
    end

    def type_cast_object(object)
      binded? ? @parent.send("type_cast_#{@attribute_name}_object", object) : object
    end

    def objects_before_type_cast
      @parent.send("#{@attribute_name}_before_type_cast") if binded?
    end

  end
end