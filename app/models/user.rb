class User < ApplicationRecord
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :lockable,
         :confirmable, :trackable, reconfirmable: true

  encrypts :email, :name
  blind_index :email

  has_many :user_projects, dependent: :destroy
  has_many :projects, through: :user_projects
  has_many :comments, dependent: :destroy
  has_many :links, dependent: :destroy
  has_many :events, dependent: :destroy

  validates :email, uniqueness: true

  # Override default devise method to send emails using active job
  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  def is_admin_on?(project)
    UserProject.where(project_id: project.id).first.role == UserProject::ADMIN
  end

  def is_admin_on_any_project?
    UserProject.where(user_id: id, role: UserProject::ADMIN).exists?
  end

  # This will allow enabling the :trackable Devise module without saving user IPs.
  # https://github.com/heartcombo/devise/issues/4849#issuecomment-534733131
  def current_sign_in_ip; end
  def last_sign_in_ip=(_ip); end
  def current_sign_in_ip=(_ip); end
end
