# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mailhandler/version'

Gem::Specification.new do |s|
  s.name        = 'mailhandler'
  s.version     = MailHandler::VERSION
  s.platform    = Gem::Platform::RUBY
  s.license     = 'MIT'
  s.required_ruby_version = '>= 3.0.0'

  s.authors     = ['Igor Balos']
  s.email       = ['ibalosh@gmail.com', 'ibalos@activecampaign.com']

  s.summary     = 'Postmark email receiving and sending handler.'
  s.description = 'Use this gem to send emails through SMTP and Postmark API and check if email arrived.'

  s.files       = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  s.homepage    = 'https://github.com/ActiveCampaign/mailhandler'
  s.require_paths = ['lib']

  s.post_install_message = '
    ==================
    Thanks for installing the mailhandler gem.
    Review the README.md for implementation details and examples.
    ==================
  '

  s.required_rubygems_version = '>= 1.9.3'

  s.add_dependency 'mail', '>= 2.7.0'
  s.add_dependency 'postmark', '>= 1.7.0'
  s.metadata['rubygems_mfa_required'] = 'true'
end
