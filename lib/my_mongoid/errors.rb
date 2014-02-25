module MyMongoid
  class DuplicateFieldError < StandardError
  end

  class UnknownAttributeError < StandardError
  end

  class UnconfiguredDatabaseError <StandardError
  end

  class RecordNotFoundError <StandardError
  end
end
