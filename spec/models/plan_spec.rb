require 'rails_helper'

RSpec.describe Plan, type: :model do
  # Create a test user for association
  let(:user) { User.create(email: "test@example.com", password: "password") }

  # Test case: Plan is valid with required attributes
  it "is valid with a name, description, start_time, and end_time" do
    plan = Plan.new(
      name: "Test Plan",
      description: "This is a test",
      start_time: Time.now,
      end_time: Time.now + 1.day,
      user: user # Associate the plan with the test user
    )
    expect(plan).to be_valid
  end

  # Test case: Plan is invalid without a name
  it "is invalid without a name" do
    plan = Plan.new(description: "Test description", user: user) # No name provided
    expect(plan).not_to be_valid
  end

  # Test case: Plan is invalid without a description
  it "is invalid without a description" do
    plan = Plan.new(name: "Test Plan", user: user, start_time: Time.now, end_time: Time.now + 1.day)
    expect(plan).not_to be_valid
  end

  # Test case: Plan is invalid without a start_time
  it "is invalid without a start_time" do
    plan = Plan.new(name: "Test Plan", description: "Test description", user: user, end_time: Time.now + 1.day)
    expect(plan).not_to be_valid
  end

  # Test case: Plan is invalid without an end_time
  it "is invalid without an end_time" do
    plan = Plan.new(name: "Test Plan", description: "Test description", user: user, start_time: Time.now)
    expect(plan).not_to be_valid
  end

  # Test case: Plan is invalid without an associated user
  it "is invalid without an associated user" do
    plan = Plan.new(name: "Test Plan", description: "Test description", start_time: Time.now, end_time: Time.now + 1.day)
    expect(plan).not_to be_valid
  end
end
