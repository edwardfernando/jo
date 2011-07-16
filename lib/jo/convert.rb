module Jo
  module Convert
    extend ActiveSupport::Concern

    module ClassMethods
      # Set corresponding jo class, pass nil to get the current jo_class
      def jo_class(clazz = nil)
        clazz ? @jo_class = clazz : @jo_class
      end
    end

    # Convert current model to Jo
    def to_jo
      jo_class = self.class.jo_class

      raise 'set jo_class() inside your class first' if jo_class.nil?

      jo_class.new(self)
    end

  end
end