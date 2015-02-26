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

    # List all templates(configurations)
    def list_templates
      require_token @tenant_name
      response = HTTParty.get(
                             CloudToolkit::BASE_URL + 'cluster_config',
                             :headers => {
                                 'X-Auth-User' => CloudToolkit::X_AUTH_USER,
                                 'X-Auth-Key' => CloudToolkit::X_AUTH_KEY
                             }
      )
      puts response
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
    # TODO: POST will give an internal server error
    self.class.require_token @tenant_name
    response = HTTParty.post(
                           CloudToolkit::BASE_URL + 'cluster',
                           :query => {
                               'conf_id' => setting['config_id'],
                               'cluster_number' => setting['cluster_number']
                           },
                           :headers => {
                               'X-Auth-User' => CloudToolkit::X_AUTH_USER,
                               'X-Auth-Key' => CloudToolkit::X_AUTH_KEY
                           }
    )
    puts response
    return {:ip_address => '123.456.789.10', :specifier => 'machine ID'}
  end

  # Stop a machine
  def stop_machine
    self.class.require_token @tenant_name
    HTTParty.delete(
                CloudToolkit::BASE_URL + 'cluster/' + self.specifier,
                :headers => {
                    'X-Auth-User' => CloudToolkit::X_AUTH_USER,
                    'X-Auth-Key' => CloudToolkit::X_AUTH_KEY
                }
    )
  end

  # Delete a machine
  # Temporarily the same as stop
  def delete_machine
    stop_machine
  end

  # Get machine status
  def machine_status (specifier)
    self.class.require_token @tenant_name
    response = HTTParty.get(
                           CloudToolkit::BASE_URL + 'cluster/' + self.specifier,
                           :headers => {
                               'X-Auth-User' => CloudToolkit::X_AUTH_USER,
                               'X-Auth-Key' => CloudToolkit::X_AUTH_KEY
                           }
    )
    return {:status => response['status'], :ip => response['ext_ip']}
  end

  # Create a template
  def create_template(settings)
    # TODO: POST will give an internal server error
    self.class.require_token @tenant_name
    response = HTTParty.post(
                           CloudToolkit::BASE_URL + 'cluster_config',
                           :query => {'vms' => settings},
                           :headers => {
                               'X-Auth-User' => CloudToolkit::X_AUTH_USER,
                               'X-Auth-Key' => CloudToolkit::X_AUTH_KEY
                           }
    )
    # self.specifier = response['config_id']
    # self.save
    puts response
  end

  # Delete a configuration
  def delete_template
    self.class.require_token @tenant_name
    HTTParty.delete(
                CloudToolkit::BASE_URL + 'cluster_config/' + self.specifier,
                :headers => {
                    'X-Auth-User' => CloudToolkit::X_AUTH_USER,
                    'X-Auth-Key' => CloudToolkit::X_AUTH_KEY
                }
    )
  end

  # Show configuration details
  def show_template
    self.class.require_token @tenant_name
    response = HTTParty.get(
                CloudToolkit::BASE_URL + 'cluster_config' + self.specifier,
                :headers => {
                    'X-Auth-User' => CloudToolkit::X_AUTH_USER,
                    'X-Auth-Key' => CloudToolkit::X_AUTH_KEY
                }
    )
    puts response
  end

  # Create image
  def create_image
    # TODO: POST will give an internal server error
    self.class.require_token @tenant_name
    response = HTTParty.post(
                           CloudToolkit::BASE_URL + 'images',
                           :query => {
                               'tenant-id' => 'WTF',
                               'instance-id' => '220f77d2-49b0-452f-90f8-440b4f29163a',
                               'image-name' => 'test-image',
                               'members' => []
                           },
                           :headers => {
                               'X-Auth-User' => CloudToolkit::X_AUTH_USER,
                               'X-Auth-Key' => CloudToolkit::X_AUTH_KEY
                           }
    )
    puts response
  end

  # Delete an image
  def delete_image
    self.class.require_token @tenant_name
    HTTParty.delete(
                CloudToolkit::BASE_URL + 'images/' + self.specifier,
                :headers => {
                    'X-Auth-User' => CloudToolkit::X_AUTH_USER,
                    'X-Auth-Key' => CloudToolkit::X_AUTH_KEY
                }
    )
  end

  # Show image information
  def show_image(specifier)
    self.class.require_token @tenant_name
    response = HTTParty.get(
                CloudToolkit::BASE_URL + 'images/' +specifier,
                :headers => {
                    'X-Auth-User' => CloudToolkit::X_AUTH_USER,
                    'X-Auth-Key' => CloudToolkit::X_AUTH_KEY
                }
    )
    puts response
  end

  # Update an image
  def update_image
    self.class.require_token @tenant_name
    response = HTTParty.put(
                           CloudToolkit::BASE_URL + 'images/' + self.specifier,
                           :headers => {
                               'X-Auth-User' => CloudToolkit::X_AUTH_USER,
                               'X-Auth-Key' => CloudToolkit::X_AUTH_KEY
                           }
    )
    puts response
  end

end
