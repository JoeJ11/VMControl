module GitToolkit

  GIT_USER = 'root'
  GIT_KEY = 'thuvmcontrol'
  GIT_BASE_URL = 'http://thuvmcontrol.cloudapp.net/api/v3/'
  GIT_TOKEN = 'Rs4iykATCeUaBquz7F4L'

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
      puts response
      @@token = response['private_token']
    end

  end

  # Create a new user
  def create_git_user
    # self.class.require_token

    response = HTTParty.post(
        GitToolkit::GIT_BASE_URL + 'users',
        :headers => {
            'PRIVATE-TOKEN' => GIT_TOKEN
        },
        :body => {
            :email => self.mail_address,
            :password => 'pass4git',
            :username => 'mooc_user' + self.id.to_s,
            :name => 'Unknown_user' + self.id.to_s
        }
    )
    puts response
    self.git_id = response['id'].to_s
    get_token
  end

  # Add SSH User
  def add_ssh_key
    # self.class.require_token

    response = HTTParty.post(
        GitToolkit::GIT_BASE_URL + 'users/' + self.git_id + '/keys',
        :headers => {
            'PRIVATE-TOKEN' => GIT_TOKEN
        },
        :body => {
            :title => 'DoNotDelete',
            :key => self.public_key
        }
    )
    puts response
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
    self.git_token = response['private_token']
  end

  # Create new repo
  def create_repo(repo_name)
    response = HTTParty.post(
        GIT_BASE_URL + 'projects/user/' + self.git_id,
        :headers => {
            'PRIVATE-TOKEN' => GIT_TOKEN
        },
        :body => {
            :name => repo_name,
            :visibility_level => 0
        }
    )
    puts response
    return response['id']
  end

  # Fork the specified repo
  def fork_repo(dst, src)
    response = HTTParty.post(
        GIT_BASE_URL + 'projects/' + dst.to_s + '/fork/' + src.to_s,
        :headers => {
            'PRIVATE-TOKEN' => GIT_TOKEN
        }
    )
    puts response
  end

end