require 'net/http'
require 'net/https'
require 'uri'
require 'cgi'
require 'fileutils'
require 'yaml'

require './devices'

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

def has_notified?(device, value = nil)
  file = 'has_notified.yml'

  File.open(file, 'w') { |f| f.write({}.to_yaml) } unless File.exist?(file)
  data = YAML.load_file(file)

  if !value.nil?
    data[device] = value
    File.open(file, 'w') { |f| f.write(data.to_yaml) }
  else
    data[device]
  end
end

DEVICES.each do |device, url|
  print "Checking #{device} availability... "
  body = https_get(url)

  if !body.index('We are out of inventory. Please check back soon.')
    puts "AVAILABLE!"

    if !has_notified?(device)
      puts "Sending notification..."
      http_get("http://nexus4notifier.herokuapp.com/" +
        "send_the_notification_email?device=#{CGI.escape(device)}")
    end

    has_notified?(device, true)
  else
    puts "NOT AVAILABLE"
    has_notified?(device, false)
  end
end
