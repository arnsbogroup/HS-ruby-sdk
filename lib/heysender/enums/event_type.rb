module Heysender

  # Webhook event types
  module EventType
    QUEUED = 'queued'
    SENT = 'sent'
    ATTEMPT = 'attempt'
    SOFT_BOUNCE = 'soft_bounce'
    HARD_BOUNCE = 'hard_bounce'
    COMPLAINT = 'complaint'
    UNSUBSCRIBE = 'unsubscribe'
    OPEN = 'open'
    CLICK = 'click'

    # Get all event type values
    #
    # @return [Array<String>] All event type values
    def self.values
      [QUEUED, SENT, ATTEMPT, SOFT_BOUNCE, HARD_BOUNCE,
       COMPLAINT, UNSUBSCRIBE, OPEN, CLICK]
    end
  end
end
