class PlansController < ApplicationController
  before_action :authenticate_user!  # Ensure user is logged in before accessing any action.
  before_action :set_plan, only: [ :show, :edit, :update, :destroy, :generate_reference_plan, :export_pdf ]
  # Load the specific plan for these actions.

  # List all plans, with optional search functionality
  def index
    if params[:query].present?
      # Search plans by name or description containing the query string.
      @plans = current_user.plans.where(
        Plan.arel_table[:name].matches("%#{params[:query]}%")
        .or(Plan.arel_table[:description].matches("%#{params[:query]}%"))
      )
    else
      # Load all plans for the current user if no query is provided.
      @plans = current_user.plans
    end
  end

  # Initialize a new plan for the form
  def new
    @plan = current_user.plans.build  # Associate the new plan with the current user.
  end

  # Create a new plan and save it to the database
  def create
    @plan = current_user.plans.build(plan_params)  # Build a new plan with permitted parameters.
    if @plan.save
      # Redirect to the plans list with a success message if the plan is saved.
      redirect_to plans_path, notice: "Plan created successfully!!!"
    else
      # Re-render the form if saving fails.
      render :new
    end
  end

  def show
  end

  def edit
  end

  # Update a specific plan with new data
  def update
    if @plan.update(plan_params)  # Attempt to update the plan with new parameters.
      redirect_to plans_path, notice: "Plan successful update!!!"
    else
      # Re-render the form if update fails.
      render :edit
    end
  end

  # Delete a specific plan
  def destroy
    @plan = current_user.plans.find(params[:id])  # Find the plan belonging to the current user.
    @plan.destroy  # Delete the plan.
    redirect_to plans_path, notice: "Plan deleted!!!"
  end

  # Generate a reference plan using OpenAI
  def generate_reference_plan
    if @plan.persisted?  # Ensure the plan is saved in the database before generating a reference.
      generated_plan = call_openai_to_generate_plan(@plan.description, @plan.start_time, @plan.end_time)
      # Call OpenAI API to generate the plan.

      @plan.reference_plan = generated_plan  # Assign the generated plan.
      if @plan.save
        Rails.logger.info "The reference plan is saved successfully: #{@plan.reference_plan}"
        # Log success if the generated plan is saved.
      else
        Rails.logger.error "The reference plan save failure: #{@plan.errors.full_messages.join(', ')}"
        # Log failure with error messages.
      end
    else
      Rails.logger.error "The plan is not saved so the reference plan cannot be generated"
      # Log an error if the plan is not saved yet.
    end
    redirect_to edit_plan_path(@plan)  # Redirect back to the edit page for the plan.
  end

  # Export the plan details as a PDF
  def export_pdf
    @plan = Plan.find(params[:id])  # Find the plan by ID.
    pdf = Prawn::Document.new  # Initialize a new Prawn PDF document.
    pdf.text "Plan Name: #{@plan.name}", size: 20, style: :bold  # Add the plan name to the PDF.
    pdf.text "Plan Description: #{@plan.description}", size: 14  # Add the plan description.
    pdf.text "Start Time: #{@plan.start_time.strftime('%Y-%m-%d %H:%M')}", size: 12  # Add start time.
    pdf.text "End Time: #{@plan.end_time.strftime('%Y-%m-%d %H:%M')}", size: 12  # Add end time.
    pdf.move_down 20
    pdf.text "Reference Plan:", size: 16, style: :bold  # Add the reference plan heading.
    pdf.text @plan.reference_plan || "Not yet generated", size: 12  # Add the reference plan content.

    # Send the PDF as an inline file for download or viewing in the browser.
    send_data pdf.render, filename: "plan_#{@plan.id}.pdf", type: "application/pdf", disposition: "inline"
  end

  private

  # Load the specific plan for certain actions
  def set_plan
    @plan = current_user.plans.find(params[:id])  # Ensure the plan belongs to the current user.
  end

  # Strong parameters to permit only the allowed fields for a plan
  def plan_params
    params.require(:plan).permit(:name, :description, :start_time, :end_time, :reference_plan)
  end

  # Call the OpenAI API to generate a reference plan
  def call_openai_to_generate_plan(description, start_time, end_time)
    prompt = <<~PROMPT
      Generate a detailed plan based on the following description:
      description: #{description}
      Start time: #{start_time.strftime('%Y-%m-%d')}
      End time: #{end_time.strftime('%Y-%m-%d')}
      List your planned tasks and schedule in detail.
    PROMPT

    response = HTTParty.post(
      "https://api.openai.com/v1/chat/completions",
      headers: {
        "Authorization" => "Bearer #{ENV['OPENAI_API_KEY']}",  # Use the OpenAI API key from environment variables.
        "Content-Type" => "application/json"
      },
      body: {
        model: "gpt-4",  # Use the GPT-4 model.
        messages: [
          { role: "system", content: "You are a professional plan generator." },  # System message for context.
          { role: "user", content: prompt }  # User message with the prompt for plan generation.
        ],
        max_tokens: 1000,  # Limit the number of tokens in the response.
        temperature: 0.7  # Set the temperature for response creativity.
      }.to_json
    )

    if response.code == 200
      # Parse and return the generated plan content if the response is successful.
      generated_plan = JSON.parse(response.body)["choices"].first["message"]["content"].strip
      generated_plan
    else
      # Return an error message if the API call fails.
      "Unable to generate reference plan, please try again later."
    end
  end
end
