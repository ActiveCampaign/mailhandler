# frozen_string_literal: true

require 'spec_helper'

describe MailHandler::Receiving::IMAPChecker do
  let(:checker) { described_class.new }

  it '.create' do
    expect(checker).to be_a MailHandler::Receiving::Checker
  end

  it 'options' do
    expect(checker.search_options).to eq(count: 50, archive: false)
  end

  context 'search options' do
    before do
      allow(checker).to receive_messages(init_retriever: true, find_emails: [])
    end

    it 'by multiple search options' do
      checker.find(by_subject: 'test', by_content: 'test', by_recipient: { to: 'igor@example.com' })
      expect(checker.search_options).to eq(
        count: 50,
        archive: false,
        by_subject: 'test',
        by_content: 'test',
        by_recipient: { to: 'igor@example.com' }
      )
    end

    it 'by_subject' do
      checker.find(by_subject: 'test')
      expect(checker.search_options).to eq(count: 50, archive: false, by_subject: 'test')
    end

    it 'by_content' do
      checker.find(by_content: 'test')
      expect(checker.search_options).to eq(count: 50, archive: false, by_content: 'test')
    end

    context 'invalid' do
      it 'by_test' do
        expect { checker.find(by_test: 'test') }.to raise_error MailHandler::Error
      end
    end

    context 'archive' do
      it 'invalid' do
        expect { checker.find(archive: 'test') }.to raise_error MailHandler::Error
      end
    end
  end
end
