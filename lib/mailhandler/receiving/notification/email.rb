require_relative 'email/content'
require_relative 'email/states'
require_relative '../../errors'

module MailHandler

  module Receiving

    module Notification

      class Email

        attr_reader   :sender,
                      :contacts,
                      :min_time_to_notify,
                      :max_time_to_notify

        def initialize(sender, contacts, min_time_to_notify = 60)

          @min_time_to_notify = min_time_to_notify

          @sender = sender
          @contacts = contacts
          init_state

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
          content = EmailContent.send("email_#{type}",search.options, Time.now - search.started_at, sender.dispatcher.username, contacts)
          sender.send_email content

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



