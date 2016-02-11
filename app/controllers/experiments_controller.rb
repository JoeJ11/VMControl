class ExperimentsController < ApplicationController
  before_action :set_experiment, only: [:show, :edit, :update, :destroy, :start, :stop]

  # GET /experiments
  # GET /experiments.json
  def index
    @experiments = Experiment.all
  end

  # GET /experiments/1
  # GET /experiments/1.json
  def show
    @port_list = JSON.load(@experiment.port)
  end

  # GET /experiments/new
  def new
    @cluster_configurations = ClusterConfiguration.all
    @courses = Course.all
    @experiment = Experiment.new
  end

  # GET /experiments/1/edit
  def edit
  end

  # POST /experiments
  # POST /experiments.json
  def create
    @experiment = Experiment.new(experiment_params)
    # repo = @experiment.course.setup_repo(@experiment.name)
    # @experiment.code_repo_id = repo[:code]
    # @experiment.config_repo_id = repo[:config]

    respond_to do |format|
      if @experiment.save
        format.html { redirect_to @experiment, notice: 'Experiment was successfully created.' }
        format.json { render action: 'show', status: :created, location: @experiment }
      else
        format.html { render action: 'new' }
        format.json { render json: @experiment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /experiments/1
  # PATCH/PUT /experiments/1.json
  def update
    respond_to do |format|
      if @experiment.update(experiment_params)
        format.html { redirect_to @experiment, notice: 'Experiment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @experiment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /experiments/1
  # DELETE /experiments/1.json
  def destroy

    @experiment.destroy
    respond_to do |format|
      format.html { redirect_to experiments_url }
      format.json { head :no_content }
    end
  end

  # GET /experiments/1/start
  # GET /experiments/1/start.json
  def start
     respond_to do |format|
       if @experiment.start
         format.html { redirect_to :back }
         format.json { render json: {:status => 'Succeed'}.to_json }
       else
         format.html { redirect_to :back }
         format.html { render json: {:status => 'Fail to update database.'}.to_json }
       end
     end
  end

  # GET /experiments/1/stop
  # GET /experiments/1/stop.json
  def stop
    respond_to do |format|
      if @experiment.stop
        format.html { redirect_to :back }
        format.json { render json: {:status => 'Succeed'}.to_json }
      else
        format.html { redirect_to :back }
        format.html { render json: {:status => 'Fail to update database.'}.to_json }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_experiment
      @experiment = Experiment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def experiment_params
      tem = params.require(:experiment).permit(:name, :cluster_configuration, :course, :port)
      port_map = {}
      tem[:port].split(';').each do |line|
        tem_line = line.split(':')
        port_map[tem_line[0]] = tem_line[1]
      end
      tem[:port] = JSON.generate(port_map)
      tem[:cluster_configuration] = ClusterConfiguration.find tem[:cluster_configuration].to_i
      tem[:course] = Course.find tem[:course]
      tem
    end
end
