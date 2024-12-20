class PlansController < ApplicationController
  before_action :authenticate_user!
  before_action :set_plan, only: [ :show, :edit, :update, :destroy, :generate_reference_plan, :export_pdf ]

  def index
    @plans = current_user.plans
  end

  def new
    @plan = current_user.plans.build
  end

  def create
    @plan = current_user.plans.build(plan_params)
    if @plan.save
      redirect_to plans_path, notice: "Plan created successfully!!!"
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @plan.update(plan_params)
      redirect_to plans_path, notice: "Plan successful update!!!"
    else
      render :edit
    end
  end

  def destroy
    @plan = current_user.plans.find(params[:id])
    @plan.destroy
    redirect_to plans_path, notice: "Plan deleted!!!"
  end
  
  def generate_reference_plan
    if @plan.persisted?
      generated_plan = call_openai_to_generate_plan(@plan.description, @plan.start_time, @plan.end_time)
      @plan.reference_plan = generated_plan

      if @plan.save
        Rails.logger.info "The reference plan is saved successfully: #{@plan.reference_plan}"
      else
        Rails.logger.error "The reference plan save failure: #{@plan.errors.full_messages.join(', ')}"
      end
    else
      Rails.logger.error "The plan is not saved so the reference plan cannot be generated"
    end
    redirect_to edit_plan_path(@plan)
  end


  def export_pdf
    @plan = Plan.find(params[:id])
    pdf = Prawn::Document.new
    pdf.text "Plan Name: #{@plan.name}", size: 20, style: :bold
    pdf.text "Plan Description: #{@plan.description}", size: 14
    pdf.text "Start Time: #{@plan.start_time.strftime('%Y-%m-%d %H:%M')}", size: 12
    pdf.text "End Time: #{@plan.end_time.strftime('%Y-%m-%d %H:%M')}", size: 12
    pdf.move_down 20
    pdf.text "Reference Plan:", size: 16, style: :bold
    pdf.text @plan.reference_plan || "Not yet generated", size: 12

    send_data pdf.render, filename: "plan_#{@plan.id}.pdf", type: "application/pdf", disposition: "inline"
  end
  def index
    if params[:query].present?
      @plans = current_user.plans.where(
        Plan.arel_table[:name].matches("%#{params[:query]}%")
        .or(Plan.arel_table[:description].matches("%#{params[:query]}%"))
      ) if params[:query].present?
    else
      @plans = current_user.plans
    end
  end

  private

  def set_plan
    @plan = current_user.plans.find(params[:id])
  end

  def plan_params
    params.require(:plan).permit(:name, :description, :start_time, :end_time, :reference_plan)
  end
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
        "Authorization" => "Bearer #{ENV['OPENAI_API_KEY']}",
        "Content-Type" => "application/json"
      },
      body: {
        model: "gpt-4",
        messages: [
          { role: "system", content: "You are a professional plan generator." },
          { role: "user", content: prompt }
        ],
        max_tokens: 1000,
        temperature: 0.7
      }.to_json
    )

    if response.code == 200
      generated_plan = JSON.parse(response.body)["choices"].first["message"]["content"].strip

      generated_plan
    else
      "Unable to generate reference plan, please try again later."
    end
  end
end
