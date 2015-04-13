class StudentsController < ApplicationController
  before_action :set_student, only: [:show, :edit, :update, :destroy]

  # GET /students
  # GET /students.json
  def index
    @students = Student.all
  end

  # GET /students/1
  # GET /students/1.json
  def show
  end

  # GET /students/new
  def new
    @student = Student.new
  end

  # GET /students/1/edismp9t
  def edit
  end

  # POST /students
  # POST /students.json
  def create
    @student = Student.new(student_params)

    respond_to do |format|
      if @student.save
        format.html { redirect_to @student, notice: 'Student was successfully created.' }
        format.json { render action: 'show', status: :created, location: @student }
      else
        format.html { render action: 'new' }
        format.json { render json: @student.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /students/1
  # PATCH/PUT /students/1.json
  def update
    respond_to do |format|
      if @student.update(student_params)
        format.html { redirect_to @student, notice: 'Student was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @student.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /students/1
  # DELETE /students/1.json
  def destroy
    @student.delete_user
    @student.destroy
    respond_to do |format|
      format.html { redirect_to students_url }
      format.json { head :no_content }
    end
  end

  # Get /students/1/assign
  # Get /students/1/assign.json
  # def assign
  #   if @student.machine and @student.machine.status == CloudToolkit::STATUS_OCCUPIED
  #     render json: { :address => @student.machine.ip_address } and return
  #   end
  #   machine = Machine.find_by_status CloudToolkit::STATUS_AVAILABLE
  #   if machine
  #     ip_address = '0.0.0.0' #machine.assign @student.id
  #     # MachineControlJob.new(machine.id).perform
  #     Delayed::Job.enqueue(MachineControlJob.new(machine.id), 100, 5.minute.from_now)
  #     render json: { :address => ip_address }
  #   else
  #     render json: { :information => "No available machine!"}
  #   end
  # end

  # Get /students/1/release
  # Get /students/1/release.json
  # def release
  #   if @student.machine and @student.machine == CloudToolkit::STATUS_OCCUPIED
  #     @student.machine.restart
  #   end
  #   redirect_to :back
  # end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_student
      @student = Student.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def student_params
      params.require(:student).permit(:xuetang_id, :mail_address, :public_key)
    end
end
