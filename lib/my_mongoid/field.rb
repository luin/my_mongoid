module MyMongoid
  class Field
    attr_reader :name
    attr_reader :options
    def initialize(name, options)
      @name = name
      @options = options
    end
  end
end
