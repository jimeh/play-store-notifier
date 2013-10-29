require './shared'

url = "https://play.google.com/store/devices"

DEVICES['exist_check'].each do |device|
  print "[#{Time.now}] Checking \"#{device}\" device existance... "
  body = https_get(url)

  if body.index(device)
    puts "EXISTS!"

    if !has_notified?("exist", device)
      puts "[#{Time.now}] Sending notification..."
      notify("#{device} now EXISTS!", "#{device}: #{url}")
    end

    has_notified?("exist", device, true)
  else
    puts "DOES NOT EXIST! :("
    has_notified?("exist", device, false)
  end
end
