# MailHandler Gem

[![Build Status](https://travis-ci.org/ibalosh/MailHandler.svg?branch=master)](https://travis-ci.org/ibalosh/MailHandler)

This gem represents a simple library which allows you to send email and check email delivery. 
The library supports sending SMTP, Postmark API or Postmark Batch API, checking email delivery by IMAP, or by folder, 
if you have a local mailbox. 

# Install the gem

With Bundler:

``` ruby
gem 'mailhandler'
``` 

Without Bundler:

``` bash
gem install mailhandler
``` 

# Email arrival testing 

## Configure local mailbox email to check

``` ruby
email_receiver = MailHandler::Handler.receiver(:folder) do |checker|
    checker.inbox_folder = folder_of_your_inbox
    checker.archive_folder = folder_of_your_inbox_archive_folder
end
```  

## Configure imap mailbox email to check
 
``` ruby
email_receiver = MailHandler::Handler.receiver(:imap) do |checker|
    checker.imap_details(
        address,
        port,
        username,
        password,
        use_ssl
    )
end
``` 
Email receiving handler will be referenced below as `email_receiver`

## Searching for email

Once you have setup mailbox checking type, you can search for email like this:

``` ruby
email_receiver.find_email(:by_subject => email.subject, :archive => true)
``` 

You can search imap mailbox by following options:

* `:by_subject` - subject of the email

You can search local mailbox by following options:

* `:by_subject` - subject of the email   
* `:by_recipient` - by email recipient

If you would like email to be archived after its read, use `:archive => true` option (recommended)

## Search results

Once email searching is finished, you can check search result by looking at: `email_receiver.search` object

* `:options` - search options which were used (described above)
* `:started_at` - time when search was initiated
* `:finished_at` - time when search was stopped
* `:duration` - time how long the search took 
* `:max_duration` - maximum amount of time search can take in seconds (default is 240)
* `:result - result of search - `true/false`
* `:email` - email found in search 
* `:emails` - array of emails found in search

# Email search notifications

While searching for an email, there is a possibility to get notification if emails sending is taking too long. 
You can get an notification in console, by email or both.

To add notifications to email searching all you need to do is:

``` ruby
email_receiver.add_observer(MailHandler::Receiving::Notification::Email.new(email_sender, contacts))
email_receiver.add_observer(MailHandler::Receiving::Notification::Console.new)
``` 

the parameters you need are:

* `email_sender` - email sender you will use for sending an email (it should be one of senders described below)
* `contacts` - list of contacts to receive the notification (for example: `john@example.com, igor@example.com`
 
# Email sending 

There are three ways you can send email. 
 
## Send by postmark

To send email you can use SMTP protocol or Postmark.

### Send by Postmark API 

To send email with Postmark, you need to choose type of sending, host, api token, and ssl options.
 
``` ruby
email_sender = MailHandler::Handler.sender(type) do |dispatcher|
    dispatcher.host = host
    dispatcher.api_token = api_token
    dispatcher.use_ssl = use_ssl
end
```

* `:type` - type can be `:postmark_api` or `postmark_batch_api`
* `:host` - host is `api.postmarkapp.com`
* `:api_token` - api token of one of your Postmark sending servers 
* `:use_ssl` - can be true/false
  
### Sending email by SMTP

To send email with SMTP you need to configure standard SMTP settings.

``` ruby
email_sender = MailHandler::Handler.sender(:smtp) do |dispatcher|
    dispatcher.address = address
    dispatcher.port = port
    dispatcher.domain = domain
    dispatcher.username = username
    dispatcher.password = password
    dispatcher.use_ssl = use_ssl
end
``` 

## Sending results
 
Once email sending is finished, you can check sending result by looking at: `email_receiver.sending` object 

* `:started_at` - time when sending was initiated
* `:finished_at` - time when sending was finished
* `:duration` - time how long the sending took 
* `:response` - response from sending
* `:email` - email sent
 






