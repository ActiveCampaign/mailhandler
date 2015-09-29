module MailHandler

  module Receiving

    module Observer

      def init_observer

        @observers = Array.new

      end

      def add_observer(observer)

        @observers ||= Array.new
        @observers << observer

      end

      def delete_observer(observer)

        @observers.delete(observer) if @observers

      end

      def notify_observers(search)

        @observers.each { |observer| observer.notify(search) } if @observers

      end

    end

  end

end

