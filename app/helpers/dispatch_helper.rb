module DispatchHelper
end

module CloudToolkit

  STATUS_OCCUPIED = 0
  STATUS_AVAILABLE = 1
  STATUS_ONPROCESS = 2

  def initialize
    @tenant_name = ''
  end

  def set_tenant_name(tenant_name)
    @tenant_name = ''
  end

  def self.require_token(tenant_name)
  end

  def self.list_machines
    CloudToolkit.require_token @tenant_name
    return ["Test Machine"]
  end

  def create_machine(setting)
    CloudToolkit.require_token @tenant_name
  end

  def stop_machine
    CloudToolkit.require_token @tenant_name
  end

  def delete_machine
    CloudToolkit.require_token @tenant_name
  end

  def machine_status (specifier)
    CloudToolkit.require_token @tenant_name
    return {:name => "Test Machine"}
  end
end
