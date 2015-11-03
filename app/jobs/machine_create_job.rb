class MachineCreateJob < Struct.new(:params)

  def perform
    config = ClusterConfiguration.find params[:cluster_configuration_id]
    if config and config.machine_number < Machine::MAXIMUM_MACHINES
      setting = { 'master' => nil, 'slaves' => [] }
      config.cluster_templates.each do |t|
        if t.ext_enable
          setting['master'] = t.generate_config
        else
          setting['slaves'].push t.generate_config
        end
      end
      new_params = {
          :setting => JSON.generate(setting),
          :cluster_configuration => config,
      }
      machine = Machine.new(new_params)
      machine.start
      sleep(5.seconds)
    end
  end

end
