require './shared'

DEVICES['stock_check'].each do |device, url|
  print "[#{Time.now}] Checking \"#{device}\" availability... "
  body = https_get(url)

  if !body.include?('We are out of inventory. Please check back soon.')
    puts "AVAILABLE!"

    if !has_notified?("stock", device)
      puts "[#{Time.now}] Sending notification..."
      notify("#{device} is AVAILABLE!", "#{device}: #{url}")
    end

    has_notified?("stock", device, true)
  else
    puts "NOT AVAILABLE"
    has_notified?("stock", device, false)
  end
end
