require "test_helper"

class EmailAccountTest < ActiveSupport::TestCase
  def setup
    @email_account = email_accounts(:one)
  end

  test "should belong to user and persona" do
    assert_respond_to @email_account, :user
    assert_respond_to @email_account, :persona
  end

  test "should have many conversations" do
    assert_respond_to @email_account, :conversations
  end

  test "should validate presence of required fields" do
    account = EmailAccount.new
    assert_not account.valid?
    assert_includes account.errors[:email], "can't be blank"
    assert_includes account.errors[:fetch_server], "can't be blank"
    assert_includes account.errors[:username], "can't be blank"
    assert_includes account.errors[:password], "can't be blank"
  end

  test "should validate email format" do
    account = EmailAccount.new(email: "invalid-email")
    account.valid?
    assert_includes account.errors[:email], "is invalid"
  end

  test "should validate unique email" do
    duplicate = email_account
      .with_email(@email_account.email)
      .for_user(users(:one))
      .with_persona(personas(:one))
      .build

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:email], "has already been taken"
  end

  test "should validate status values" do
    account = email_account
      .with_status("invalid_status")
      .for_user(users(:one))
      .with_persona(personas(:one))
      .build

    assert_not account.valid?
    assert_includes account.errors[:status], "is not included in the list"
  end

  test "should validate protocol values" do
    account = email_account
      .with_protocol("invalid_protocol")
      .for_user(users(:one))
      .with_persona(personas(:one))
      .build

    assert_not account.valid?
    assert_includes account.errors[:fetch_protocol], "is not included in the list"
  end

  test "should set active to true by default" do
    account = EmailAccount.new
    account.send(:set_defaults)
    assert account.active
  end
end
