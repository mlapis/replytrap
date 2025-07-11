module AuthenticationHelper
  def sign_in_user(user = nil)
    user ||= users(:one)
    sign_in user
  end
end
