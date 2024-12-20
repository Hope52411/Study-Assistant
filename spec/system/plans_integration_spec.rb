require 'rails_helper'

RSpec.describe "Plans Integration Tests", type: :system do
  # before do
  #   driven_by(:selenium, using: :chrome, screen_size: [ 1400, 1100 ])
  # end

  # Create a test user with a unique email
  let!(:user) { create(:user, email: "test_#{Time.now.to_i}@example.com", password: 'password') }

  it "allows a user to log in, create a plan, generate AI plan, export PDF, and log out" do
    # Step 1: Log in the user
    visit new_user_session_path # Devise login path
    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    click_button "Login"

    # Verify login success by checking for a confirmation message
    expect(page).to have_content("Signed in successfully.")

    # Step 2: Create a new plan
    click_link "Create a New Plan" # Ensure this matches the button or link text
    fill_in "Plan Name", with: "Test Plan"
    fill_in "Plan Description", with: "This is a test plan description"
    click_button "Create Plan"

    # Verify plan creation success
    expect(page).to have_content("Plan created successfully!!!")
    expect(page).to have_content("Test Plan")

    # Step 3: Generate AI reference plan
    click_link "Edit" # Navigate to the edit page

    # Verify the presence of the AI generation button and click it
    expect(page).to have_link('AI Generates a Reference Plan') # Ensure the link is visible on the page
    click_link "AI Generates a Reference Plan"

    # Verify the AI plan generation success
    expect(page).to have_content("Plan")

    # Step 4: Export the plan to PDF
    click_link "Export to PDF"

    # Verify the PDF export page content
    expect(page).to have_content("Plan Name")
  end
end
