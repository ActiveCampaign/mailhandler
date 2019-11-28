# frozen_string_literal: true

require_relative '../email'
require_relative '../../../errors'

module MailHandler
  module Receiving
    module Notification
      # base state
      class DelayState
        attr_accessor :context,
                      :notified

        def initialize(context)
          @context = context
        end

        def notification_fired
          @notified = true
        end

        def notify(_search)
          raise MailHandler::InterfaceError, 'notify(search) interface has to be implemented.'
        end

        protected

        def send_notification_email(type, search)
          return if notified

          context.send_email(type, search)
          notification_fired
        end

        def change_notification_state(search, state)
          context.change_state(state)
          context.notify(search)
        end
      end

      # there was no delay
      class NoDelay < DelayState
        def notify(search)
          return unless Time.now - search.started_at >= context.min_time_to_notify

          change_notification_state(search, Delay.new(context))
        end
      end

      # delay happened
      class Delay < DelayState
        def notify(search)
          if search.result
            change_notification_state(search, Received.new(context))
          elsif max_time_to_notify?(search)
            change_notification_state(search, MaxDelay.new(context))
          else
            send_notification_email(:delayed, search)
          end
        end

        private

        def max_time_to_notify?(search)
          Time.now - search.started_at >= context.max_time_to_notify
        end
      end

      # maximum delay checked happened
      class MaxDelay < DelayState
        def notify(search)
          send_notification_email(:delayed, search)
        end
      end

      # no more delays will be fired
      class Received < DelayState
        def notify(search)
          send_notification_email(:received, search)
        end
      end
    end
  end
end
