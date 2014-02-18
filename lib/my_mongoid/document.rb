module MyMongoid
  def self.models
    @models ||= []
  end

  class Field
    attr_reader :name
    def initialize(name)
      @name = name
    end
  end

  class DuplicateFieldError < StandardError
  end

  class UnknownAttributeError < StandardError
  end

  module Document
    attr_reader :attributes
    module ClassMethods
      attr_reader :fields
      def is_mongoid_model?
        true
      end

      def field(key)
        @fields ||= {}
        if @fields[key.to_s]
          raise MyMongoid::DuplicateFieldError
        end
        @fields[key.to_s] = MyMongoid::Field.new(key.to_s)
        self.class_eval("def #{key};@attributes['#{key}'];end")
        self.class_eval("def #{key}=(v);@attributes['#{key}']=v;end")
      end

      def self.extended(klass)
        klass.field :_id
      end

    end

    def self.included(klass)
      MyMongoid.models << klass
      klass.extend ClassMethods
    end

    def initialize(attrs = nil)
      raise ArgumentError unless attrs.is_a?(Hash)
      @attributes ||= {}
      process_attributes(attrs)
    end

    def read_attribute(key)
      @attributes[key]
    end

    def write_attribute(key, value)
      @attributes[key] = value
    end

    def process_attributes(hash)
      hash.each_pair do |k,v|
        raise MyMongoid::UnknownAttributeError unless self.class.fields.include? k.to_s
        self.send "#{k}=", v
      end
    end

    def attributes=(hash)
      process_attributes(hash)
    end

    def new_record?
      true
    end


  end
end
