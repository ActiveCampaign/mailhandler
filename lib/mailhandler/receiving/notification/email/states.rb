require_relative '../email'
require_relative '../../../errors'

module MailHandler
  module Receiving
    module Notification
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
      end

      # there was no delay
      class NoDelay < DelayState
        def notify(search)
          if Time.now - search.started_at >= context.min_time_to_notify
            context.change_state(Delay.new(context))
            context.notify(search)
          end
        end
      end

      # delay happened
      class Delay < DelayState
        def notify(search)
          if search.result
            context.change_state(Received.new(context))
            context.notify(search)
          elsif Time.now - search.started_at >= context.max_time_to_notify
            context.change_state(MaxDelay.new(context))
            context.notify(search)
          else
            send_notification_email(:delayed, search)
          end
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
