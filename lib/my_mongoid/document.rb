module MyMongoid
  def self.models
    @models ||= []
  end

  module Document
    attr_reader :attributes
    module ClassMethods
      def is_mongoid_model?
        true
      end
    end

    def self.included(klass)
      MyMongoid.models << klass
      klass.extend ClassMethods
    end

    def initialize(attrs = nil)
      raise ArgumentError unless attrs.is_a?(Hash)
      @attributes = attrs
    end

    def read_attribute(key)
      @attributes[key]
    end

    def write_attribute(key, value)
      @attributes[key] = valus
    end

    def new_record?
      true
    end

  end
end
