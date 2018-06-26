require 'spec_helper'

describe MailHandler::Sending::PostmarkAPISender do
  subject { MailHandler::Sending::PostmarkAPISender }

  let(:api_token) { '122878782' }

  it 'create' do
    sender = subject.new(api_token)

    aggregate_failures 'init details' do
      expect(sender.api_token).to eq api_token
      expect(sender.type).to eq :postmark_api
      expect(sender.use_ssl).to be false
      expect(sender.host).to eq 'api.postmarkapp.com'
    end
  end

  it '.send - invalid auth' do
    sender = subject.new(api_token)
    expect { sender.send(Mail.new) }.to raise_error Postmark::InvalidApiKeyError
  end

  context 'invalid sending object' do
    it '.send' do
      sender = subject.new(api_token)
      expect { sender.send('test') }.to raise_error StandardError
    end
  end
end
