require 'spec_helper'

describe MailHandler::Receiving::Notification::Console do

  subject { MailHandler::Receiving::Notification::Console  }

  context 'notify of a delay' do

    it '.notify' do

      search = double('Search', :started_at => Time.now - 10)
      expect{ subject.new.notify(search) }.to output(/.+email delay: 0(9|1)0 seconds/).to_stdout

    end

  end

  context 'not notify of a delay' do

    it '.notify' do

      search = double('Search', :started_at => Time.now + 5)
      expect{ subject.new.notify(search) }.to output('').to_stdout

    end

  end

end