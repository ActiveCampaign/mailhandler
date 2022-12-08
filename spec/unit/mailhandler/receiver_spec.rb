# frozen_string_literal: true

require 'spec_helper'

describe MailHandler::Receiver do
  context 'valid receiver' do
    subject(:receiver) { described_class.new(checker) }

    let(:default_search_option) { { by_subject: 'test' } }
    let(:receiving_duration) { 5 }
    let(:found_email) { Mail.new { subject :"test email" } }
    let(:checker) do
      checker = instance_double('Checker')

      allow(checker).to receive(:find) do
        sleep receiving_duration
        true
      end

      allow(checker).to receive(:search_result).and_return(true)
      allow(checker).to receive(:found_emails) { [found_email] }
      allow(checker).to receive(:reset_found_emails).and_return([])
      allow(checker).to receive(:start).and_return(nil)
      allow(checker).to receive(:stop).and_return(nil)
      checker
    end

    context 'att readers' do
      it { is_expected.to respond_to(:checker) }
      it { is_expected.to respond_to(:search) }
      it { is_expected.to respond_to(:max_search_duration) }
    end

    context 'att writters' do
      it { is_expected.to respond_to(:checker=) }
      it { is_expected.to respond_to(:search=) }
      it { is_expected.to respond_to(:max_search_duration=) }
    end

    it 'create' do
      expect(receiver).to be_kind_of described_class
    end

    it '.find_email' do
      expect(receiver.find_email(default_search_option)).to be true
    end

    it '.search' do
      receiver.find_email(default_search_option)

      aggregate_failures 'search details' do
        expect(receiver.search.options).to eq default_search_option
        expect(receiver.search.started_at).to be_within(1).of(Time.now - receiving_duration)
        expect(receiver.search.finished_at).to be_within(1).of(Time.now)
        expect(receiver.search.duration).to be_within(0.5).of(receiving_duration)
        expect(receiver.search.result).to be true
        expect(receiver.search.emails).to eq [found_email]
        expect(receiver.search.email).to eq found_email
      end
    end

    describe '.search not found' do
      let(:checker) do
        checker = instance_double('Checker')

        allow(checker).to receive(:find).and_return(false)
        allow(checker).to receive(:search_result).and_return(false)
        allow(checker).to receive(:found_emails).and_return([])
        allow(checker).to receive(:reset_found_emails).and_return([])
        allow(checker).to receive(:start).and_return(nil)
        allow(checker).to receive(:stop).and_return(nil)
        checker
      end

      it 'raise error' do
        receiver.max_search_duration = 3
        receiver.validate_result = true
        expect { receiver.find_email(default_search_option) }
          .to raise_error(MailHandler::SearchEmailError,
                          'Email searched by {:by_subject=>"test"} not found for 3 seconds.')
      end

      it 'do not raise error' do
        receiver.max_search_duration = 3
        receiver.validate_result = false
        expect(receiver.find_email(default_search_option)).to be false
      end
    end

    describe '.search' do
      let(:checker) do
        checker = instance_double('Checker')

        allow(checker).to receive(:find) do
          sleep 1
          false
        end
        allow(checker).to receive(:search_result).and_return(true)
        allow(checker).to receive(:found_emails).and_return([])
        allow(checker).to receive(:reset_found_emails).and_return([])
        allow(checker).to receive(:start).and_return(nil)
        allow(checker).to receive(:stop).and_return(nil)
        checker
      end

      [1, 3, 5].each do |duration|
        it "max duration - #{duration} seconds" do
          receiver.max_search_duration = duration
          receiver.find_email(default_search_option)

          expect(receiver.search.duration).to be_within(1).of(duration)
        end
      end
    end
  end
end
