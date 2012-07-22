#!/usr/bin/env ruby
# encoding: utf-8

require 'amqp'
require 'dalli'
require 'em-http-request'
require 'em-pusher'

AMQP_URL      = ENV['CLOUDAMQP_URL']
EXCHANGE_NAME =     'com.herokuapp.delayed-webrequest'
QUEUE_NAME    =     'com.herokuapp.delayed-webrequest'

DALLI_CLIENT=Dalli::Client.new \
                 ENV['MEMCACHIER_SERVERS' ], {
    :username => ENV['MEMCACHIER_USERNAME'],
    :password => ENV['MEMCACHIER_PASSWORD']  }

PUSHER = EM::Pusher.new \
    :app_id      => ENV['PUSHER_APP_ID'],
    :auth_key    => ENV['PUSHER_KEY'   ],
    :auth_secret => ENV['PUSHER_SECRET'],
    :channel     =>     'test_channel'


##url = 'http://whoismyrepresentative.com/whoismyrep.php?zip=46544'

c = 0

EM.run do
  connection = AMQP.connect AMQP_URL
  channel = AMQP::Channel.new connection
  exchange = channel.direct EXCHANGE_NAME
  queue = channel.queue QUEUE_NAME
  queue.bind exchange
  queue.subscribe do |payload|
    p(url = payload)

    http = EM::HttpRequest.new(url).get
    http.errback { p "Bad DNS: #{url}" }
    http.headers do |hash|
      headers_before = [:headers, hash]
    end
    http.callback do
      status        = http.response_header.status
      headers_after = http.response_header.inspect
      response      = http.response

      s = [status, url, headers_after, response]

      DALLI_CLIENT.set 'foo', s

      EM::Timer.new(1) do
        c += 1
        PUSHER.trigger 'greet', :greeting => "Hello from EventMachine (Pusher) #{c}"
      end

    end
  end
end
