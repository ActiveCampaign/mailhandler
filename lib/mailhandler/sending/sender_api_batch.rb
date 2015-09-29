require_relative 'sender_api.rb'

module MailHandler

  module Sending

    class PostmarkBatchAPISender < PostmarkAPISender

      def send(emails)

        client = setup_sending_client
        client.deliver_messages(emails)

      end

    end

  end

end
