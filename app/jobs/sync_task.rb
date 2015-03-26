class SyncTask

  def perform

  end

  def sync_configuration
    remote_configs = ClusterConfiguration.list_templates
    number = 0
    remote_configs.each do |config|
      if ClusterConfiguration.find_by_specifier config['config_id']
        number += 1
      else
        tem_config = ClusterConfiguration.new()
        tem_config.specifier = config['config_id']
        tem_config.delete_template
      end
    end
    unless number == ClusterConfiguration.all.size
      ClusterConfiguration.all.each do |config|
        flag = false
        remote_configs.each do |r_config|
          if r_config['config_id'] == config
            flag = true
          end
        end
        if flag
          config.destroy
        end
      end
    end
  end

  def sync_machine

  end
end