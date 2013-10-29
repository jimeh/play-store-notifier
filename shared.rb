require 'net/http'
require 'net/https'
require 'uri'
require 'cgi'
require 'fileutils'
require 'yaml'
require 'mail'

#
# Methods
#

def http_get(url)
  uri      = URI.parse(url)
  response = Net::HTTP.get_response(uri)
  response.body
end

def https_get(url)
  uri              = URI.parse(url)
  http             = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl     = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  request  = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)
  response.body
end

def has_notified?(group, device, value = nil)
  file = File.expand_path('../has_notified.yml', __FILE__)

  File.open(file, 'w') { |f| f.write({}.to_yaml) } unless File.exist?(file)
  data = YAML.load_file(file)
  data[group] ||= {}

  if !value.nil?
    data[group][device] = value
    File.open(file, 'w') { |f| f.write(data.to_yaml) }
  else
    data[group][device]
  end
end

def notify(sbj, bdy)
  Mail.deliver do
    from    CONFIG["from"]
    to      CONFIG["to"]
    subject sbj
    body    bdy
  end
end

#
# Config
#

CONFIG  = YAML.load_file File.expand_path("../config.yml", __FILE__)
DEVICES = YAML.load_file File.expand_path("../devices.yml", __FILE__)

Mail.defaults { delivery_method :smtp, CONFIG['smtp'] }
