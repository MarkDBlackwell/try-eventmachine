# Use another port by:
# foreman start -p 5001

Kernel.fork { `bundle exec ruby amqp_consumer.rb` }


require './web'
run DelayedWebRequest
