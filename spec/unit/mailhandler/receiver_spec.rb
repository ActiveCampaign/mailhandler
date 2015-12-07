require 'spec_helper'

describe MailHandler::Receiver do

  context 'valid receiver' do

    let(:default_search_option) { {:by_subject => 'test'} }
    let(:receiving_duration) { 5 }
    let(:found_email) { Mail.new { subject 'test email' } }
    let(:checker) {
      checker = double('Checker')

      allow(checker).to receive(:find) { sleep receiving_duration; true }
      allow(checker).to receive(:search_result) { true }
      allow(checker).to receive(:found_emails) { [found_email] }
      checker

    }
    subject(:receiver) { MailHandler::Receiver.new(checker) }

    context 'att readers' do

      it { is_expected.to respond_to(:checker) }
      it { is_expected.to respond_to(:search) }
      it { is_expected.to respond_to(:search_max_duration) }

    end

    context 'att writters' do

      it { is_expected.to respond_to(:checker=) }
      it { is_expected.to respond_to(:search=) }
      it { is_expected.to respond_to(:search_max_duration=) }

    end

    it 'create' do

      is_expected.to be_kind_of MailHandler::Receiver

    end

    it '.find_email' do

      expect(receiver.find_email(default_search_option)).to be true

    end

    it '.search' do

      receiver.find_email(default_search_option)

      aggregate_failures "search details" do
        expect(receiver.search.options).to eq default_search_option
        expect(receiver.search.started_at).to be_within(1).of(Time.now - receiving_duration)
        expect(receiver.search.finished_at).to be_within(1).of(Time.now)
        expect(receiver.search.duration).to be_within(0.5).of(receiving_duration)
        expect(receiver.search.result).to be true
        expect(receiver.search.emails).to eq [found_email]
        expect(receiver.search.email).to eq found_email
      end

    end

    context '.search' do

      let(:checker) {
        checker = double('Checker')

        allow(checker).to receive(:find) { sleep 1; false }
        allow(checker).to receive(:search_result) { false }
        allow(checker).to receive(:found_emails) { [] }
        checker

      }

      [1,3,5].each do |duration|

        it "max duration - #{duration} seconds" do

          receiver.search_max_duration = duration
          receiver.find_email(default_search_option)

          expect(receiver.search.duration).to be_within(1).of(duration)

        end

      end

    end

  end

end