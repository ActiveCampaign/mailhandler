# frozen_string_literal: true

require_relative 'email/content'
require_relative 'email/states'
require_relative '../../errors'

module MailHandler
  module Receiving
    module Notification
      # notification in form of sent email
      class Email
        attr_accessor :sender,
                      :from,
                      :contacts,
                      :min_time_to_notify,
                      :max_time_to_notify

        attr_reader   :current_state

        def initialize(sender, from, to, min_time_to_notify = 60)
          @min_time_to_notify = min_time_to_notify

          @sender = sender
          @from = from
          @contacts = to
          init_state
          change_content_handler(EmailContent.new)
        end

        def notify(search)
          @max_time_to_notify = search.max_duration
          init_state if Time.now - search.started_at < min_time_to_notify
          @current_state.notify(search)
        end

        def change_state(state)
          @current_state = state
        end

        def send_email(type, search)
          verify_email_type(type)
          content = @content_handler.retrieve(type, search.options, Time.now - search.started_at, from, contacts)
          sender.send_email content
        end

        # Allow users to specify their own content classes.
        # Class must match by methods to the interface of MailHandler::Receiving::Notification::EmailContent
        def change_content_handler(content_handler)
          @content_handler = content_handler
        end

        private

        def init_state
          @current_state = Notification::NoDelay.new(self)
        end

        EMAIL_TYPES = %i[delayed received].freeze

        def verify_email_type(type)
          return if EMAIL_TYPES.include?(type)

          raise MailHandler::TypeError, "Incorrect type: #{type}, allowed types: #{EMAIL_TYPES}."
        end
      end
    end
  end
end
