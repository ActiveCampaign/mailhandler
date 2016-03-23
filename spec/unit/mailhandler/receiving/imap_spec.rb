# encoding: utf-8
require 'spec_helper'

describe MailHandler::Receiving::IMAPChecker do

  let(:checker) { MailHandler::Receiving::IMAPChecker.new }

  it '.create' do

    expect(checker).to be_kind_of MailHandler::Receiving::Checker

  end

  it 'options' do

    expect(checker.search_options).to eq({:count=>50, :archive=>false})

  end

  context 'search options' do

    before(:each) do

        allow(checker).to receive(:init_retriever) { true }
        allow(checker).to receive(:find_emails) { []}

    end

    it 'by multiple search options' do

      checker.find({:by_subject => 'test', :by_content => 'test', :by_recipient => {:to => 'igor@example.com'}})
      expect(checker.search_options).to eq(
                                            {:count=>50,
                                             :archive=>false,
                                             :by_subject => 'test',
                                             :by_content => 'test',
                                             :by_recipient => {:to => 'igor@example.com'}})

    end

    it 'by_subject' do

      checker.find({:by_subject => 'test'})
      expect(checker.search_options).to eq({:count=>50, :archive=>false, :by_subject=>'test'})

    end

    it 'by_content' do

      checker.find({:by_content => 'test'})
      expect(checker.search_options).to eq({:count=>50, :archive=>false, :by_content => 'test'})

    end

    context 'invalid' do

      it 'by_test' do

        expect { checker.find({:by_test => 'test'}) }.to raise_error MailHandler::Error

      end


    end

    context 'archive' do

      it 'invalid' do

        expect { checker.find({:archive => 'test'}) }.to raise_error MailHandler::Error

      end

    end

  end

end