# Don't mess with this stuff please :-)

def verify_ex_4!
  start_time = Time.now.to_f

  sleep 1
  easy_stuff_started = Redis.current.get('ex_4:the_easy_stuff:started')
  hard_stuff_started = Redis.current.get('ex_4:the_hard_stuff:started')
  return unless easy_stuff_started || hard_stuff_started

  until Redis.current.get('ex_4:the_hard_stuff:finished')
    sleep 0.2
    break if Time.now.to_f - start_time > 8.0
  end

  easy_stuff_started = Redis.current.get('ex_4:the_easy_stuff:started')
  easy_stuff_finished = Redis.current.get('ex_4:the_easy_stuff:finished')
  hard_stuff_started = Redis.current.get('ex_4:the_hard_stuff:started')
  hard_stuff_finished = Redis.current.get('ex_4:the_hard_stuff:finished')

  if easy_stuff_started < hard_stuff_started
    puts 'Make sure you start the hard request first.'
  elsif hard_stuff_finished < easy_stuff_finished
    puts 'Make sure you\'re doing this work asynchronously.'
  else
    puts 'Exercise 4 complete!'
  end
end

def verify_ex_5!
  sleep 1
  return unless Redis.current.get('ex_5:status') == 'started'

  start_time = Time.now.to_f
  until Redis.current.get('ex_5:status') == 'complete'
    sleep 0.2
    break if Time.now.to_f - start_time > 30.0
  end

  if Redis.current.get('ex_5:requests_submitted').to_i != 3
    puts 'Looks like you aren\'t retrying properly.  Or perhaps that sidekiq is being *very* slow.'
  elsif Redis.current.get('ex_5:status') == 'complete'
    puts 'Exercise 5 complete!'
  else
    puts 'Ex 5 did not go well.'
  end
end
