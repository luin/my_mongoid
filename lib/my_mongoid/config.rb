require 'singleton'

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

  class Configuration
    include Singleton

    attr_accessor :host, :database
  end

end