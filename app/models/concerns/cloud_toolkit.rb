module CloudToolkit

  STATUS_OCCUPIED = 0
  STATUS_AVAILABLE = 1
  STATUS_ONPROCESS = 2
  STATUS_ERROR = 3
  STATUS_PREPARE = 4

  X_AUTH_USER = 'thu_mooc@hotmail.com'
  X_AUTH_KEY = 'pwd4p0wercloud'
  BASE_URL = 'http://172.16.10.39:8080/supernova/'
  ACCOUNT_URL = 'http://ptopenlab.com/cloudlab/api/user/account'
  BASE_ACCOUNT_URL = 'http://ptopenlab.com/cloudlab/api/user/account'
  API_KEY = '86ed353a-4d63-47ea-92a5-9bc3d4daa18c'

  def self.included(base)
    base.extend(ClassMethods)
  end

  # This is where class methods are defined
  module ClassMethods

    # Authentication
    # Require token if no valid token
    # Token is useless temporarily
    def require_token(tenant_name)
      # response = HTTParty.post(CloudToolkit::BASE_URL + 'tokens',
      #               :body => {
      #                   :auth => {
      #                     :tenantName => tenant_name,
      #                     :passwordCredentials => {
      #                         :username => CloudToolkit::X_AUTH_USER,
      #                         :password => CloudToolkit::X_AUTH_KEY
      #                     }
      #                   }
      #               }.to_json,
      #               :headers => {
      #                   'Content-Type' => 'application/json',
      #                   'X-Auth-User' => CloudToolkit::X_AUTH_USER,
      #                   'X-Auth-Key' => CloudToolkit::X_AUTH_KEY
      #               }
      # )
      # response = HTTParty.get('http://localhost:3000/dispatches')
      # return response
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
      Rails.logger.info "Cloud service response (list_machine): #{response}"
      return response['clusters']
    # rescue => exception
    #   redirect_to :back, notice: exception.message
    end

    # List all templates(configurations)
    def list_templates
      require_token @tenant_name
      response = HTTParty.get(
                             CloudToolkit::BASE_URL + 'cluster_config',
                             :headers => {
                                 # 'X-Auth-User' => CloudToolkit::X_AUTH_USER,
                                 # 'X-Auth-Key' => CloudToolkit::X_AUTH_KEY
                             }
      )
      Rails.logger.info "Cloud service response (list templates): #{response}"
      return response['configs']
    end

    # Check if given username is registered
    def check_username(user_name)
      self.class.require_token @tenant_name
      response = HTTParty.post(
                             CloudToolkit::BASE_ACCOUNT_URL,
                             :headers => {
                                 'Content-Type' => 'application/json',
                                 # 'X-Auth-User' => CloudToolkit::X_AUTH_USER,
                                 # 'X-Auth-Key' => CloudToolkit::X_AUTH_KEY
                             },
                             :body => {
                                 'username' => user_name
                             }.to_json
      )
      if response['code'] == 0 or response['code'] == '0'
        return true
      end

      pwd = 'thumooc123'
      HTTParty.post(
          CloudToolkit::BASE_ACCOUNT_URL,
          :headers => {
              'Content-type' => 'application/json',
              'X-Auth-User' => CloudToolkit::X_AUTH_USER,
              'X-Auth-Key' => CloudToolkit::X_AUTH_KEY
          },
          :body => {
              'username' => user_name,
              'passwd' => pwd
          }.to_json
      )
      return false
    end

    # Check if a user exists
    def validate_user(user_name)
      response = HTTParty.post(
          CloudToolkit::BASE_ACCOUNT_URL + '/verify/exist',
          :headers => {
              'Content-Type' => 'application/json',
              # 'X-Auth-User' => CloudToolkit::X_AUTH_USER,
              # 'X-Auth-Key' => CloudToolkit::X_AUTH_KEY,
              'apikey' => CloudToolkit::API_KEY
          },
          :body => {
              'username' => user_name
          }.to_json
      )
      Rails.logger.info "Cloud service response(validate user): #{response}"
      if response['code'] == 0
        return true
      end
      pwd = 'thumooc123'
      HTTParty.post(
          CloudToolkit::BASE_ACCOUNT_URL,
          :headers => {
              'Content-type' => 'application/json',
              # 'X-Auth-User' => CloudToolkit::X_AUTH_USER,
              # 'X-Auth-Key' => CloudToolkit::X_AUTH_KEY,
              'apikey' => CloudToolkit::API_KEY
          },
          :body => {
              'username' => user_name,
              'passwd' => pwd
          }.to_json
      )
      Rails.logger.info "Cloud service response (create user): #{response}"
      return false
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
    self.class.require_token @tenant_name
    Rails.logger.info "Setting for new machine: #{setting}"
    response = HTTParty.post(
                           CloudToolkit::BASE_URL + 'cluster',
                           :body => {
                               'conf_id' => setting[:config_id],
                               'cluster_number' => setting[:cluster_number]
                           }.to_json,
                           :headers => {
                               'Content-type' => 'application/json',
                               'X-Auth-User' => CloudToolkit::X_AUTH_USER,
                               'X-Auth-Key' => CloudToolkit::X_AUTH_KEY
                           }
    )
    Rails.logger.info "Cloud service response (create machine): #{response}"
    if response['clusters']
      self.status = STATUS_ONPROCESS
      self.specifier = response['clusters'][0]['cluster_id']
    else
      self.status = STATUS_ERROR
    end
    self.save
    Delayed::Job.enqueue(MachineStatusJob.new(self.id), 10, 10.seconds.from_now)
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

  # Show the detailed information about a cluster
  def show_machine
    self.class.require_token @tenant_name
    response = HTTParty.get(
                CloudToolkit::BASE_URL + 'cluster/' + self.specifier,
                :headers => {
                    'X-Auth-User' => CloudToolkit::X_AUTH_USER,
                    'X-Auth-Key' => CloudToolkit::X_AUTH_KEY
                }
    )
    Rails.logger.info "Cloud service response (List machine): #{response}"
    if response['status'] == 'CREATE_IN_PROGRESS' or response['status'] == 'DELETE_IN_PROGRESS'
      return { :status => STATUS_ONPROCESS }
    elsif response['status'] == 'CREATE_COMPLETE'
      return { :status => STATUS_AVAILABLE, :ip_address => response['ext_ip'] }
    elsif response['status'] == 'CREATE_FAILED' or response['status'] == 'DELETE_FAILED'
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
    self.class.require_token @tenant_name
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
    self.class.require_token @tenant_name
    response = HTTParty.post(
                           CloudToolkit::BASE_URL + 'cluster_config',
                           :body => {'vms' => settings}.to_json,
                           :headers => {
                               'Content-type' => 'application/json',
                               'X-Auth-User' => CloudToolkit::X_AUTH_USER,
                               'X-Auth-Key' => CloudToolkit::X_AUTH_KEY
                           }
    )
    # self.specifier = response['config_id']
    # self.save
    Rails.logger.info "Cloud service response (create template): #{response}"
    return response['config_id']
  #rescue => exception
  #  return {:error => exception.message}
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
                CloudToolkit::BASE_URL + 'cluster_config/' + self.specifier,
                :headers => {
                    'X-Auth-User' => CloudToolkit::X_AUTH_USER,
                    'X-Auth-Key' => CloudToolkit::X_AUTH_KEY
                }
    )
    Rails.logger.info "Cloud service response (show template): #{response}"
  end

  # Create image
  def create_image(m_id, name)
    self.class.require_token @tenant_name
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
    self.class.require_token @tenant_name
    response = HTTParty.put(
                           CloudToolkit::BASE_URL + 'images/' + self.specifier,
                           :headers => {
                               'X-Auth-User' => CloudToolkit::X_AUTH_USER,
                               'X-Auth-Key' => CloudToolkit::X_AUTH_KEY,
                           }
    )
    puts response
  end

end
