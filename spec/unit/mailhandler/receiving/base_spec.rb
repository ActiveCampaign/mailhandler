require 'spec_helper'

describe MailHandler::Receiving::Checker do
  subject(:receiving_checker) { described_class.new }

  it '.create' do
    expect(receiving_checker).to be_kind_of described_class
  end

  it 'init details' do
    aggregate_failures 'receiving details' do
      expect(receiving_checker.search_options).to eq(count: 50, archive: false)
      expect(receiving_checker.found_emails).to eq []
      expect(receiving_checker.search_result).to be false
    end
  end

  it '.find' do
    expect { receiving_checker.find(by_subject: 'test') }
      .to raise_error(MailHandler::InterfaceError, 'Find interface not implemented.')
  end

  it '.search_result' do
    expect(receiving_checker.search_result).to be false
  end
end
