class ContactController < ApplicationController
  require 'roo'
  
  def index
  end

  def upload
  	s = get_file_content(params[:file])
  	if s.class == Hash && s[:code] == 415
  		redirect_to root_path, alert: s[:msg]
  	else
  		@lists = validations(s.parse)
  	end
  end

  def create
  	s = get_file_content(params[:file])
  	if s.class == Hash && s[:code] == 415
  		redirect_to root_path, alert: s[:msg]
  	else
  		@errlist = save_all_contacts(s.parse)
  		@contacts = Contact.all.to_a
  	end
  end

  def save_all_contacts(s)
  	error_list = []
  	s.each do | c |
  		contact = Contact.create(:firstname => c[0], :lastname => c[1], :email => c[2])
  		if contact.errors.any? && c[0] != "first_name"
  			c << contact.errors.full_messages.join(". ")
  			error_list << c
  		end
  	end
  	return error_list
  end

  def get_file_content file
  	begin
  		s = Roo::Spreadsheet.open(file)
  	rescue Exception => e
  		return {code: 415, msg: "This file doesn't have the xlsx format."}
  	end
  	if s.to_s == "{}"
  		return {code: 415, msg: "This file is nil."}
  	end
  	return s
  end

  def add_to_errlist list, errlist, msg
  	list << msg
  	errlist << list
  end

  def already_exist?(c, finalist, errlist)
  	finalist.each do |f|
  		if f[0].casecmp(c[0]) == 0 && f[1].casecmp(c[1]) == 0
  			add_to_errlist(c, errlist, "This firstname and lastname already exist.")
  			return true
  		elsif f[2].casecmp(c[2]) == 0
  			add_to_errlist(c, errlist, "This email already exist.")
  			return true
  		end
  	end
  	false
  end

  def validations contacts
  	errlist = []
  	finalist = []
  	contacts.each do |c|
  		if c[0].length < 3 || c[1].length < 3
  			add_to_errlist(c, errlist, "Firstname and/or lastname have less than 3 char.")
  		elsif c[2] != "email" && c[2].match(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i).nil?
  			add_to_errlist(c, errlist, "This email doesn't have a good format.")
  		elsif ((c[0] != "first_name" && c[1] != "last_name") && (c[0].match(/\A[a-zA-Z]{1}[a-z0-9]+\z/).nil? || c[1].match(/\A[a-zA-Z]{1}[a-z0-9]+\z/).nil?))
  			add_to_errlist(c, errlist, "Firstname and/or lastname doesn't have a good format.")
  		elsif !already_exist?(c, finalist, errlist)
  			finalist << c
  		end
  	end
  	return {final: finalist, error: errlist}
  end
end