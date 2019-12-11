class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :trackable, reconfirmable: true
  has_and_belongs_to_many :projects
  has_many :comments
end
