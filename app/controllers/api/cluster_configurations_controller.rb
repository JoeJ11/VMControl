class Api::ClusterConfigurationsController < ApplicationController
  before_action :set_cluster_configuration, only: [:show, :destroy]

  def create
    cluster_configuration_params = params.require(:cluster_configuration).permit(:specifier, :size)
    @cc = ClusterConfiguration.new(cluster_configuration_params)
    templates = cluster_configuration_params['templates']
    @cluster_configuration.instantiated = 'false'
    if cluster_configuration_params['size'].to_i == templates.size
      templates.each do |template_param|
        @cluster_configuration.cluster_templates += [ClusterTemplate.create(template_param)]
      end
    else
      render json: {warning: 'create configuration failed!'}
    end
  end

  def show
    response = {specifier: @cc.specifier,
                  size: @cc.size,
                  instantiated: @cc.instantiated}
    response[:templates]=[]
    @cc.cluster_templates.each do |ct|
      response[:templates].push({ name: ct.name,
                                image: ct.image_id,
                                flavor: ct.flavor_id,
                                internal_ip: ct.internal_ip })
    end
    render json: response
  end

  def destroy
    @cc.destroy
  end

  def index
    render json: ClusterConfiguration.all
  end

  def set_cluster_configuration
    @cc = ClusterConfiguration.find(params[:id])
  end

end
