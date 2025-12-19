# frozen_string_literal: true

require_relative "../lib/heysender/enums/anonymize_option"
require_relative "../lib/heysender/message_builder"
require_relative "../lib/heysender/hs_client"

include Heysender

# Build the client
client = Client.new(
  api_key: 'your-api-key',
  api_secret: 'your-api-secret'
)

begin
  # Build the message
   message = MessageBuilder.new(
      from_email: 'sender@yourdomain.com',
      from_name: 'Your Name',
      subject: 'Test Email',
      html: '<h1>Hello</h1><p>World!</p>'
   )
   .add_to('example@heysender.com', name: 'Mr. Sender')
   .add_bcc('example2@heysender.com')
   .tracking(false)
   .add_tag('tagTest', 'some tag')
   .anonymize_options([AnonymizeOption::CONTENT, AnonymizeOption::SUBJECT])
   .build()

   # Send the message
   puts client.send_message(message)

rescue => e
   # Handle exception
   puts e
end
