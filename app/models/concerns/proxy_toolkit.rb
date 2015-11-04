module ProxyToolkit

  Return_URL = 'https://218.247.230.203:8800/'
  PROXY_URL = 'http://218.247.230.203:3000/'
  PROXY_GENERAL_MODE = 0
  PROXY_SHELL_MODE = 1

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
  end

  def start_proxy(token, mode, target_url)
    Rails.logger.info "Start a proxy to URL: #{target_url}"
    response = HTTParty.post(
        PROXY_URL + 'thu-manage/create',
        :body => {
            'target' => target_url,
            'token' => token,
            'mode' => mode
        }
    )
    Rails.logger.info "Proxy service response (start proxy): #{response}"
    return Return_URL + response['proxy'] + '/'
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
