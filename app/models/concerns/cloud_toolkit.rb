module CloudToolkit

  STATUS_OCCUPIED = 0
  STATUS_AVAILABLE = 1
  STATUS_ONPROCESS = 2
  X_AUTH_USER = 'andyjvan@gmail.com'
  X_AUTH_KEY = 'pass4test'
  BASE_URL = 'https://crl.ptopenlab.com:8800/supernova/'

  def self.included(base)
    base.extend(ClassMethods)
  end

  # This is where class methods are defined
  module ClassMethods

    # Authentication
    # Require token if no valid token
    def require_token(tenant_name)
      response = HTTParty.post(CloudToolkit::BASE_URL + 'tokens',
                    :query => {
                        :auth => {
                          :tenantName => tenant_name,
                          :passwordCredentials => {
                              :username => CloudToolkit::X_AUTH_USER,
                              :password => CloudToolkit::X_AUTH_KEY
                          }
                        }
                    },
                    :headers => {
                        'X-Auth-User' => CloudToolkit::X_AUTH_USER,
                        'X-Auth-Key' => CloudToolkit::X_AUTH_KEY
                    }
      )
      #response = HTTParty.get('http://localhost:3000/dispatches')
      return response
    end

    # List info for all machines
    def list_machines
      require_token @tenant_name
      response = HTTParty.get(CloudToolkit::BASE_URL + 'cluster',
                              :headers => {
                                  'X-Auth-User' => CloudToolkit::X_AUTH_USER,
                                  'X-Auth-Key' => CloudToolkit::X_AUTH_KEY
                              }
      )
      puts response
      return ['Test Machine']
    end
  end

  # Do nothing but add class variable @tenant_name
  # def initialize
  #   @tenant_name = ''
  # end

  # Set tenant_name.
  def set_tenant_name(tenant_name)
    @tenant_name = tenant_name
  end

  # Generate a new machine and return machine config info
  # The config info should include "ip_address", "specifier"
  def create_machine(setting)
    ClassMethods.require_token @tenant_name
    return {:ip_address => '123.456.789.10', :specifier => 'machine ID'}
  end

  # Stop a machine
  def stop_machine
    ClassMethods.require_token @tenant_name
  end

  # Delete a machine
  def delete_machine
    ClassMethods.require_token @tenant_name
  end

  # Get machine status
  def machine_status (specifier)
    ClassMethods.require_token @tenant_name
    return {:name => 'Test Machine'}
  end

end
