require 'action_mailer'

class UakariDeliveryHandler
  attr_accessor :settings

  def initialize options
    self.settings = {:track_opens => true, :track_clicks => true}.merge(options)
  end

  def deliver! message
    
    if message[:to].blank?
      raise ArgumentError.new('At least one To recipient is required to send a message') 
    end
    
    message_payload = {
      :track_opens => settings[:track_opens],
      :track_clicks => settings[:track_clicks]
    }
    
    message_fields = {
      :subject => message.subject,
      :from_name => settings[:from_name] || (message[:from] && message[:from].display_names.first),
      :from_email => message[:from] && message[:from].addresses.first
    }
    
    message_fields = add_destinations_to(message_fields, message)

    message_payload[:message] = message_fields

    message_payload[:tags] = build_tags(message)

    mime_types = {
      :html => "text/html",
      :text => "text/plain"
    }

    get_content_for = lambda do |format|
      content = message.send(:"#{format}_part")
      content ||= message if message.content_type =~ %r{#{mime_types[format]}}
      content
    end

    [:html, :text].each do |format|
      content = get_content_for.call(format)
      message_payload[:message][format] = content.body if content
    end

    Uakari.new(settings[:api_key]).send_email(message_payload)
  
  end
  
  private
  
  def add_destinations_to(fields, message)
    
    field_names = %w[to cc bcc]

    field_names.each do |field|
      if message[field]
        names = field + "_name"
        emails = field + "_email"
        
        fields[names] = message[field].display_names
        fields[emails] = message[field].addresses
      end
    end
    fields
  end
      
  def build_tags(message)
    tags = []
    tags = tags | settings[:tags] if settings[:tags]   # tags set in Uakari config
    tags = tags | extract_message_tags(message)
  end
  
  def extract_message_tags(message)
    [*message[:tags]].collect { |t| t.to_s }
  end


end
ActionMailer::Base.add_delivery_method :uakari, UakariDeliveryHandler
