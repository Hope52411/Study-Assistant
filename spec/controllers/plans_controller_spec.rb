require 'rails_helper'
require 'pdf-reader'

RSpec.describe PlansController, type: :controller do
  include Devise::Test::ControllerHelpers # Include Devise helpers for controller testing

  # Define a test user
  let(:user) { User.create(email: "test@example.com", password: "password") }
  
  # Define a test plan associated with the user
  let(:plan) do
    Plan.create(
      name: "Test Plan",
      description: "This is a test description",
      start_time: Time.now,
      end_time: Time.now + 1.day,
      reference_plan: "This is a reference plan generated by AI.",
      user: user
    )
  end

  before do
    sign_in user # Simulate user login
  end

  # Test for GET #index action
  describe "GET #index" do
    it "returns a successful response" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  # Test for POST #create action
  describe "POST #create" do
    it "creates a new plan" do
      expect {
        post :create, params: { plan: { name: "New Plan", description: "Test description", start_time: Time.now, end_time: Time.now + 1.day } }
      }.to change(Plan, :count).by(1)
    end
  end

  # Test for PATCH #update action
  describe "PATCH #update" do
    it "updates an existing plan" do
      patch :update, params: { id: plan.id, plan: { name: "Updated Plan" } }
      expect(plan.reload.name).to eq("Updated Plan")
    end
  end

  # Test for DELETE #destroy action
  describe "DELETE #destroy" do
    it "deletes a plan" do
      plan # Ensure the plan exists before deleting
      expect {
        delete :destroy, params: { id: plan.id }
      }.to change(Plan, :count).by(-1)
    end
  end

  # Test for POST #generate_reference_plan action
  describe "POST #generate_reference_plan" do
    it "generates a reference plan using OpenAI" do
      # Mock OpenAI API response
      allow_any_instance_of(PlansController).to receive(:call_openai_to_generate_plan).and_return("This is a generated plan.")
      
      post :generate_reference_plan, params: { id: plan.id }
      plan.reload

      expect(plan.reference_plan).to eq("This is a generated plan.")
      expect(response).to redirect_to(edit_plan_path(plan))
    end

    it "handles OpenAI failure gracefully" do
      # Mock OpenAI API failure
      allow_any_instance_of(PlansController).to receive(:call_openai_to_generate_plan).and_return("Unable to generate reference plan, please try again later.")
      
      post :generate_reference_plan, params: { id: plan.id }
      plan.reload

      expect(plan.reference_plan).to eq("Unable to generate reference plan, please try again later.")
      expect(response).to redirect_to(edit_plan_path(plan))
    end
  end

  # Test for GET #export_pdf action
  describe "GET #export_pdf" do
    it "successfully exports the plan as a PDF" do
      get :export_pdf, params: { id: plan.id }

      # Check HTTP response status
      expect(response).to have_http_status(:success)
      expect(response.headers['Content-Type']).to eq 'application/pdf'

      # Parse PDF content
      reader = PDF::Reader.new(StringIO.new(response.body))
      pdf_text = reader.pages.map(&:text).join("\n")

      # Validate PDF content
      expect(pdf_text).to include("Plan Name: Test Plan")
      expect(pdf_text).to include("Plan Description")
      expect(pdf_text).to include("Reference Plan")
    end

    it "returns a 404 error if the plan does not exist" do
      expect {
        get :export_pdf, params: { id: -1 }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
