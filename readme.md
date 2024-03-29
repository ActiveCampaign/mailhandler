<a href="https://postmarkapp.com">
    <img src="postmark.png" alt="Postmark Logo" title="Postmark" width="120" height="120" align="right">
</a>

# MailHandler Gem

[![Build Status](https://circleci.com/gh/ActiveCampaign/mailhandler.svg?style=shield)](https://circleci.com/gh/ActiveCampaign/mailhandler)

MailHandler is a simple wrapper on top of [Mail gem](https://github.com/mikel/mail) and [Postmark gem](https://github.com/ActiveCampaign/postmark-gem) libraries. It allows you to send and retrieve emails and at the same time get details on how long these operations took.
Main purpose of the gem is easier email sending/delivery testing with notification option if sending or retrieving email is taking too long. 

The library supports sending email by standard SMTP protocol and by Postmark API. More importantly it also allows checking email delivery by IMAP protocol, or by folder if you have a local mailbox. 

# Install the gem

With Bundler:

``` ruby
gem 'mailhandler'
``` 

Without Bundler:

``` bash
gem install mailhandler
``` 

# Email retrieval  

## Configure local folder as your mailbox check for emails

Searching emails locally is an option that can be used when you have emails stored in certain local path on your test machine. 
In order to search for email, all you need to do is setup inbox folder and archive folder. 

Folders can be the same if you don't plan to archive found emails. Retrieving emails from a folder would look like following:

``` ruby

inbox_folder = '/folder/mailbox/inbox'
archive_folder = '/folder/mailbox/archive/'

email_receiver = MailHandler.receiver(:folder) do |checker|
    checker.inbox_folder = inbox_folder
    checker.archive_folder = archive_folder
end
```  

## Configure imap mailbox email to check

If you plan to search for emails in your remote inbox which supports IMAP, you can use Mailhandler by providing IMAP settings.
We recommend to keep credentials for your IMAP settings safe, and read them from config file or environment variables.
Do NOT keep credentials in your repositories. 
 
``` ruby

address = 'imap.example.com'
port = 993
username = 'john'
password = 'xxxxxxxxxxxxxx'
use_ssl = true

email_receiver = MailHandler.receiver(:imap) do |checker|
  checker.address = address
  checker.port = port
  checker.username = username
  checker.password = password
  checker.use_ssl  =  use_ssl
end
``` 

Email receiving handler will be referenced in examples below as `email_receiver`.

## Searching for email

Once you have setup mailbox searching type, you can search for email like this:

``` ruby
email_receiver.find_email(:by_subject => subject, :archive => true)
``` 

You can search imap mailbox by following options:

* `:by_subject` - subject of the email
* `:by_content` - search email content by keywords
* `:by_recipient` - by email recipient

You can search local mailbox by following options:

* `:by_subject` - subject of the email   
* `:by_recipient` - by email recipient
* `:by_content` - search email content by keywords

Recipient to search by needs to by added in the following form: `by_recipient => { :to => 'igor@example.com' }`.
Library supports searching by :to, :cc recipients. At the moment, only searching by a single recipient email address is supported.

If you would like email to be archived after its read, use `:archive => true` option (recommended).

**For now, Unicode is not supported for search by local mailbox, only ASCII.**

## Search results

Once email searching is finished, you can check search results by checking: `email_receiver.search` object, which has following information:

* `:options` - search options which were used (described above)
* `:started_at` - time when search was initiated
* `:finished_at` - time when search was stopped
* `:duration` - time how long the search took 
* `:max_duration` - maximum amount of time search can take in seconds (default is 240)
* `:result` - result of search - `true/false`
* `:email` - first email found in search 
* `:emails` - array of all emails found in search

# Email search notifications

While searching for an email, there is a possibility to get notification if emails searching is taking too long. 
You can get an notification in console, by email or both. 

Console notification is a good option if you are testing email delivery and want to see console output on how is the progress of search going.

To add console or email notifications, to your email searching all you need to do is:

``` ruby
email_receiver.add_observer(MailHandler::Receiving::Notification::Email.new(email_sender, from, contacts))
email_receiver.add_observer(MailHandler::Receiving::Notification::Console.new)
``` 

For email notifications, the parameters you need are:

* `email_sender` - email sender you will use for sending an email (it should be one of senders described below)
* `from` - email address from which email is sent 
* `contacts` - list of contacts to receive the notification (for example: `john@example.com, igor@example.com`
 
# Email sending 

There are three ways you can send email, which we will describe below. To send email you can use SMTP protocol or Postmark API.

### Send by Postmark API 

To send email with Postmark, you need to choose type of sending, api token options.
 
``` ruby
api_token = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'

email_sender = MailHandler.sender(type) do |dispatcher|
    dispatcher.api_token = api_token
end
```

* `:type` - type can be `:postmark_api` or `:postmark_batch_api`
* `:api_token` - api token of one of your Postmark sending servers 
  
### Sending email by SMTP

To send email with SMTP you need to configure standard SMTP settings.
We recommend to keep credentials for your SMTP settings safe, and read them from config file or environment variables.
Do NOT keep credentials in your repositories. 

``` ruby

address = 'imap.example.com'
domain = 'example.com'
port = 587
username = 'john'
password = 'xxxxxxxxxxxxxx'
use_ssl = true

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

Email you plan to send has to be an email created with Mail gem. 
In order to send emails by Postmark batch, you will need to provide an Array of emails.

## Sending results
 
Once email sending is finished, you can check sending result by looking at: `email_receiver.sending` object 

* `:started_at` - time when sending was initiated
* `:finished_at` - time when sending was finished
* `:duration` - time how long the sending took 
* `:response` - response from sending
* `:email` - email sent
 
### License

MailHandler Library is licensed under the [MIT](http://www.opensource.org/licenses/mit-license.php "Read more about the MIT license form") license. Refere to the [LICENSE](https://github.com/ActiveCampaign/mailhandler/blob/master/LICENSE) file for more information. 






