module AzureCloudToolkit

  Azure.configure do |config|
    config.storage_account_name = 'thumooc2015'
    config.storage_access_key = 'MBZ205tjIlK1UQ4Db74dGtSlaEsbPWsJ1rBR973j37j0MJVbkcWaI7Ph10GiU4e6bgeiz/N4NEgHIUG2NJCboA=='

    config.management_certificate = '/Users/Joe/Work/CourseExp/keys/cert.pem'
    config.subscription_id = '8ea61f0d-03d1-430e-94d3-e594d6dadd13'
    config.management_endpoint = 'https://management.core.windows.net'
  end

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
    virtual_machine_service = Azure::VirtualMachineManagementService.new
    service_name = 'mooccluster' + random_string(8)
    while self.class.check_cloud_service_name service_name
      puts service_name
      service_name = 'mooccluster' + random_string(8)
    end

    puts 'Create machine...'
    params = {
        :vm_name => 'remote_machine',
        :vm_user => 'azureuser',
        :image => 'GraphMaster1',
        :password => 'Thumooc_2015',
        :location => 'East US',
        :affinity_group_name => 'Wonderland'
    }
    options = {
        :storage_account_name => 'thumoocy2qawigx',
        # :winrm_transport => ['https','http'], #Currently http is supported. To enable https, set the transport protocol to https, simply rdp to the VM once VM is in ready state, export the certificate ( CN name would be the deployment name) from the certstore of the VM and install to your local machine and communicate WinRM via https.
        :cloud_service_name => service_name,
        :deployment_name => 'thu',
        :tcp_endpoints => '80,3389:3390',
        # :private_key_file => 'c:/private_key.key', #required for ssh or winrm(https) certificate.
        # :certificate_file => 'c:/certificate.pem', #required for ssh or winrm(https) certificate.
        :ssh_port => 22,
        :vm_size => 'Basic_A1', #valid choices are (Basic_A0,Basic_A1,Basic_A2,Basic_A3,Basic_A4,ExtraSmall,Small,Medium,Large,ExtraLarge,A5,A6,A7,A8,A9,Standard_D1,Standard_D2,Standard_D3,Standard_D4,Standard_D11,Standard_D12,Standard_D13,Standard_D14,Standard_DS1,Standard_DS2,Standard_DS3,Standard_DS4,Standard_DS11,Standard_DS12,Standard_DS13,Standard_DS14,Standard_G1,Standard_G2,Standard_G3,Standard_G4,Standard_G5)
        :affinity_group_name => 'Wonderland',
        :virtual_network_name => 'test_virtual_net',
        :subnet_name => 'subnet-1',
        # :availability_set_name => 'availabiltyset1',
        :reserved_ip_name => '192.168.0.2'
    }
    virtual_machine_service.create_virtual_machine(params,options)

  end

  # Create a new virtual network.
  def create_virtual_network
    virtual_net = Azure::VirtualNetworkManagementService.new

    address_space = ['192.168.0.0/12']
    subnets = [{:name => 'subnet-1',  :ip_address=>'192.168.0.0',  :cidr=>12}]
    # dns_servers = [{:name => 'dns-1',  :ip_address=>'30.30.30.1'}]
    options = {:subnet => subnets}

    virtual_net.set_network_configuration('test_virtual_net', 'Wonderland', address_space, options)
  end

  def random_string(length)
    rand(36**length).to_s(36)
  end
end