class UserProject < ApplicationRecord
  belongs_to :project
  belongs_to :user

  validate :user_role_allowed_on_project

  ADMIN = "admin".freeze
  USER = "user".freeze
  USER_ROLES = [ADMIN, USER].freeze

  private

  def user_role_allowed_on_project
    unless USER_ROLES.include?(role)
      errors.add(:role, "not included in '#{USER_ROLES}'")
    end
  end
end
