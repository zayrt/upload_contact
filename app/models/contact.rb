class Contact < ActiveRecord::Base
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
	VALID_USERNAME_REGEX = /\A[a-zA-Z]{1}[a-z0-9]+\z/
	validates :firstname,	presence: true, length: { in: 3..30 }, format: { with: VALID_USERNAME_REGEX }
	validates :lastname,	presence: true, length: { in: 3..30 }, format: { with: VALID_USERNAME_REGEX }
	validates :email,		presence: true, length: { maximum: 60 }, uniqueness: { case_sensitive: false },
						format: { with: VALID_EMAIL_REGEX }
	validates :firstname, uniqueness: {scope: :lastname, case_sensitive: false, message: "and Lastname have already been taken"}
end