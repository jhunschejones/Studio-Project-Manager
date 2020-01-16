#
# USER PROJECT ROLES / PERMISSIONS:
# --------------------------------
# User project roles are used to affect the capabilities a user has
# on a project.
#
# Hierarchy of roles and the capabilities they provide (from lowest to
# highest) goes: "project_user" > "project_owner" > USER_SITE_ROLES
#
# "project_user" can update a project, invite other users, update and
# add links, and update their own user profile. This role is intended
# for band members, artists, and other studio staff who are working on
# a project but only need basic access.
#
# "project_owner" can archive projects and remove other project owners
# from a project. It is intended for studio staff who will be managing
# a specific project. This role is assigned on the user_project record
# when a user creates a new project. (Currently project creation is
# restricted to site admins and site creators)
#
# IMPORTANT: users also have site roles which supersede these scoped
# project roles, providing capabilities at the site level that trickle
# down to the project level. Currently, "site_creator" and "site_admin"
# allow additional capabilities such as creating new projects (both),
# archiving projects and accessing projects where there is no
# user_project record (site_admin only)
#
class UserProject < ApplicationRecord
  belongs_to :project
  belongs_to :user

  validate :project_role_valid
  validates_uniqueness_of :user_id, { scope: :project_id, message: "%{value} already has a user_project record for this project"}

  PROJECT_OWNER = "project_owner".freeze
  PROJECT_USER = "project_user".freeze
  USER_PROJECT_ROLES = [PROJECT_OWNER, PROJECT_USER].freeze

  private

  def project_role_valid
    unless USER_PROJECT_ROLES.include?(project_role)
      errors.add(:project_role, "not included in '#{USER_PROJECT_ROLES}'")
    end
  end
end
