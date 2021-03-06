namespace :etradeauth do
  # bundle exec rake etradeauth:start
  task :start => :environment do

    require 'oauth'
    include OAuth::Helper

    CUST_KEY = App.etrade["oauth_consumer_key"]
    CUST_SECRET = App.etrade["consumer_secret"]

    consumer = OAuth::Consumer.new(CUST_KEY, CUST_SECRET, {:site => "https://etws.etrade.com", :http_method => :get})
    request_token = consumer.get_request_token()

    puts "In your browser, go to https://us.etrade.com/e/t/etws/authorize?key=#{escape(CUST_KEY)}&token=#{escape(request_token.token)}"
    puts "Once you have authorized this app, enter your pin here and press enter : "

    pin = $stdin.readline().chomp

    access_token = consumer.get_access_token(request_token,{:oauth_verifier => pin})
    newtoken = EtradeToken.new(:token => access_token.token, :secret => access_token.secret)
    if newtoken.save
        puts "Token has been updated !"
    else
        puts "Failed updating the token !"
    end
  end

end