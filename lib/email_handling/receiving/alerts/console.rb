module EmailHandling

  module Receiving

    module Alert

      class Console

        def initialize(context)

          @context = context

        end

        def notify

          output_delay Time.now - @context.search.started_at

        end

        private

        module Seconds

          TO_SHOW = 10

        end

        # print to screen delay length
        def output_delay(delay)

          delay_seconds = delay.to_i
          output(delay_seconds) if [0,1].include? (delay_seconds % Seconds::TO_SHOW)

        end

        # print to screen delay length
        def output(delay)

          puts "  delay: #{'%03d' % delay} seconds"

        end

      end

    end

  end

end
