class PageController < ApplicationController
  #skip_before_action :verify_authenticity_token
  require 'roo'
  
  def index
  end

  def upload
  	begin
  		s = Roo::Spreadsheet.open(params[:file])
  	rescue Exception => e
  		redirect_to root_path, alert: "This file doesn't have the xlsx format."
  		return
  	end
  	@lists = check_format(check_doublon(s.parse))
  end

  def check_format lists
  	i = 0
  	while i < lists[:first].length
  		if lists[:first][i][0].length < 3 || lists[:first][i][1].length < 3
  			lists[:first][i] << "Lastname and/or firstname have less than 3 char."
  			lists[:second] << lists[:first][i]
  			lists[:first].delete_at(i)
  		elsif lists[:first][i][2] != "email" && lists[:first][i][2].match(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i).nil?
  			lists[:first][i] << "This email doesn't have a good format."
  			lists[:second] << lists[:first][i]
  			lists[:first].delete_at(i)
  		elsif (lists[:first][i][0] != "first_name" && lists[:first][i][1] != "last_name") && (lists[:first][i][0].match(/\A[a-zA-Z]?[a-z0-9]+\z/).nil? || lists[:first][i][1].match(/\A[a-zA-Z0-9]+\z/).nil?)
  			lists[:first][i] << "Firstname and/or lastname doesn't have a good format."
  			lists[:second] << lists[:first][i]
  			lists[:first].delete_at(i)
  		end
  		i += 1
  	end
  	return lists
  end

  def check_doublon first_list
  	i = 0
  	second_list = [["first_name", "last_name", "email", "reason"]]
  	while i < first_list.length
  		j = 0
  		while j < first_list.length
  			if i != j
  				if first_list[i][0].casecmp(first_list[j][0]) == 0 && first_list[i][1].casecmp(first_list[j][1]) == 0
  					first_list[j] << "This firstname and lastname already exist."
  					second_list << first_list[j]
  					first_list.delete_at(j)
  				elsif first_list[i][2].casecmp(first_list[j][2]) == 0
  					first_list[j] << "This email already exist."
  					second_list << first_list[j] 
  					first_list.delete_at(j)
  				end
  			end
  			j += 1
  		end
  		i += 1
  	end
  	return {first: first_list, second: second_list}
  end
end