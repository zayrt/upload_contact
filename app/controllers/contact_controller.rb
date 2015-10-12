class ContactController < ApplicationController
  require 'roo'
  
  def index
  end

  def upload
  	s = get_file_content(params[:file])
  	if s.class == Hash && s[:code] == 415
  		redirect_to root_path, alert: s[:msg]
  	else
  		@lists = check_format(check_doublon(s.parse))
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

  def swap_list list1, list2, n, msg
  	list1[n] << msg
  	list2 << list1[n]
  	list1.delete_at(n)
  end 

  def check_format lists
  	i = 0
  	#raise lists.inspect
  	while i < lists[:first].length
  		puts lists[:first][i].inspect
  		if lists[:first][i][0].length < 3 || lists[:first][i][1].length < 3
  			swap_list(lists[:first], lists[:second], i, "Firstname and/or lastname have less than 3 char.")
  		elsif lists[:first][i][2] != "email" && lists[:first][i][2].match(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i).nil?
  			swap_list(lists[:first], lists[:second], i, "This email doesn't have a good format.")
  		elsif ((lists[:first][i][0] != "first_name" && lists[:first][i][1] != "last_name") && (lists[:first][i][0].match(/\A[a-zA-Z]{1}[a-z0-9]+\z/).nil? || lists[:first][i][1].match(/\A[a-zA-Z]{1}[a-z0-9]+\z/).nil?))
  			swap_list(lists[:first], lists[:second], i, "Firstname and/or lastname doesn't have a good format.")
  		else
  			i += 1
  		end
  	end
  	return lists
  end

  def check_doublon first_list
  	i = 0
  	second_list = []
  	while i < first_list.length
  		j = 0
  		while j < first_list.length
  			if i != j
  				if first_list[i][0].casecmp(first_list[j][0]) == 0 && first_list[i][1].casecmp(first_list[j][1]) == 0
  					swap_list(first_list, second_list, j, "This firstname and lastname already exist.")
  				elsif first_list[i][2].casecmp(first_list[j][2]) == 0
  					swap_list(first_list, second_list, j, "This email already exist.")
  				end
  			end
  			j += 1
  		end 
  		i += 1
  	end
  	return {first: first_list, second: second_list}
  end
end