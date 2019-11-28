# frozen_string_literal: true

require 'spec_helper'

describe MailHandler::Receiving::Notification::Console do
  subject(:notification_console) { described_class }

  context 'notify of a delay' do
    it '.notify' do
      search = instance_double('Search', started_at: Time.now - 10)
      expect { notification_console.new.notify(search) }.to output(/.+email delay: 0(9|1)0 seconds/).to_stdout
    end
  end

  context 'not notify of a delay' do
    it '.notify' do
      search = instance_double('Search', started_at: Time.now + 5)
      expect { notification_console.new.notify(search) }.to output('').to_stdout
    end
  end
end
