require "my_mongoid/version"
require "my_mongoid/document"
require "my_mongoid/field"
require "my_mongoid/errors"
require "my_mongoid/config"

module MyMongoid

  def self.configuration
    Configuration.instance
  end

  def self.configure
    if block_given?
      yield(configuration)
    else
      configuration
    end
  end

end
