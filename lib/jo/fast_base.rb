module Jo
  class FastBase
    def initialize(objects = {})
      @attributes = objects
    end

    def method_missing(method)
      @attributes[method]
    end
  end
end