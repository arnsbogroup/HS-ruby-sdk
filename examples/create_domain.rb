# frozen_string_literal: true

require_relative "../lib/heysender/hs_client"

include Heysender

# Build the client
client = Client.new(
  api_key: 'your-api-key',
  api_secret: 'your-api-secret'
)

begin
  # Create domain
  puts client.create_domain(
     url: 'example.hey sender.com'
  )

  # Get all domains on account
  puts client.get_domains()
rescue => e
  # Handle exception
  puts e
end
