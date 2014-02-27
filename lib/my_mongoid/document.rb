require "active_support/inflector"

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
            @alias[v.to_s] = key.to_s
          end
        end
      end

      def self.extended(klass)
        klass.field :_id, :as => :id
      end

      def collection_name
        self.name.tableize
      end

      def collection
        # todo
        MyMongoid.session[collection_name]
      end

      def create(attrs)
        new_record = self.new(attrs)
        new_record.save

        new_record.instance_variable_set :@is_changed, false

        new_record
      end

      def instantiate(attrs)
        record = self.new({})
        attrs.each_pair do |key, value|
          record.attributes[key] = value
        end
        record.instance_variable_set :@is_new_record, false
        record.instance_variable_set :@is_changed, false

        record
      end

      def find(selector)
        query = selector.is_a?(String) ? {"_id" => selector} : selector

        result = collection.find(query).first
        raise RecordNotFoundError unless result

        instantiate(result)
      end
    end

    def self.included(klass)
      MyMongoid.models << klass
      klass.extend ClassMethods
    end

    def method_missing(m, *args)
      @changed_attributes ||= {}

      m.match(/^(.*?)=?$/)
      if self.class.alias.key? $1
        field_name = self.class.alias[$1]
      else
        field_name = $1
      end
      return super unless self.class.fields.key? field_name


      if field_name != '_id' && @attributes[field_name] != args[0]
        @changed_attributes[field_name] = @attributes[field_name]
        @is_changed = true
      end

      if m.to_s == $1
        @attributes[field_name]
      else
        @attributes[field_name] = args[0]
      end
    end

    def initialize(attrs = nil)
      @is_new_record = true

      raise ArgumentError unless attrs.is_a?(Hash) ||
      self.class.alias.include?(k.to_sym)
      @attributes ||= {}
      process_attributes(attrs)

      unless attrs.key?('_id') || attrs.key?('id') ||
        attrs.key?(:_id) || attrs.key?(:id)
        self._id = BSON::ObjectId.new
      end
    end

    def read_attribute(key)
      self.send key
    end

    def write_attribute(key, value)
      self.send "#{key}=", value
    end

    def process_attributes(hash)
      hash.each_pair do |k,v|
        raise MyMongoid::UnknownAttributeError unless self.class.fields.include?(k.to_s) || self.class.alias.include?(k.to_s)
        self.send "#{k}=", v
      end
    end

    def attributes=(hash)
      process_attributes(hash)
    end

    def new_record?
      @is_new_record
    end


    def to_document
      @attributes
    end

    def save
      if @is_new_record == true
        self.class.collection.insert(to_document)
        @is_new_record = false
      else
        update_document
      end

      @changed_attributes = {}
      true
    end

    def changed_attributes
      @changed_attributes
    end

    def changed?
      @is_changed
    end

    def atomic_updates
      if changed? && !new_record?
        result = {"$set"=>{}}
        @changed_attributes.each_pair do |key, value|
          result["$set"][key] = read_attribute(key)
        end

        result
      else
        {}
      end
    end

    def update_document
      updates = atomic_updates

      unless updates.empty?
        selector = { "_id" => self.id }
        self.class.collection.find(selector).update(updates)
      end
    end

    def update_attributes(attrs)
      process_attributes(attrs)
      update_document
    end

    def delete
      self.class.collection.find({"_id" => self.id }).remove
    end

    def deleted?
      true
    end
  end
end
