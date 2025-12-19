# frozen_string_literal: true

module Heysender
  class MessageBuilder

    attr_reader :data

    # Initialize a new MessageBuilder
    #
    # @param from_email [String] Sender email address
    # @param from_name [String] Sender name
    # @param subject [String] Email subject
    # @param html [String] HTML body content
    def initialize(from_email:, from_name:, subject:, html:)
      @data = {
        from_email: from_email,
        from_name: from_name,
        subject: subject,
        html: html,
        to: []
      }
    end

    # Set plain text body
    #
    # @param text [String] Plain text content
    # @return [MessageBuilder] self for chaining
    def text(text)
      @data[:text] = text
      self
    end

    # Add TO recipient
    #
    # @param email [String] Recipient email
    # @param name [String, nil] Recipient name (optional)
    # @return [MessageBuilder] self for chaining
    def add_to(email, name: nil)
      recipient = { email: email }
      recipient[:name] = name if name
      @data[:to] << recipient
      self
    end

    # Add CC recipient
    #
    # @param email [String] Recipient email
    # @param name [String, nil] Recipient name (optional)
    # @return [MessageBuilder] self for chaining
    def add_cc(email, name: nil)
      @data[:cc] ||= []
      recipient = { email: email }
      recipient[:name] = name if name
      @data[:cc] << recipient
      self
    end

    # Add BCC recipient
    #
    # @param email [String] Recipient email
    # @return [MessageBuilder] self for chaining
    def add_bcc(email)
      @data[:bcc] ||= []
      @data[:bcc] << email
      self
    end

    # Set reply-to address
    #
    # @param reply_to [String, Array] Single email or array of recipients
    # @return [MessageBuilder] self for chaining
    def reply_to(reply_to)
      @data[:reply_to] = reply_to
      self
    end

    # Add attachment
    #
    # @param name [String] Filename with extension
    # @param base64_content [String] Base64 encoded file content
    # @return [MessageBuilder] self for chaining
    def add_attachment(name, base64_content)
      @data[:attachments] ||= []
      @data[:attachments] << {
        name: name,
        content: base64_content
      }
      self
    end

    # Add custom tag
    #
    # @param key [String] Tag key
    # @param value [String] Tag value
    # @return [MessageBuilder] self for chaining
    def add_tag(key, value)
      @data[:tags] ||= []
      @data[:tags] << {
        key: key,
        value: value
      }
      self
    end

    # Add custom header
    #
    # @param key [String] Header key
    # @param value [String] Header value
    # @return [MessageBuilder] self for chaining
    def add_header(key, value)
      @data[:headers] ||= []
      @data[:headers] << {
        key: key,
        value: value
      }
      self
    end

    # Set custom content for bulk messaging
    #
    # @param content [Hash] Hash mapping recipient emails to custom variables
    # @return [MessageBuilder] self for chaining
    def custom_content(content)
      @data[:custom_content] = content
      self
    end

    # Enable or disable tracking
    #
    # @param enabled [Boolean] Whether to enable tracking
    # @return [MessageBuilder] self for chaining
    def tracking(enabled)
      @data[:tracking] = enabled
      self
    end

    # Enable or disable list-unsubscribe header
    #
    # @param enabled [Boolean] Whether to enable list-unsubscribe
    # @return [MessageBuilder] self for chaining
    def list_unsubscribe(enabled)
      @data[:list_unsubscribe] = enabled
      self
    end

    # Set message retention time in days
    #
    # @param days [Integer] Number of days to retain message
    # @return [MessageBuilder] self for chaining
    def retention_time(days)
      @data[:retention_time] = days
      self
    end

    # Set anonymization options
    #
    # @param options [Array<String>] Fields to anonymize (use AnonymizeOption constants or strings)
    # @return [MessageBuilder] self for chaining
    def anonymize_options(options)
      @data[:anonymize_options] = options
      self
    end

    # Set custom webhook for this message
    #
    # @param url [String] Webhook URL
    # @param events [Array<String>] Events to trigger webhook (use EventType constants or strings)
    # @return [MessageBuilder] self for chaining
    def webhook(url, events)
      @data[:webhook] = {
        url: url,
        events: events
      }
      self
    end

    # Build and return the message data hash
    #
    # @return [Hash] Complete message data
    def build
      @data
    end
  end
end
