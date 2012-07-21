#!/usr/bin/env ruby
# encoding: utf-8

require 'amqp'
require 'dalli'
require 'em-pusher'

AMQP_URL = ENV['CLOUDAMQP_URL']
EXCHANGE_NAME = 'com.herokuapp.delayed-webrequest'
QUEUE_NAME    = 'com.herokuapp.delayed-webrequest'

DALLI_CLIENT=Dalli::Client.new \
                 ENV['MEMCACHIER_SERVERS' ], {
    :username => ENV['MEMCACHIER_USERNAME'],
    :password => ENV['MEMCACHIER_PASSWORD']  }

PUSHER = EM::Pusher.new \
    :app_id      => ENV['PUSHER_APP_ID'],
    :auth_key    => ENV['PUSHER_KEY'   ],
    :auth_secret => ENV['PUSHER_SECRET'],
    :channel     =>     'test_channel'

c = 0

EM.run do
  connection = AMQP.connect AMQP_URL
  channel = AMQP::Channel.new connection
  exchange = channel.direct EXCHANGE_NAME
  queue = channel.queue QUEUE_NAME
  queue.bind exchange
  queue.subscribe do |payload|
    c += 1
    DALLI_CLIENT.set 'foo', 'Hello from EventMachine (Memcachier)'
    EM::Timer.new(1) do
      PUSHER.trigger 'greet', :greeting => "Hello from EventMachine (Pusher) #{c}"
    end
  end
end
