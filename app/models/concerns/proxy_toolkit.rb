module ProxyToolkit

  Return_URL = 'https://crl.ptopenlab.com:8800/thuproxy/'
  PROXY_URL = 'http://172.16.10.43:3000/thuproxy/'
  PROXY_GENERAL_MODE = 0
  PROXY_SHELL_MODE = 1

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
  end

  def start_proxy(token, mode)
    Rails.logger.info "Start a proxy to IP: #{self.ip_address}"
    response = HTTParty.post(
        PROXY_URL + 'thu-manage/create',
        :body => {
            'target' => self.ip_address,
            'token' => token,
            'mode' => mode
        }
    )
    Rails.logger.info "Proxy service response (start proxy): #{response}"
    return Return_URL + response['proxy']
  end

  def stop_proxy
    response = HTTParty.post(
        PROXY_URL + 'thu-manage/delete',
        :body => {
            'target' => self.ip_address
        }
    )
    Rails.logger.info "Proxy service response (stop proxy): #{response}"
  end
end
