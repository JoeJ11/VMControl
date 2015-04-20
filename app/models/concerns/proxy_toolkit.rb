module ProxyToolkit

  PROXY_URL = 'http://thuvmcontrol.cloudapp.net:3000/ssh/'

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
  end

  def start_proxy
    response = HTTParty.get(
        PROXY_URL + 'assign/' + self.ip_address
    )
    puts response
    if response['status'] == 'success'
      return response['url']
    else
      return false
    end
  end

  def stop_proxy
    response = HTTParty.get(
        PROXY_URL + 'release/' + self.ip_address
    )
    puts response
  end

  def release_all
    HTTParty.get(PROXY_URL + 'release-all')
  end
end