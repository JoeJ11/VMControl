class UserGroupsController < ApplicationController
  before_action :set_user_group, only: [:show, :edit, :update, :destroy, :join]

  # GET /user_groups
  # GET /user_groups.json
  def index
    @user_groups = UserGroup.all
  end

  # GET /user_groups/1
  # GET /user_groups/1.json
  def show
  end

  # GET /user_groups/new
  def new
    @user_group = UserGroup.new
  end

  # GET /user_groups/1/edit
  def edit
  end

  # POST /user_groups
  # POST /user_groups.json
  def create
    @user_group = UserGroup.new(user_group_params)
    fake_username = "fake_#{@user_group.experiment.name}_#{@user_group.name}"
    student = Student.new
    student.setup_new_user("#{fake_username}@fake.com", fake_username, '233')
    @user_group.fake_user = student.id

    respond_to do |format|
      if @user_group.save
        format.html { redirect_to @user_group, notice: 'User group was successfully created.' }
        format.json { render action: 'show', status: :created, location: @user_group }
      else
        format.html { render action: 'new' }
        format.json { render json: @user_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /user_groups/1
  # PATCH/PUT /user_groups/1.json
  def update
    respond_to do |format|
      if @user_group.update(user_group_params)
        format.html { redirect_to @user_group, notice: 'User group was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_groups/1
  # DELETE /user_groups/1.json
  def destroy
    @user_group.destroy
    respond_to do |format|
      format.html { redirect_to user_groups_url }
      format.json { head :no_content }
    end
  end

  # GET /user_groups/select
  def select
    if session[:exp_id]
      @experiment = Experiment.find(session[:exp_id])
    else
      @experiment = Experiment.find 5
    end
    # @experiment = Experiment.find(flash[:exp_id])
    @user_groups = @experiment.user_groups
    flash = flash
  end

  # GET /user_groups/1/join
  def join
    student = Student.find(session[:user_id])
    @user_group.students.append student
    @user_group.save
    redirect_to controller: 'dispatches', action: 'service', user_name: student.mail_address, exp_id: session[:exp_id], account_name: '', anonym_id: ''
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_group
      @user_group = UserGroup.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_group_params
      params.require(:user_group).permit(:experiment_id, :name)
    end
end
