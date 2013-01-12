require 'net/http'
require 'net/https'
require 'uri'

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

def has_notified?(input = nil)
  if !input.nil?
    File.open('has_notified.txt', 'w') { |f| f.write(input ? 'yes' : 'no') }
  else
    if File.exist?('has_notified.txt')
      File.read('has_notified.txt').strip == 'yes'
    else
      File.open('has_notified.txt', 'w') { |f| f.write('no') }
    end
  end
end

print "Checking Nexus 4 availability... "
body = https_get('https://play.google.com/store/devices/details?id=nexus_4_16gb')

if !body.index('We are out of inventory. Please check back soon.')
  puts "AVAILABLE!"

  if !has_notified?
    puts "Sending notification..."
    http_get('http://nexus4notifier.herokuapp.com/send_the_notification_email')
  end

  has_notified?(true)
else
  puts "NOT AVAILABLE"
  has_notified?(false)
end
