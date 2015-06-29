module AzureCloudToolkit

  Azure.configure do |config|
    config.storage_account_name = 'thumooc2015'
    config.storage_access_key = 'MBZ205tjIlK1UQ4Db74dGtSlaEsbPWsJ1rBR973j37j0MJVbkcWaI7Ph10GiU4e6bgeiz/N4NEgHIUG2NJCboA=='

    config.management_certificate = '/Users/Joe/Work/CourseExp/keys/cert.pem'
    config.subscription_id = '8ea61f0d-03d1-430e-94d3-e594d6dadd13'
    config.management_endpoint = 'https://management.core.windows.net'
  end

  STORAGE_ACCOUNT_NAME = 'thumoocy2qawigx'
  AFFINITY_GROUP = 'Wonderland'


  STATUS_OCCUPIED = 0
  STATUS_AVAILABLE = 1
  STATUS_ONPROCESS = 2
  STATUS_ERROR = 3
  STATUS_PREPARE = 4

  def self.included(base)
    base.extend(ClassMethods)
  end

  # This is where class methods go
  module ClassMethods

    # Check if a cloud service name is taken
    def check_cloud_service_name(name)
      cloud_service_manage_service = Azure::CloudServiceManagementService.new
      cloud_service_manage_service.get_cloud_service(name)
    end

  end


  def create_machine
    # setting = JSON.parse(self.setting)
    setting = {}
    config = self.cluster_configuration
    machines = config.cluster_templates

    net_name = create_virtual_network setting
    setting[:virtual_net] = net_name
    service = create_role setting, machines[0]
    setting[:service] = service
    for i in (1...machines.size) do
      add_role setting, machines[i]
    end
    self.status = CloudToolkit::STATUS_ONPROCESS
    self.specifier = service
    self.save
  end

  # create role
  def create_role(setting, machine)
    virtual_machine_service = Azure::VirtualMachineManagementService.new
    service_name = 'mooccluster' + random_string(8)
    while self.class.check_cloud_service_name service_name
      puts service_name
      service_name = 'mooccluster' + random_string(8)
    end

    params = {
        :vm_name => machine.name,
        :vm_user => 'azureuser',
        :image => machine.image_id,
        :password => 'Thumooc_2015',
        :location => 'East US',
        :affinity_group_name => AFFINITY_GROUP
    }
    options = {
        :storage_account_name => STORAGE_ACCOUNT_NAME,
        # :winrm_transport => ['https','http'], #Currently http is supported. To enable https, set the transport protocol to https, simply rdp to the VM once VM is in ready state, export the certificate ( CN name would be the deployment name) from the certstore of the VM and install to your local machine and communicate WinRM via https.
        :cloud_service_name => service_name,
        :deployment_name => 'thu',
        # :tcp_endpoints => '80',
        # :private_key_file => 'c:/private_key.key', #required for ssh or winrm(https) certificate.
        # :certificate_file => 'c:/certificate.pem', #required for ssh or winrm(https) certificate.
        :ssh_port => 22,
        :vm_size => machine.flavor_id, #valid choices are (Basic_A0,Basic_A1,Basic_A2,Basic_A3,Basic_A4,ExtraSmall,Small,Medium,Large,ExtraLarge,A5,A6,A7,A8,A9,Standard_D1,Standard_D2,Standard_D3,Standard_D4,Standard_D11,Standard_D12,Standard_D13,Standard_D14,Standard_DS1,Standard_DS2,Standard_DS3,Standard_DS4,Standard_DS11,Standard_DS12,Standard_DS13,Standard_DS14,Standard_G1,Standard_G2,Standard_G3,Standard_G4,Standard_G5)
        :affinity_group_name => AFFINITY_GROUP,
        :virtual_network_name => setting[:virtual_net],
        :subnet_name => 'subnet',
        # :availability_set_name => 'availabiltyset1',
        # :reserved_ip_name => '192.168.0.2'
    }
    virtual_machine_service.create_virtual_machine(params,options)
    service_name
  end

  # Add role
  def add_role(setting, machine)
    virtual_machine_service = Azure::VirtualMachineManagementService.new
    params = {
        :vm_name => machine.name,
        :cloud_service_name => setting[:service],
        :vm_user => 'azureuser',
        :image => machine.image_id,
        :password => 'Password4test',
    }
    options = {
        :storage_account_name => STORAGE_ACCOUNT_NAME,
        # :winrm_transport => ['https','http'], #Currently http is supported. To enable https, set the transport protocol to https, simply rdp to the VM once VM is in ready state, export the certificate ( CN name would be the deployment name) from the certstore of the VM and install to your local machine and communicate WinRM via https.
        # :tcp_endpoints => '80'
        # :private_key_file => 'c:/private_key.key', #required for ssh or winrm(https) certificate.
        # :certificate_file => 'c:/certificate.pem', #required for ssh or winrm(https) certificate.
        # :winrm_https_port => 5999,
        # :winrm_http_port => 6999, #Used to open different powershell port
        :vm_size => machine.flavor_id, #valid choices are (Basic_A0,Basic_A1,Basic_A2,Basic_A3,Basic_A4,ExtraSmall,Small,Medium,Large,ExtraLarge,A5,A6,A7,A8,A9,Standard_D1,Standard_D2,Standard_D3,Standard_D4,Standard_D11,Standard_D12,Standard_D13,Standard_D14,Standard_DS1,Standard_DS2,Standard_DS3,Standard_DS4,Standard_DS11,Standard_DS12,Standard_DS13,Standard_DS14,Standard_G1,Standard_G2,Standard_G3,Standard_G4,Standard_G5)
        # :availability_set_name => 'availabiltyset'
    }
    virtual_machine_service.add_role(params, options)
  end

  # Create a new virtual network.
  def create_virtual_network(setting)
    virtual_net = Azure::VirtualNetworkManagementService.new
    net_name = 'moocvpn' + random_string(8)

    address_space = ['192.168.0.0/16']
    subnets = [{:name => 'subnet',  :ip_address=>'192.168.0.0',  :cidr=>16}]
    # dns_servers = [{:name => 'dns-1',  :ip_address=>'30.30.30.1'}]
    options = {:subnet => subnets}

    virtual_net.set_network_configuration(net_name, AFFINITY_GROUP, address_space, options)
    net_name
  end

  # Delete machine
  def delete_machine
    virtual_machine_service = Azure::VirtualMachineManagementService.new
    virtual_machine_service.delete_virtual_machine('name', 'service')
  end

  def random_string(length)
    rand(36**length).to_s(36)
  end
end