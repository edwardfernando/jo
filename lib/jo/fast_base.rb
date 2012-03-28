module Jo
  class FastBase
    [:id, :type].each do |method|
      undef_method(method) if respond_to?(method)
    end

    def initialize(objects = {})
      @attributes = objects
    end

    def method_missing(method, *params, &block)
      @attributes[method]
    end
  end
end