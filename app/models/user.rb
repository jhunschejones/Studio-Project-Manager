#
# USER SITE ROLES & PERMISSIONS:
# ------------------------------
# User site roles are used to affect the capabilities a user has
# for the entire site.
#
# Hierarchy of roles and the capabilities they provide (from lowest to
# highest) goes: USER_PROJECT_ROLES > "site_creator" > "site_admin"
#
# "site_creator" can create new projects. This role is intended for
# studio staff who are responsible for creating and managing new
# projects, especially those working independently of each-other.
#
# "site_admin" provides the highest level of permissions, including
# accessing, modifying, and archiving projects where a user does not
# explicitly have a user_project record (otherwise required). This
# role is intended to be used sparingly for individuals managing the
# entire site. WARNING: "site_admin" has access to every project in
# the site
#
# IMPORTANT: these user site roles provide additional capabilities
# beyond project scoped roles and are mainly intended for studio
# staff. Be careful who they are assigned to to avoid unintended
# data access.
#
class User < ApplicationRecord
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :lockable,
         :confirmable, :async, :trackable, reconfirmable: true

  encrypts :email, :name
  blind_index :email, :name

  has_many :user_projects, dependent: :destroy
  has_many :projects, through: :user_projects
  has_many :comments, dependent: :destroy
  has_many :links, dependent: :destroy
  has_many :events, dependent: :destroy

  validates :email, uniqueness: true
  validate :site_role_valid

  SITE_USER = "site_user".freeze
  SITE_CREATOR = "site_creator".freeze
  SITE_ADMIN = "site_admin".freeze
  USER_SITE_ROLES = [SITE_USER, SITE_CREATOR, SITE_ADMIN].freeze

  # --- PERMISSIONS ---
  def is_site_admin?
    site_role == SITE_ADMIN
  end

  def is_site_creator?
    site_role == SITE_CREATOR
  end

  def is_project_owner?(project)
    UserProject.where(user_id: id, project_id: project.id, project_role: UserProject::PROJECT_OWNER).exists?
  end

  def can_manage_user_owned_resource?(resource)
    is_site_admin? || (resource[:user_id] && resource[:user_id] == id)
  end

  def can_create_projects?
    is_site_admin? || is_site_creator?
  end

  def can_access_project?(project)
    is_site_admin? || UserProject.where(user_id: id, project_id: project.id).exists?
  end

  def can_archive_project?(project)
    is_site_admin? || is_project_owner?(project)
  end

  def can_manage_project_owners?(project)
    is_site_admin? || is_project_owner?(project)
  end

  def can_delete_tracks?(project)
    is_site_admin? || is_project_owner?(project)
  end

  def can_manage_track_versions?(project)
    is_site_admin? || is_project_owner?(project)
  end

  def can_manage_events?(project, event)
    is_project_owner?(project) || can_manage_user_owned_resource?(event)
  end

  # --- SECURITY LIBRARY OVERRIDES ---

  # Override default devise method to send emails using active job
  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  # This will allow enabling the :trackable Devise module without saving user IPs
  # https://github.com/heartcombo/devise/issues/4849#issuecomment-534733131
  def current_sign_in_ip; end
  def last_sign_in_ip=(_ip); end
  def current_sign_in_ip=(_ip); end

  private

  def site_role_valid
    unless USER_SITE_ROLES.include?(site_role)
      errors.add(:site_role, "not included in '#{USER_SITE_ROLES}'")
    end
  end
end
