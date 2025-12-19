module Heysender

  # Anonymization options for email privacy compliance
  module AnonymizeOption
    NONE = 'none'
    ALL = 'all'
    RECIPIENT = 'recipient'
    SUBJECT = 'subject'
    CONTENT = 'content'

    # Get all anonymization option values
    #
    # @return [Array<String>] All anonymization option values
    def self.values
      [NONE, ALL, RECIPIENT, SUBJECT, CONTENT]
    end
  end
end
