# frozen_string_literal: true

require_relative "../lib/heysender/enums/anonymize_option"
require_relative "../lib/heysender/hs_client"

include Heysender

# Build the client
client = Client.new(
  api_key: 'your-api-key',
  api_secret: 'your-api-secret'
)

begin
   # Get domains
   domains =  client.get_domains()
   domain = domains[0]

   # Create smtp user on a specific domain id
   puts client.create_smtp_user(
      domain['id'],
      smtp_email: "example@#{domain['url']}",
      anonymize_options: [AnonymizeOption::CONTENT, AnonymizeOption::SUBJECT]
      )

   # Get all smtp users on domain
   puts client.get_smtp_users(domain['id'])
rescue => e
   # Handle exception
   puts e
end
