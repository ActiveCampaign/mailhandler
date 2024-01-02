# frozen_string_literal: true

module Mail
  # wrapper methods to support sending raw email, where recipient and sender can be custom
  class SMTP
    def deliver_raw!(raw_source_email, smtp_from, smtp_to)
      response = start_smtp_session do |smtp|
        Mail::SMTPConnection.new(connection: smtp, return_response: true)
                            .deliver_raw!(raw_source_email, smtp_from, smtp_to)
      end

      settings[:return_response] ? response : self
    end
  end

  # wrapper methods to support sending raw email, where recipient and sender can be custom
  class SMTPConnection
    def deliver_raw!(raw_source_email, smtp_from, smtp_to)
      response = smtp.sendmail(dot_stuff(raw_source_email), smtp_from, smtp_to)

      settings[:return_response] ? response : self
    end
  end
end
