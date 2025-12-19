module Heysender

  # Suppression list types
  module SuppressionType
    BOUNCES = 'bounce'
    UNSUBSCRIBES = 'unsubscribe'
    COMPLAINTS = 'complaint'

    # Get all suppression type values
    #
    # @return [Array<String>] All suppression type values
    def self.values
      [BOUNCES, UNSUBSCRIBES, COMPLAINTS]
    end
  end
end
