require "moped"

module MyMongoid

  def self.session
    raise UnconfiguredDatabaseError unless configuration.host && configuration.database

    @session ||= Moped::Session.new([ configuration.host ])
    @session.use(configuration.database)
    @session
  end
  
  module Session
  end
end