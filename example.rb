require 'eventmachine'

# http://rubylearning.com/blog/2010/10/01/an-introduction-to-eventmachine-and-how-to-avoid-callback-spaghetti/

EM.run do
  require 'em-http'

  s = 'http://json-time.appspot.com/time.json'
  EM::HttpRequest.new(s).get.callback do |http|
    puts http.response
  end
end
