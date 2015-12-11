# MailHandler Gem

[![Build Status](https://travis-ci.org/wildbit/mailhandler.svg?branch=master)](https://travis-ci.org/wildbit/mailhandler)

MailHandler is a simple wrapper for [mail](https://github.com/mikel/mail) and [postmark](https://github.com/wildbit/postmark-gem) libraries which allows you to send and retrieve emails, 
and get more details about email sending and delivery. Main purpose of the gem is easier email sending/delivery testing. 

The library supports sending by SMTP, Postmark API and checking email delivery by IMAP protocol, or by folder, if you have a local mailbox. 

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

Checking emails locally option can be used when you have emails stored in certain local path. In order to search for email, all you need to do is setup inbox and archive folder.
They can be the same if you don't plan to archive checked files.

``` ruby
email_receiver = MailHandler.receiver(:folder) do |checker|
    checker.inbox_folder = folder_of_your_inbox
    checker.archive_folder = folder_of_your_inbox_archive_folder
end
```  

## Configure imap mailbox email to check

If you plan to check for an email in your inbox which support IMAP, you can use mailhandler with provided IMAP settings. 
 
``` ruby
email_receiver = MailHandler.receiver(:imap) do |checker|
  checker.address = 'imap.example.com'
  checker.port = 993
  checker.username = 'username'
  checker.password = 'password'
  checker.use_ssl  =  true
end
``` 
Email receiving handler will be referenced below as `email_receiver`

## Searching for email

Once you have setup mailbox checking type, you can search for email like this:

``` ruby
email_receiver.find_email(:by_subject => subject, :archive => true)
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
You can get an notification in console, by email or both. Console output is good if you are testing email delivery, and want to see how long its taking for email to arrive in console.

To add notifications to email searching all you need to do is:

``` ruby
email_receiver.add_observer(MailHandler::Receiving::Notification::Email.new(email_sender, contacts))
email_receiver.add_observer(MailHandler::Receiving::Notification::Console.new)
``` 

For email notifications, the parameters you need are:

* `email_sender` - email sender you will use for sending an email (it should be one of senders described below)
* `contacts` - list of contacts to receive the notification (for example: `john@example.com, igor@example.com`
 
# Email sending 

There are three ways you can send email. 
 
## Send by postmark

To send email you can use SMTP protocol or Postmark.

### Send by Postmark API 

To send email with Postmark, you need to choose type of sending, api token options.
 
``` ruby
email_sender = MailHandler.sender(type) do |dispatcher|
    dispatcher.api_token = api_token
end
```

* `:type` - type can be `:postmark_api` or `postmark_batch_api`
* `:api_token` - api token of one of your Postmark sending servers 
  
### Sending email by SMTP

To send email with SMTP you need to configure standard SMTP settings.

``` ruby
email_sender = MailHandler.sender(:smtp) do |dispatcher|
    dispatcher.address = address
    dispatcher.port = port
    dispatcher.domain = domain
    dispatcher.username = username
    dispatcher.password = password
    dispatcher.use_ssl = use_ssl
end
```
 
### Sending email
 
Once you have setup your email sender, all you need to do is to send an email:

``` ruby
email_sender.send_email(email)
```

email has to be an email created with Mail gem. In order to send emails by Postmark batch, you will need to provide an Array of emails.

## Sending results
 
Once email sending is finished, you can check sending result by looking at: `email_receiver.sending` object 

* `:started_at` - time when sending was initiated
* `:finished_at` - time when sending was finished
* `:duration` - time how long the sending took 
* `:response` - response from sending
* `:email` - email sent
 






