class ContactMailer < ActionMailer::Base
  
  helper :application
  
  def contact_message(contact)
    @recipients = VIPER_EMAIL
    @from = contact.email_address
    @subject = "#{SITENAME} Contact Form Submission"
    @body['name'] = contact.name
    @body['company'] = contact.company
    @body['phone'] = contact.phone
    @body['email'] = contact.email_address
    @body['subject'] = contact.subject
    @body['message'] = contact.message
  end
  
end
