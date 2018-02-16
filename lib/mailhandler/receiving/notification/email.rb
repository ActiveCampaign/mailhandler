require_relative 'email/content'
require_relative 'email/states'
require_relative '../../errors'

module MailHandler

  module Receiving

    module Notification

      class Email

        attr_reader   :sender,
                      :from,
                      :contacts,
                      :min_time_to_notify,
                      :max_time_to_notify,
                      :current_state

        def initialize(sender, from, to, min_time_to_notify = 60)

          @min_time_to_notify = min_time_to_notify

          @sender = sender
          @from = from
          @contacts = to
          init_state
          set_content_handler(EmailContent.new)

        end

        def notify(search)

          @max_time_to_notify = search.max_duration
          init_state if Time.now - search.started_at < min_time_to_notify
          @current_state.notify(search)

        end

        def set_state(state)

          @current_state = state

        end

        def send_email(type, search)

          verify_email_type(type)
          content = @content_handler.retrieve(type, search.options, Time.now - search.started_at, from, contacts)
          sender.send_email content

        end

        # Allow users to specify their own content classes.
        # Class must match by methods to the interface of MailHandler::Receiving::Notification::EmailContent
        def set_content_handler(content_handler)
          @content_handler = content_handler
        end


        private

        def init_state

          @current_state = Notification::NoDelay.new(self)

        end

        EMAIL_TYPES = [:delayed, :received]

        def verify_email_type(type)

          raise MailHandler::TypeError, "Incorrect type: #{type}, allowed types: #{EMAIL_TYPES}." unless EMAIL_TYPES.include? type

        end

      end

    end

  end

end



