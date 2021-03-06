# frozen_string_literal: true

class TasksController < ApplicationController
  before_action :set_task, only: %i(show edit update destroy)

  def index
    # @task = current_user.tasks.order('created_at DESC')
    @q = current_user.tasks.ransack(params[:q])
    @tasks = @q.result(distinct: true).page(params[:page]).order('created_at DESC')
    #
    # respond_to do |format|
    #  format.html
    #  format.csv { send_data @tasks.generate_csv, filename: "task-#{Time.zone.now.strftime('%Y%m%d%S')}" }
    # end
  end

  def show; end

  def new
    @task = Task.new
  end

  def confirm_new
    @task = current_user.tasks.new(task_params)
    render :new unless @task.valid?
  end

  def create
    @task = current_user.tasks.new(task_params)

    if params[:back].present?
      render :new
      return
    end

    if @task.save
      # TaskMailer.creation_email(@task).deliver_now
      # ampleJob.perform_later
      redirect_to @task, notice: "タスク「#{@task.name}」を登録しました。"
    else
      render :new
    end
  end

  def edit; end

  def update
    @task.update!(task_params)
    redirect_to tasks_url, notice: "タスク「#{@task.name}」を更新しました。"
  end

  def destroy
    @task.destroy
    # head :no_content
  end

  def import
    current_user.tasks.import(params[:file])
    redirect_to tasks_url, notice: 'タスクを追加しました。'
  end

  private

  def task_params
    params.require(:task).permit(:name, :description, :image)
  end

  def set_task
    @task = current_user.tasks.find(params[:id])
  end
end
