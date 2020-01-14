class User < ApplicationRecord
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :lockable,
         :confirmable, :trackable, reconfirmable: true
  has_and_belongs_to_many :projects
  has_many :comments, dependent: :destroy
  has_many :links, dependent: :destroy
  has_many :events, dependent: :destroy

  # Override default devise method to send emails using active job
  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end
end
