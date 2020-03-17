# frozen_string_literal: true

require_relative 'sending/smtp'
require_relative 'sending/api'
require_relative 'sending/api_batch'

module MailHandler
  # Class for sending email, and storing details about the sending.
  class Sender
    attr_accessor :dispatcher,
                  :sending,
                  :validate_response

    # @param [Time] - sending started at Time
    # @param [Time] - sending finished at Time
    # @param [int] - how long sending lasted, seconds
    # @param [Object] - sending response message
    # @param [Mail] - email/emails sent
    Sending = Struct.new(:started_at, :finished_at, :duration, :response, :email)

    # @param [Sending::Oblect] dispatcher - sender type used for sending email
    def initialize(dispatcher)
      @dispatcher = dispatcher
      @sending = Sending.new
      @validate_response = false
    end

    def send_email(email)
      init_sending_details(email)
      response = dispatcher.send(email)
      update_sending_details(response)
      check_response(response)
      response
    end

    def dispatcher_client
      dispatcher.client if dispatcher.respond_to?(:client)
    end

    private

    def check_response(response)
      return unless validate_response
      return if dispatcher.valid_response?(response)

      raise "Invalid sending response: #{response}"
    end

    def init_sending_details(email)
      @sending = Sending.new
      @sending.started_at = Time.now
      @sending.email = email
    end

    def update_sending_details(response)
      @sending.finished_at = Time.now
      @sending.duration = @sending.finished_at - @sending.started_at
      @sending.response = response
    end
  end
end
