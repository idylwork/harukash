class ContactMailer < ApplicationMailer
  def forward(contact, email)
    @contact = contact
    from_name = "#{ENV['SITE_NAME']} - Contact Form Nortification"
    from_address = ENV["MAIL_FROM_ADDRESS"]
    mail from: "#{escape_mail_name(from_name)} <#{from_address}>",
         to: email,
         subject: "[#{ENV['SITE_NAME']}] Message from #{contact.name}"
  end

  private

  def escape_mail_name(name)
    # Special characters
    if name && name =~ /[\(\)<>\[\]:;@\\,\."]/
      name.gsub!('\\', '\\\\')
      name.gsub!('"', '\"')
      name = '"' + name + '"'
    end
    name
  end
end
