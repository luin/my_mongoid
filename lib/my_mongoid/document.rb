module MyMongoid
  def self.models
    @models ||= []
  end

  module Document

    module ClassMethods
      def is_mongoid_model?
        true
      end
    end

    def self.included(klass)
      MyMongoid.models << klass
      klass.extend ClassMethods
    end

  end
end
