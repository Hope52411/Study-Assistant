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

  # Test case: User email should be unique
  it "is invalid with a duplicate email" do
    User.create(email: "test@example.com", password: "password")
    duplicate_user = User.new(email: "test@example.com", password: "password")
    expect(duplicate_user).not_to be_valid
  end

  # Test case: User email should have a valid format
  it "is invalid with an invalid email format" do
    user = User.new(email: "invalid-email", password: "password")
    expect(user).not_to be_valid
  end

  # Test case: User password should be at least 6 characters long
  it "is invalid with a password shorter than 6 characters" do
    user = User.new(email: "test@example.com", password: "short")
    expect(user).not_to be_valid
  end

  # Test case: User email should be saved in lowercase
  it "saves email in lowercase" do
    user = User.create(email: "Test@Example.Com", password: "password")
    expect(user.email).to eq("test@example.com")
  end
end
