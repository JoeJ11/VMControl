module GitToolkit

  GIT_USER = 'root'
  GIT_KEY = 'passw0rd'
  GIT_BASE_URL = 'http://localhost/api/v3/'
  GIT_TOKEN = '7uHj4p5wBmV3bLHuhr_a'
  GIT_SERVER_ADDRESS = '172.16.10.43'

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods

    # Require a private token for authentification
    def require_token

      if defined?(@@token) == nil
        @@token = nil
      end
      unless @@token.nil?
        return
      end

      response = HTTParty.post(
          GitToolkit::GIT_BASE_URL + 'session',
          :body => {
              :login => GitToolkit::GIT_USER,
              :password => GitToolkit::GIT_KEY
          }
      )
      Rails.logger.info "Git server response (require token): #{response}"
      @@token = response['private_token']
    end

    # List the information of a project
    def list_repo(repo_id)
      response = HTTParty.get(
          GIT_BASE_URL + 'projects/' + repo_id.to_s,
          :headers => {
              'PRIVATE-TOKEN' => GIT_TOKEN
          }
      )
      Rails.logger.info "Git server response (list repo): #{response}"
      return response
    end

  end

  # Create a new user
  def create_git_user(user_name, name)
    # self.class.require_token

    response = HTTParty.post(
        GitToolkit::GIT_BASE_URL + 'users',
        :headers => {
            'PRIVATE-TOKEN' => GIT_TOKEN
        },
        :body => {
            :email => self.mail_address,
            :password => 'pass4git',
            :username => user_name,
            :name => name
        }
    )
    Rails.logger.info "Git server response (create user): #{response}"
    self.git_id = response['id']
    get_token
  end

  # Add SSH User
  def add_ssh_key
    # self.class.require_token

    response = HTTParty.post(
        GitToolkit::GIT_BASE_URL + 'users/' + self.git_id.to_s + '/keys',
        :headers => {
            'PRIVATE-TOKEN' => GIT_TOKEN
        },
        :body => {
            :title => 'DoNotDelete',
            :key => self.public_key
        }
    )
    Rails.logger.info "Git server response (add key): #{response}"
  end

  # Require the token for a user
  def get_token
    response = HTTParty.post(
        GIT_BASE_URL + 'session',
        :body => {
            :email => self.mail_address,
            :password => 'pass4git'
        }

    )
    Rails.logger.info "Git server response (get token): #{response}"
    self.git_token = response['private_token']
  end

  # Create new repo
  def create_repo(repo_name)
    response = HTTParty.post(
        GIT_BASE_URL + 'projects/user/' + self.git_id.to_s,
        :headers => {
            'PRIVATE-TOKEN' => GIT_TOKEN
        },
        :body => {
            :name => repo_name,
            :visibility_level => 20
        }
    )
    Rails.logger.info "Git server response (Create repo): #{response}"
    return response['id']
  end

  # Change the fork relationship
  def admin_fork_repo(dst, src)
    response = HTTParty.post(
        GIT_BASE_URL + 'projects/' + dst.to_s + '/fork/' + src.to_s,
        :headers => {
            'PRIVATE-TOKEN' => GIT_TOKEN
        }
    )
    Rails.logger.info "Git server response (fork repo): #{response}"
  end

  # Fork the specified repo
  def fork_repo(src)
    response = HTTParty.post(
        GIT_BASE_URL + 'projects/fork/' + src.to_s,
        :headers => {
            'PRIVATE-TOKEN' => self.git_token
        }
    )
    Rails.logger.info "Git server response (fork repo): #{response}"
    if response.has_key? 'id'
      return response['id']
    end
    -1
  end

  # Change the visibility of the repo
  def edit_repo(repo_id)
    response = HTTParty.put(
        GIT_BASE_URL + 'projects/' + repo_id.to_s,
        :headers => {
            'PRIVATE-TOKEN' => GIT_TOKEN
        },
        :body => {
            :visibility_level => 0
        }
    )
    Rails.logger.info "Git server response (edit repo): #{response}"
  end

  # Change the name of the repo
  def change_name(repo_id, name)
    response = HTTParty.put(
        GIT_BASE_URL + 'projects/' + repo_id.to_s,
        :headers => {
            'PRIVATE-TOKEN' => GIT_TOKEN
        },
        :body => {
            :name => name
        }
    )
    Rails.logger.info "Git server response (change name): #{response}"
  end

  # Delete a user
  def delete_user
    response = HTTParty.delete(
        GIT_BASE_URL + 'users/' + self.git_id.to_s,
        :headers => {
            'PRIVATE-TOKEN' => GIT_TOKEN
        }
    )
    Rails.logger.info "Git server response (delete user): #{response}"
  end

  # Get a user info
  def get_user
    response = HTTParty.get(
        GIT_BASE_URL + 'users/' + self.git_id.to_s,
        :headers => {
            'PRIVATE-TOKEN' => GIT_TOKEN
        }
    )
    Rails.logger.info "Git server response (get user): #{response}"
    return response
  end

  # Change public repo
  def publicize_repo(repo_id)
    response = HTTParty.put(
        GIT_BASE_URL + 'projects/' + repo_id.to_s,
        :headers => {
            'PRIVATE-TOKEN' => GIT_TOKEN
        },
        :body => {
            :visibility_level => 20
        }
    )
    Rails.logger.info "Git server resposne (publicize repo): #{response}"
  end

  # Add key to a repo
  def add_key_to_repo(repo_id, pub_key)
    response = HTTParty.post(
        GIT_BASE_URL + 'projects/' + repo_id.to_s + '/keys',
        :headers => {
        'PRIVATE-TOKEN' => GIT_TOKEN
        },
        :body => {
            :title => 'DEPLOY_KEY',
            :key => pub_key
        }
    )
    Rails.logger.info "Git server response (add key to repo): #{response}"
  end
end
