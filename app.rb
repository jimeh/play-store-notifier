require 'sinatra'
require 'mail'

require './devices'

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
  device = params[:device]
  mail = Mail.new do
    from     ENV['FROM_EMAIL']
    to       ENV['TO_EMAIL']
    subject  "#{device} NOW AVAILABLE!!"
    body     "#{DEVICES[device]}"
  end

  mail.deliver!
  "Success!"
end
