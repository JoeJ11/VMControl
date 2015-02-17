class ClusterTemplatesController < ApplicationController
  before_action :set_configuration, only: [:show, :edit, :update, :destroy]

  # GET /ClusterTemplates
  # GET /ClusterTemplates.json
  def index
    @cluster_templates = ClusterTemplate.all
  end

  # GET /ClusterTemplates/1
  # GET /ClusterTemplates/1.json
  def show
  end

  # GET /ClusterTemplates/new
  def new
    @cluster_template = ClusterTemplate.new
  end

  # GET /ClusterTemplates/1/edit
  def edit
  end

  # POST /ClusterTemplates
  # POST /ClusterTemplates.json
  def create
    @cluster_template = ClusterTemplate.new(configuration_params)

    respond_to do |format|
      if @cluster_template.save
        format.html { redirect_to @cluster_template, notice: 'ClusterTemplate was successfully created.' }
        format.json { render action: 'show', status: :created, location: @cluster_template }
      else
        format.html { render action: 'new' }
        format.json { render json: @cluster_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ClusterTemplates/1
  # PATCH/PUT /ClusterTemplates/1.json
  def update
    respond_to do |format|
      if @cluster_template.update(configuration_params)
        format.html { redirect_to @cluster_template, notice: 'ClusterTemplate was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @cluster_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ClusterTemplates/1
  # DELETE /ClusterTemplates/1.json
  def destroy
    @cluster_template.destroy
    respond_to do |format|
      format.html { redirect_to configurations_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_configuration
      @cluster_template = ClusterTemplate.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def configuration_params
      params.require(:cluster_template).permit(:name, :image_id, :flavor_id, :internal_ip, :external_ip, :ext_enable, :config_id)
    end
end
