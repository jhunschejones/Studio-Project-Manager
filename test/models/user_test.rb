require 'test_helper'

# bundle exec ruby -Itest test/models/user_test.rb
class UserTest < ActiveSupport::TestCase
  test "sets default role as project_user" do
    user = User.create!(
      name_ciphertext: User.generate_name_ciphertext("McClain Fox").inspect,
      name_bidx: User.generate_name_bidx("McClain Fox").inspect,
      email_ciphertext: User.generate_email_ciphertext("mcclain.fox@dafox.com").inspect,
      email_bidx: User.generate_email_bidx("mcclain.fox@dafox.com").inspect,
      password: "secret",
      password_confirmation: "secret",
      confirmed_at: Time.now.utc
    )
    assert_equal "site_user", user.site_role
  end

  describe "validations" do
    test "requires valid project_role" do
      expected_error_message = {:site_role=>["not included in '[\"site_user\", \"site_creator\", \"site_admin\"]'"]}
      user = User.new(
        name_ciphertext: User.generate_name_ciphertext("McClain Fox").inspect,
        name_bidx: User.generate_name_bidx("McClain Fox").inspect,
        email_ciphertext: User.generate_email_ciphertext("mcclain.fox@dafox.com").inspect,
        email_bidx: User.generate_email_bidx("mcclain.fox@dafox.com").inspect,
        password: "secret",
        password_confirmation: "secret",
        confirmed_at: Time.now.utc,
        site_role: "Robot Overlord"
      )
      user.validate
      assert_equal expected_error_message, user.errors.messages
    end

    test "prevents invalid project_role" do
      assert_raises ActiveRecord::RecordInvalid do
        User.create!(
          name_ciphertext: User.generate_name_ciphertext("McClain Fox").inspect,
          name_bidx: User.generate_name_bidx("McClain Fox").inspect,
          email_ciphertext: User.generate_email_ciphertext("mcclain.fox@dafox.com").inspect,
          email_bidx: User.generate_email_bidx("mcclain.fox@dafox.com").inspect,
          password: "secret",
          password_confirmation: "secret",
          confirmed_at: Time.now.utc,
          site_role: "Robot Overlord"
        )
      end
    end
  end
end
