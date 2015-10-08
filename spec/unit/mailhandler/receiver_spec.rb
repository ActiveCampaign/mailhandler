require 'spec_helper'

describe MailHandler::Receiver do

  subject { MailHandler::Receiver }
  let(:default_search_option) { {:by_subject => 'test'} }
  let(:receiving_duration) { 5 }
  let(:checker) {
    checker = double('Checker')

    allow(checker).to receive(:find) { sleep receiving_duration ; true }
    allow(checker).to receive(:search_result) { true }
    allow(checker).to receive(:found_emails) { [] }
    checker

  }
  
  it '.find_email' do

    receiver = subject.new(checker)
    expect(receiver.find_email(default_search_option)).to be true

  end

  it '.search object' do

    receiver = subject.new(checker)
    receiver.find_email(default_search_option)

    aggregate_failures "search details" do
      expect(receiver.search.options).to eq default_search_option
      expect(receiver.search.started_at).to be_within(1).of(Time.now - receiving_duration)
      expect(receiver.search.finished_at).to be_within(1).of(Time.now)
      expect(receiver.search.duration).to be_within(0.5).of(receiving_duration)
      expect(receiver.search.result).to be true
      expect(receiver.search.emails).to eq []
    end

  end

end