require 'spec_helper'

describe MailHandler::Sending::PostmarkBatchAPISender do

  subject { MailHandler::Sending::PostmarkBatchAPISender }

  let(:api_token) { '122878782' }

  it 'create' do

    sender = subject.new(api_token)

    aggregate_failures "init details" do
      expect(sender.api_token).to eq api_token
      expect(sender.type).to eq :postmark_api
      expect(sender.use_ssl).to be false
      expect(sender.host).to eq 'api.postmarkapp.com'
    end

  end

  it '.send' do

    sender = subject.new(api_token)
    expect{sender.send([Mail.new])}.to raise_error Postmark::InvalidApiKeyError

  end

  context 'invalid sending object' do

    it '.send with string parameter' do

      sender = subject.new(api_token)
      expect{sender.send('test')}.
          to raise_error StandardError, 'Invalid type error, only Array of Mail::Message object types for sending allowed'

    end

    it '.send with incorrect array parameter' do

      sender = subject.new(api_token)
      expect{sender.send([1,2,2])}.
          to raise_error StandardError, 'Invalid type error, only Array of Mail::Message object types for sending allowed'

    end

  end

end