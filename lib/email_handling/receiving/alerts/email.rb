module EmailHandling

  module Receiving

    module Alert

      class Email

        attr_accessor :context,
                      :current_state,
                      :min_time_to_alert,
                      :max_time_to_alert

        attr_reader :email_received, :email_sent_at

        def initialize(context, min_time_to_alert = 5, max_time_to_alert = 10)

          @min_time_to_alert = min_time_to_alert
          @max_time_to_alert = max_time_to_alert

          @context = context
          set_start_state

        end

        def notify

          set_start_state if Time.now - context.search.started_at < min_time_to_alert

          @email_sent_at = context.search.started_at
          @email_received = context.search.result
          alert

        end

        def alert

          current_state.alert(self)

        end

        def set_state(state)

          @current_state = state

        end

        private

        def set_start_state

          @current_state = Alert::NoDelay.new

        end

      end


      class DelayState

        attr_accessor :email_sent

        def set_email_sent

          @email_sent = true

        end

        def alert(context)

          raise StandardError, 'Alert interface has to be implemented'

        end

      end

      class NoDelay < DelayState

        def alert(context)

          if Time.now - context.email_sent_at > context.min_time_to_alert

            context.set_state(Delayed.new)
            context.alert

          end

        end

      end

      class Delayed < DelayState

        def alert(context)

          if context.email_received

            context.set_state(Received.new)
            context.alert

          elsif Time.now - context.email_sent_at > context.max_time_to_alert

            context.set_state(MaxDelayed.new)
            context.alert

          else

            puts 'alert_email_delayed' unless email_sent
            set_email_sent

          end

        end

      end

      class MaxDelayed < DelayState

        def alert(context)

          puts 'alert_email_max_delayed' unless email_sent
          set_email_sent

        end

      end

      class Received < DelayState

        def alert(context)

          puts 'alert_email_received' unless email_sent
          set_email_sent

        end

      end

    end

  end

end



