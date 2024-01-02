# frozen_string_literal: true

module Mail
  # IMAP class patch to better manage connection and search of emails
  class IMAP
    attr_accessor :imap_connection

    def find_emails(options = {}, &block) # rubocop:disable all
      options = validate_options(options)
      options[:read_only] ? imap_connection.examine(options[:mailbox]) : imap_connection.select(options[:mailbox])
      uids = imap_connection.uid_search(options[:keys])

      uids.reverse! if options[:what].to_sym == :last
      uids = uids.first(options[:count]) if options[:count].is_a?(Integer)
      uids.reverse! if (options[:what].to_sym == :last && options[:order].to_sym == :asc) ||
                       (options[:what].to_sym != :last && options[:order].to_sym == :desc)

      if block_given?
        uids.each do |uid|
          uid = options[:uid].to_i unless options[:uid].nil?
          new_message = retrieve_email_content(uid, options[:fetch_type])
          new_message.mark_for_delete = true if options[:delete_after_find]

          if block.arity == 3
            yield new_message, imap_connection, uid
          else
            yield new_message
          end

          imap_connection.uid_store(uid, '+FLAGS', [Net::IMAP::DELETED]) if options[:delete_after_find] &&
                                                                            new_message.is_marked_for_delete?
          break unless options[:uid].nil?
        end
        imap_connection.expunge if options[:delete_after_find]
      else
        emails = []

        uids.each do |uid|
          uid = options[:uid].to_i unless options[:uid].nil?
          emails << retrieve_email_content(uid, options[:fetch_type])
          imap_connection.uid_store(uid, '+FLAGS', [Net::IMAP::DELETED]) if options[:delete_after_find]
          break unless options[:uid].nil?
        end

        imap_connection.expunge if options[:delete_after_find]
        emails.size == 1 && options[:count] == 1 ? emails.first : emails
      end
    end

    # Start an IMAP session
    def connect(_config = Mail::Configuration.instance) # rubocop:disable all
      @imap_connection = Net::IMAP.new(settings[:address], settings[:port], settings[:enable_ssl], nil, false)

      if settings[:authentication].nil?
        imap_connection.login(settings[:user_name], settings[:password])
      else
        # Note that Net::IMAP#authenticate('LOGIN', ...) is not equal with Net::IMAP#login(...)!
        # (see also http://www.ensta.fr/~diam/ruby/online/ruby-doc-stdlib/libdoc/net/imap_connection/rdoc/classes/Net/IMAP.html#M000718)
        imap_connection.authenticate(settings[:authentication], settings[:user_name], settings[:password])
      end
    end

    def disconnect
      imap_connection.disconnect if defined?(imap_connection) && imap_connection && !imap_connection.disconnected?
    end

    private

    # fetch emails with different flag
    # to make it work with icloud
    FETCH_FLAG = {
      body: 'BODY[]',
      rfc: 'RFC822',
      envelope: 'ENVELOPE'
    }.freeze

    def retrieve_email_content(uid, flag_type = :body)
      case flag_type
      when :envelope
        retrieve_email_content_by_envelope(uid)
      else
        retrieve_email_content_by_body(uid)
      end
    end

    def retrieve_email_content_by_body(uid)
      fetchdata = retrieve_fetch_type_data(FETCH_FLAG[:body], uid)
      Mail.new(fetchdata)
    end

    def retrieve_email_content_by_envelope(uid)
      fetchdata = retrieve_fetch_type_data(FETCH_FLAG[:envelope], uid)
      mail = Mail.new
      mail.subject = fetchdata.subject
      mail
    end

    def retrieve_fetch_type_data(fetch_type, uid)
      fetchdata = imap_connection.uid_fetch(uid, fetch_type)[0]
      fetchdata.attr[fetch_type]
    end
  end
end
