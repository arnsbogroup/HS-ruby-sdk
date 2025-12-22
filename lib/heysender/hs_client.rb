# frozen_string_literal: true

require_relative 'hs_exception'
require 'net/http'
require 'base64'
require 'json'
require 'uri'

module Heysender
  # Main client for interacting with the Heysender API
  class Client
    attr_reader :api_key, :api_secret, :base_url

    # Initialize a new Heysender client
    #
    # @param api_key [String] Your Heysender API key
    # @param api_secret [String] Your Heysender API secret
    # @param base_url [String] Base URL for the API (default: https://app.heysender.com)
    def initialize(api_key:, api_secret:, base_url: 'https://app.heysender.com')
      @api_key = api_key
      @api_secret = api_secret
      @base_url = base_url
    end

    # ==================== DOMAIN METHODS ====================

    # Get list of domains
    #
    # @return [Array<Hash>] List of domains
    def get_domains
      request(:get, '/api/domains')
    end

    # Create a new domain
    #
    # @param url [String] Domain URL
    # @param custom_selector [String, nil] Custom DKIM selector (optional)
    # @param dkim_key [String, nil] Custom DKIM private key (optional)
    # @return [Hash] Created domain data
    def create_domain(url:, custom_selector: nil, dkim_key: nil)
      body = { url: url }
      body[:custom_selector] = custom_selector if custom_selector
      body[:dkim_key] = dkim_key if dkim_key

      request(:post, '/api/domains', body)
    end

    # Update domain with new DKIM key
    #
    # @param domain [String] Domain name
    # @param dkim_key [String] New DKIM private key
    # @return [Hash] Response data
    def update_domain(domain, dkim_key)
      request(:put, "/api/domains/#{domain}", { dkim_key: dkim_key })
    end

    # Delete a domain
    #
    # @param domain [String] Domain name
    # @return [Hash] Response data
    def delete_domain(domain)
      request(:delete, "/api/domains/#{domain}")
    end

    # Validate domain SPF and DKIM
    #
    # @param domain [String] Domain name
    # @return [Hash] Validation status
    def validate_domain(domain)
      request(:get, "/api/domains/#{domain}/validate")
    end

    # ==================== SMTP USER METHODS ====================

    # Get SMTP users for a domain
    #
    # @param domain_id [Integer] Domain ID
    # @return [Array<Hash>] List of SMTP users
    def get_smtp_users(domain_id)
      request(:get, "/api/smtp/#{domain_id}")
    end

    # Create SMTP user
    #
    # @param domain_id [Integer] Domain ID
    # @param smtp_email [String] SMTP email address
    # @param anonymize_options [Array<String>] Anonymization options (use AnonymizeOption constants or strings)
    # @return [Array<Hash>] Created SMTP user with password
    def create_smtp_user(domain_id, smtp_email:, anonymize_options: [AnonymizeOption::NONE])
      body = {
        smtp_email: smtp_email,
        anonymize_options: anonymize_options
      }

      request(:post, "/api/smtp/#{domain_id}", body)
    end

    # Delete SMTP user
    #
    # @param domain_id [Integer] Domain ID
    # @param user_id [Integer] SMTP user ID
    # @return [Hash] Response data
    def delete_smtp_user(domain_id, user_id)
      request(:delete, "/api/smtp/#{domain_id}/#{user_id}")
    end

    # Generate new password for SMTP user
    #
    # @param domain_id [Integer] Domain ID
    # @param user_id [Integer] SMTP user ID
    # @return [Array<Hash>] New password data
    def reset_smtp_password(domain_id, user_id)
      request(:get, "/api/smtp/#{domain_id}/#{user_id}/newpassword")
    end

    # ==================== WEBHOOK METHODS ====================

    # Get webhooks for a domain
    #
    # @param domain [String] Domain name
    # @return [Array<Hash>] List of webhooks
    def get_webhooks(domain)
      request(:get, "/api/webhooks/#{domain}")
    end

    # Get specific webhook
    #
    # @param domain [String] Domain name
    # @param webhook_id [Integer] Webhook ID
    # @return [Hash] Webhook data
    def get_webhook(domain, webhook_id)
      request(:get, "/api/webhooks/#{domain}/#{webhook_id}")
    end

    # Create webhook
    #
    # @param domain [String] Domain name
    # @param url [String] Webhook URL
    # @param events [Array<String>] Event triggers (use EventType constants or strings)
    # @return [Hash] Created webhook data
    def create_webhook(domain, url:, events: [])
      body = { url: url }

      EventType.values.each do |event|
        body[event.to_sym] = events.include?(event)
      end

      request(:post, "/api/webhooks/#{domain}", body)
    end

    # Update webhook
    #
    # @param domain [String] Domain name
    # @param webhook_id [Integer] Webhook ID
    # @param url [String] Webhook URL
    # @param events [Array<String>] Event triggers (use EventType constants or strings)
    # @return [Hash] Response data
    def update_webhook(domain, webhook_id, url:, events: [])
      body = { url: url }

      EventType.values.each do |event|
        body[event.to_sym] = events.include?(event)
      end

      request(:put, "/api/webhooks/#{domain}/#{webhook_id}", body)
    end

    # Delete webhook
    #
    # @param domain [String] Domain name
    # @param webhook_id [Integer] Webhook ID
    # @return [Hash] Response data
    def delete_webhook(domain, webhook_id)
      request(:delete, "/api/webhooks/#{domain}/#{webhook_id}")
    end

    # ==================== MESSAGE METHODS ====================

    # Send an email message
    #
    # @param message_data [Hash] Message data hash
    # @return [Array<Hash>] Message responses with status and message IDs
    def send_message(message_data)
      request(:post, '/api/message', message_data)
    end

    # Get message information
    #
    # @param message_id [String] Message ID
    # @return [Hash] Message information
    def get_message(message_id)
      request(:get, "/api/message/#{message_id}")
    end

    # Get message information for specific recipient
    #
    # @param message_id [String] Message ID
    # @param recipient [String] Recipient email
    # @return [Hash] Message information
    def get_message_by_recipient(message_id, recipient)
      request(:get, "/api/message/#{message_id}/#{recipient}")
    end

    # ==================== SUPPRESSION METHODS ====================

    # Get suppressions by domain and type
    #
    # @param domain [String] Domain name
    # @param type [String] Suppression type (use SuppressionType constants: 'bounces', 'unsubscribes', 'complaints')
    # @return [Hash] Paginated suppression list
    def get_suppressions(domain, type)
      request(:get, "/api/suppressions/#{domain}/#{type}")
    end

    # Remove email from bounce suppressions
    #
    # @param domain [String] Domain name
    # @param email [String] Email address to remove
    # @return [Hash] Response data
    def remove_bounce(domain, email)
      request(:delete, "/api/suppressions/#{domain}/bounce/#{email}")
    end

    private

    # Make an HTTP request to the API
    #
    # @param method [Symbol] HTTP method (:get, :post, :put, :delete)
    # @param endpoint [String] API endpoint
    # @param body [Hash, nil] Request body
    # @return [Hash, Array] Response data
    # @raise [Heysender::Error] If the request fails
    def request(method, endpoint, body = nil)
      uri = URI.join(@base_url, endpoint)

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      http.read_timeout = 30
      http.open_timeout = 30

      request = case method
                when :get
                  Net::HTTP::Get.new(uri)
                when :post
                  Net::HTTP::Post.new(uri)
                when :put
                  Net::HTTP::Put.new(uri)
                when :delete
                  Net::HTTP::Delete.new(uri)
                else
                  raise ArgumentError, "Unsupported HTTP method: #{method}"
                end

      # Set headers
      credentials = Base64.strict_encode64("#{@api_key}:#{@api_secret}")
      request['Authorization'] = "Basic #{credentials}"
      request['Content-Type'] = 'application/json'
      request['Accept'] = 'application/json'
      request['User-Agent'] = 'HS-ruby-sdk/0.9'

      # Set body for POST and PUT requests
      request.body = body.to_json if body && %i[post put].include?(method)

      # Execute request
      response = http.request(request)

      # Handle response
      handle_response(response)
    end

    # Handle HTTP response
    #
    # @param response [Net::HTTPResponse] HTTP response
    # @return [Hash, Array] Parsed response data
    # @raise [Heysender::Error] If response indicates an error
    def handle_response(response)
      case response
      when Net::HTTPSuccess
        return {} if response.body.nil? || response.body.empty?
        JSON.parse(response.body)
      when Net::HTTPClientError, Net::HTTPServerError
        error_message = begin
          JSON.parse(response.body)
        rescue JSON::ParserError
          response.body
        end

        raise Error.new(
          "API Error (#{response.code}): #{error_message}",
          response.code.to_i,
          response.body
        )
      else
        raise Error.new(
          "Unexpected response: #{response.code} #{response.message}",
          response.code.to_i,
          response.body
        )
      end
    end
  end
end
