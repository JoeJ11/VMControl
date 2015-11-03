module OsCloudToolkit

  ENABLE_VPN = false

  STATUS_OCCUPIED = 0
  STATUS_AVAILABLE = 1
  STATUS_ONPROCESS = 2
  STATUS_ERROR = 3
  STATUS_PREPARE = 4
  STATUS_DELETED = 5

  X_AUTH_USER = 'anju'
  X_AUTH_KEY = 'rDqxLz6hJ7-i'
  BASE_URL = 'http://218.247.230.193:5000/'
  TENANT_ID = 'caf6d92f5f794da393e00dee6ce781fc'
  SERVER_URL = 'http://10.1.1.250:8774/'
  NETWORK_URL = 'http://10.1.1.250:9696/'
  IMAGE_URL = 'http://10.1.1.250:9292/'

  def self.included(base)
    base.extend(ClassMethods)
  end

  # This is where class methods are defined
  module ClassMethods
    # Authentication
    # Require token if no valid token
    # Token is useless temporarily
    def require_token
      response = HTTParty.post(
        BASE_URL + 'v2.0/tokens',
        :headers => {
          'Content-Type' => 'application/json'
        },
        :body => {
          "auth" => {
            "tenantId" => TENANT_ID,
            "passwordCredentials" => {
              "username" => X_AUTH_USER,
              "password" => X_AUTH_KEY
            }
          }
        }.to_json
      )
      Rails.logger.info "Cloud service response (require token): #{response}"
      @@API_KEY = response['access']['token']['id']
      return @@API_KEY
    end

    # List info for all machines
    def list_machines
      require_token
      response = HTTParty.get(
        SERVER_URL + "v2/#{TENANT_ID}/servers",
        :headers => {
          'X-Auth-Token' => @@API_KEY
        }
      )
      Rails.logger.info "Cloud service response (list_machine): #{response}"
      return response['servers']
    end

    # List all templates(configurations)
    # def list_templates
    # end

    # Check if given username is registered
    def check_username(user_name)
      True
    end

    # Check if a user exists
    def validate_user(user_name)
      True
    end

  end

  # Set tenant_name.
  def set_tenant_name(tenant_name)
    @tenant_name = tenant_name
  end

  # Generate a new machine and return machine config info
  # The config info should include "ip_address", "specifier"
  def create_machine(setting)
    key = self.class.require_token
    Rails.logger.info "Setting for new machine: #{setting}"
    response = HTTParty.post(
      "#{SERVER_URL}v2/#{TENANT_ID}/servers",
      :body => {
        'server' => {
          'name' => rand_string,
          'imageRef' => setting[:image_id],
          'flavorRef' => setting[:flavor_id],
          'networks' => [{
            'uuid' => setting[:network_id]
          }]
        }
      }.to_json,
      :headers => {
        'Content-type' => 'application/json',
        'X-Auth-Token' => key
      }
    )
    Rails.logger.info "Cloud service response (create machine): #{response}"
    if response.code == 202
      self.status = STATUS_ONPROCESS
      self.specifier = response['server']['id']
    else
      self.status = STATUS_ERROR
    end
    self.save
    Delayed::Job.enqueue(MachineStatusJob.new(self.id), 10, 10.seconds.from_now)
  end

  # Stop a machine
  def stop_machine
    key = self.class.require_token
    HTTParty.delete(
      "#{SERVER_URL}v2/#{TENANT_ID}/servers/#{self.specifier}",
      :headers => {
        'X-Auth-Token' => key
      }
    )
  end

  # Show the detailed information about a cluster
  def show_machine
    key = self.class.require_token
    response = HTTParty.get(
      "#{SERVER_URL}v2/#{TENANT_ID}/servers/#{self.specifier}",
      :headers => {
        'X-Auth-Token' => key
      }
    )
    Rails.logger.info "Cloud service response (List machine): #{response}"
    if response.code == 404
      return { :status => STATUS_DELETED}
    end
    status = response['server']['status']
    puts status
    if status == 'BUILD'
      return { :status => STATUS_ONPROCESS }
    elsif status == 'ACTIVE'
      address = response['server']['addresses']
      return { :status => STATUS_AVAILABLE, :ip_address => address[address.keys[0]][0]['addr'] }
    elsif status == 'CREATE_FAILED' or status == 'DELETE_FAILED'
      return { :status => STATUS_ERROR }
    else
      return { :status => -1 }
    end
  end

  # Delete a machine
  # Temporarily the same as stop
  def delete_machine
    stop_machine
  end

  # Get machine status
  def machine_status
    self.class.require_token
    response = HTTParty.get(
                           CloudToolkit::BASE_URL + 'cluster/' + self.specifier,
                           :headers => {
                               'X-Auth-User' => CloudToolkit::X_AUTH_USER,
                               'X-Auth-Key' => CloudToolkit::X_AUTH_KEY
                           }
    )
    Rails.logger.info "Cloud service response (machine status): #{response}"
    return {:status => response['status'], :ip => response['ext_ip']}
  end

  # Create a template
  def create_template(settings)
  end

  # Delete a configuration
  def delete_template
  end

  # Show configuration details
  def show_template
  end

  # Create image
  def create_image(m_id, name)
    self.class.require_token
    response = HTTParty.post(
                           CloudToolkit::BASE_URL + 'images',
                           :body => {
                               # 'tenant-id' => 'WTH',
                               'instance_id' => m_id,
                               'image_name' => name,
                               'members' => [X_AUTH_USER]
                           }.to_json,
                           :headers => {
                               'Content-type' => 'application/json',
                               'X-Auth-User' => CloudToolkit::X_AUTH_USER,
                               'X-Auth-Key' => CloudToolkit::X_AUTH_KEY
                           }
    )
    Rails.logger.info "Cloud service response (create image): #{response}"
  end

  # Delete an image
  def delete_image
    self.class.require_token
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
    self.class.require_token
    response = HTTParty.get(
                CloudToolkit::BASE_URL + 'images/' + specifier,
                :headers => {
                    'X-Auth-User' => CloudToolkit::X_AUTH_USER,
                    'X-Auth-Key' => CloudToolkit::X_AUTH_KEY,
                }
    )
    puts response
  end

  # Update an image
  def update_image
    self.class.require_token
    response = HTTParty.put(
                           CloudToolkit::BASE_URL + 'images/' + self.specifier,
                           :headers => {
                               'X-Auth-User' => CloudToolkit::X_AUTH_USER,
                               'X-Auth-Key' => CloudToolkit::X_AUTH_KEY,
                           }
    )
    puts response
  end

  def rand_string
    wait_list = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
    return (0..10).map { wait_list[rand(wait_list.length)] }.join
  end

end
