class ClusterConfiguration < ActiveRecord::Base
  has_many :cluster_templates
  include CloudToolkit

  def bad_int_ips
    int_ips = []
    flag = false
    self.cluster_templates.each do |template|
      int_ip = template.internal_ip
      int_ips += [int_ip]
      if int_ips.uniq != int_ips or template.has_bad_int_ip
        flag = true
        break
      end
    end
    return flag
  end

  def instantiate
    settings = []
    cluster_templates.each do |template|
      setting = {
          'name' => template.name,
          'image_id' => template.image_id,
          'flavor_id' => template.flavor_id,
          'internal_ip' => template.internal_ip,
          'ext_enable' => template.ext_enable,
      }
      settings.push setting
    end
    self.specifier = create_template settings
    self.instantiated = 'true'
    self.save
  end

end
