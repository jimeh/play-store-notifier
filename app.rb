require 'sinatra'
require 'mail'

Mail.defaults do
  delivery_method :smtp, {
    :address        => 'smtp.sendgrid.net',
    :port           => '587',
    :authentication => :plain,
    :user_name      => ENV['SENDGRID_USERNAME'],
    :password       => ENV['SENDGRID_PASSWORD'],
    :domain         => 'heroku.com'
  }
end

get '/' do
  "hi"
end

get '/send_the_notification_email' do
  mail = Mail.new do
    from     'contact@jimeh.me'
    to       'contact@jimeh.me'
    subject  'Nexus 4 16GB NOW AVAILABLE!!'
    body     'https://play.google.com/store/devices/details?id=nexus_4_16gb'
  end

  mail.deliver!
  "Success!"
end
