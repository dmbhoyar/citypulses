class JobsController < ApplicationController
  before_action :set_job, only: [:show, :edit, :update, :destroy, :apply, :submit_application]
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]

  def index
    @q = params[:q]
    @jobs = Job.search(@q).order(created_at: :desc).page(params[:page]).per(20) rescue Job.search(@q).order(created_at: :desc)
    # scope to city if selector present
    @jobs = @jobs.where(city_id: params[:city_id]) if params[:city_id].present?
  end

  def show
  end

  def new
    # only shopowners or superadmin can create jobs
    unless current_user && (current_user.shopowner? || current_user.superadmin?)
      redirect_to jobs_path, alert: 'Only shop owners can create jobs.' and return
    end
    @job = Job.new
  end

  def create
    unless current_user && (current_user.shopowner? || current_user.superadmin?)
      redirect_to jobs_path, alert: 'Only shop owners can create jobs.' and return
    end
    @job = Job.new(job_params)
    @job.user = current_user
    @job.city_id ||= current_user.shops.first&.city_id
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
    @application = @job.job_applications.build(
      name: params[:applicant_name],
      email: params[:applicant_email],
      phone: params[:applicant_phone],
      message: params[:message],
      resume_url: params[:resume_url]
    )
    if @application.save
      redirect_to @job, notice: 'Application submitted. The employer will be notified.'
    else
      flash[:alert] = 'There was a problem submitting your application.'
      render :apply
    end
  end

  private
  def set_job
    @job = Job.find(params[:id])
  end

  def job_params
    params.require(:job).permit(:title, :description, :category, :company, :location, :external_url)
  end
end
