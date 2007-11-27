class Contact < Tableless
  column :name,           :string
  column :company,        :string
  column :phone,          :string
  column :email_address,  :string
  column :subject,        :string
  column :message,        :text
  
  validates_presence_of :name, :email_address, :subject, :message
  validates_format_of   :email_address,
                        :with => /^[A-Z0-9._%-]+@([A-Z0-9-]+\.)+[A-Z]{2,4}$/i,
                        :message => "must be a valid email address"
end
