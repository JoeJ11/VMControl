class ClusterConfiguration < ActiveRecord::Base
  has_many :cluster_templates
  has_many :machines
  has_one :experiment
  include OsCloudToolkit

  def bad_int_ips
    int_ips = []
    flag = false
    self.cluster_templates.each do |template|
      int_ip = template.internal_ip
      int_ips += [int_ip] if int_ip
      if int_ips.uniq != int_ips or template.has_bad_int_ip
        flag = true
        break
      end
    end
    flag
  end

  def instantiate
    settings = []
    cluster_templates.each do |template|
      setting = {
          :name => template.name,
          :image_id => template.image_id,
          :flavor_id => template.flavor_id,
          :internal_ip => template.internal_ip,
          :ext_enable => template.ext_enable,
      }
      settings.push setting
    end
    self.specifier = create_template settings
    self.instantiated = 'true'
    self.save
  end

  def machine_number
    number = 0
    machines.each do |machine|
      unless machine.status == Machine::STATUS_ERROR
        number += 1
      end
    end
    number
  end

  def experiment_number
    experiment.status == Experiment::STATUS_ONLINE ? 1 : 0

    # number = 0
    # experiments.each do |exp|
    #   if exp.status == Experiment::STATUS_ONLINE
    #     number += 1
    #   end
    # end
    # return number
  end

end
