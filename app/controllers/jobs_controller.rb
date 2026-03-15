class JobsController < ApplicationController
  before_action :set_job, only: [:show, :edit, :update, :destroy, :apply, :submit_application]

  def index
    @q = params[:q]
    @jobs = Job.search(@q).order(created_at: :desc).page(params[:page]).per(20) rescue Job.search(@q).order(created_at: :desc)
  end

  def show
  end

  def new
    @job = Job.new
  end

  def create
    @job = Job.new(job_params)
    if @job.save
      redirect_to @job, notice: 'Job created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @job.update(job_params)
      redirect_to @job, notice: 'Job updated.'
    else
      render :edit
    end
  end

  def destroy
    @job.destroy
    redirect_to jobs_path, notice: 'Job removed.'
  end

  # GET /jobs/:id/apply
  def apply
    # if external_url present, redirect to it (shop or external apply flow)
    if @job.external_url.present?
      redirect_to @job.external_url and return
    end
    # otherwise render an internal apply form
  end

  # POST /jobs/:id/apply
  def submit_application
    # placeholder: accept name/email/message and pretend to submit
    # In a real app create an Application model and persist.
    @applicant_name = params[:applicant_name]
    @applicant_email = params[:applicant_email]
    @message = params[:message]
    # for now just redirect
    redirect_to @job, notice: 'Application submitted. The employer will be notified.'
  end

  private
  def set_job
    @job = Job.find(params[:id])
  end

  def job_params
    params.require(:job).permit(:title, :description, :category, :company, :location, :external_url)
  end
end
