module ProxyToolkit

  PROXY_URL = 'http://thuwebproxy.cloudapp.net:3000/thu-manage/'
  PROXY_GENERAL_MODE = 0
  PROXY_SHELL_MODE = 1

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
  end

  def start_proxy(token, mode)
    response = HTTParty.post(
        PROXY_URL + 'create',
        :body => {
            'target' => self.ip_address,
            'token' => token,
            'mode' => mode
        }
    )
    puts response
    if response['status'] == 'success'
      return response['url']
    else
      return false
    end
  end

  def stop_proxy
    response = HTTParty.post(
        PROXY_URL + 'delete',
        :body => {
            'target' => self.ip_address
        }
    )
    puts response
  end

  def release_all
    HTTParty.get(PROXY_URL + 'release-all')
  end
end