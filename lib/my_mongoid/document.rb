module MyMongoid
  def self.models
    @models ||= []
  end

  module Document
    attr_reader :attributes
    module ClassMethods
      attr_reader :fields
      attr_reader :alias
      def is_mongoid_model?
        true
      end

      def field(key, options = {})
        @fields ||= {}
        @alias ||= {}
        if @fields[key.to_s]
          raise MyMongoid::DuplicateFieldError
        end
        @fields[key.to_s] = MyMongoid::Field.new(key.to_s, options)
        options.each_pair do |k, v|
          if k == :as
            @alias ||= {}
            @alias[v] = key
          end
        end
      end

      def self.extended(klass)
        klass.field :_id, :as => :id
      end

    end

    def self.included(klass)
      MyMongoid.models << klass
      klass.extend ClassMethods
    end

    def method_missing(m, *args)
      m.match(/^(.*?)=?$/)
      if self.class.alias.key? $1
        field_name = self.class.alias[$1]
      else
        field_name = $1
      end
      return super unless self.class.fields.key? field_name
      if m.to_s == field_name
        @attributes[field_name]
      else
        @attributes[field_name] = args[0]
      end
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
