module ProxyToolkit

  PROXY_URL = 'http://crl.ptopenlab.com:8800/thuproxy/'
  PROXY_GENERAL_MODE = 0
  PROXY_SHELL_MODE = 1

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
  end

  def start_proxy(token, mode)
    response = HTTParty.post(
        PROXY_URL + 'thu-manage/create',
        :body => {
            'target' => self.ip_address,
            'token' => token,
            'mode' => mode
        }
    )
    puts response
    return PROXY_URL + response['proxy']
  end

  def stop_proxy
    response = HTTParty.post(
        PROXY_URL + 'thu-manage/delete',
        :body => {
            'target' => self.ip_address
        }
    )
    puts response
  end
end