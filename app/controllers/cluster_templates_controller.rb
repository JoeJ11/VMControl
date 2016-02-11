class ClusterTemplatesController < ApplicationController
  before_action :set_configuration, only: [:show, :edit, :update, :destroy]

  # GET /cluster_templates
  # GET /cluster_templates.json
  def index
    @cluster_templates = ClusterTemplate.all
  end

  # GET /cluster_templates/1
  # GET /cluster_templates/1.json
  def show
  end

  # GET /cluster_templates/new
  def new
    @cluster_template = ClusterTemplate.new
    @images = Machine.list_images
  end

  # GET /cluster_templates/1/edit
  def edit
    @images = Machine.list_images
  end

  # POST /cluster_templates
  # POST /cluster_templates.json
  def create
    @cluster_template = ClusterTemplate.new(configuration_params)
    if session.has_key? :cluster_id and session[:cluster_id]
      @cluster_template.cluster_configuration = ClusterConfiguration.find(session[:cluster_id])
      @cluster_template.save
    end

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

  # PATCH/PUT /cluster_templates/1
  # PATCH/PUT /cluster_templates/1.json
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

  # DELETE /cluster_templates/1
  # DELETE /cluster_templates/1.json
  def destroy
    @cluster_template.destroy
    respond_to do |format|
      format.html { redirect_to cluster_template_urls }
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
