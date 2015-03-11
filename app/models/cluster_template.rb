class ClusterTemplate < ActiveRecord::Base
  belongs_to :cluster_configuration

  def has_bad_int_ip
    ip = self.internal_ip
    if ip == nil
      return true
    end
    if ip.split('.').count != 4
      return true
    end
    ip.split('.').each do |t|
      unless t.scan(/[^0-9]/).empty?
        return true
      end
    end
    return false
  end
end
