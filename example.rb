require 'eventmachine'

=begin
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
=end

EM.run do
  puts 'Start'
  puts "Main #{Thread.current}"
# EM.start_server '127.0.0.1', 8081, EchoServer

  c = 0
  unit, name = 1.to_f/3, 'Third'
  pt = EM::PeriodicTimer.new(unit) { puts "#{name} #{c+=1}" }

=begin
  EM::Timer.new(1) do
    puts "Main #{Thread.current}"
  end
  EM::Timer.new(2) { pt.cancel }
=end

  EM::Timer.new(3) do
    EM.stop_event_loop
  end

  cb = proc {|a| puts "Callback receives: #{a}"}
  puts "Callback is #{cb.inspect}"

  dj = 'dj'
  dj2 = 'dj2'
  job = proc do
    puts "Defer #{Thread.current}\n"
    EM.next_tick do
      puts "dj  is #{dj .inspect}"
      puts "dj2 is #{dj2.inspect}"
    end
    n = 2
    sleep n
    puts "After sleep #{n}"
    puts "Job returns: #{result=5}"
    result
  end
  puts "Job is #{job.inspect}"

  dj = EM.defer job, cb
end
# raise 'hello'
