require 'rails_helper'

RSpec.describe User, type: :model do
  # Test case: User is valid with a valid email and password
  it "is valid with a valid email and password" do
    user = User.new(email: "test@example.com", password: "password")
    expect(user).to be_valid
  end

  # Test case: User is invalid without an email
  it "is invalid without an email" do
    user = User.new(email: nil, password: "password") # Missing email
    expect(user).not_to be_valid
  end

  # Test case: User is invalid without a password
  it "is invalid without a password" do
    user = User.new(email: "test@example.com", password: nil) # Missing password
    expect(user).not_to be_valid
  end
end
