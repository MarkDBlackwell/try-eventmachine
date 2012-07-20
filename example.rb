require 'eventmachine'

module EchoServer
  def post_init
    puts "-- someone connected to the echo server!"
  end

  def receive_data data
    send_data ">>>you sent: #{data}"
    close_connection if data =~ /quit/i
  end

  def unbind
    puts "-- someone disconnected from the echo server!"
  end
end

EM.run do
  puts "Main #{Thread.current}"
# EM.start_server '127.0.0.1', 8081, EchoServer
  c = 0
  pt = EM::PeriodicTimer.new(1) { puts "Tick #{c+=1}" }
  EM::Timer.new(1) do
    puts "Main #{Thread.current}"
  end
  EM::Timer.new(3) { pt.cancel }
  EM::Timer.new(6) do
    EM.next_tick do
      EM.stop_event_loop
    end
  end
  EM.defer do
    puts "Defer #{Thread.current}"
  end
end
raise 'hello'
