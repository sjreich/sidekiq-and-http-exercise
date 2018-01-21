# Just pretend you can't read this :-)

require 'sinatra'
require 'redis'

get '/' do
  reset_redis!
  {
    message: 'Exercise 1 complete!'
  }.to_json
end

get '/number' do
  num_of_requests = redis.incr('ex_2:count_of_nums_requested').to_i
  total_num_of_nums = redis.get('ex_2:total_num_of_nums').to_i
  new_number = rand(1..100)
  redis.lpush('ex_2:numbers', new_number)

  if num_of_requests <= 3
    message = 'Here\'s a number.'
  elsif num_of_requests >= total_num_of_nums
    message = 'You\'re all set.  Don\'t ask for any more numbers.'
  else
    message = 'Maybe try a loop?  There are going to be a lot of these...'
  end

  {
    message: message,
    number: new_number,
    stop_asking: num_of_requests >= total_num_of_nums,
  }.to_json
end

post '/sum' do
  num_of_requests = redis.get('ex_2:count_of_nums_requested').to_i
  total_num_of_nums = redis.get('ex_2:total_num_of_nums').to_i

  message = 'You need to keep asking for more numbers' if num_of_requests < total_num_of_nums
  message ||= 'You asked for too many numbers' if num_of_requests > total_num_of_nums

  expected_sum = redis.lrange('ex_2:numbers', 0, -1).map(&:to_i).inject(&:+)
  message ||= 'You didn\'t send over a sum...' if params[:the_sum].nil?
  message ||= 'Are you sure you added those up right?' unless expected_sum == params[:the_sum].to_i
  message ||= 'Exercise 2 complete!'

  {
    message: message
  }.to_json
end

get '/i_am_making_requests' do
  message = 'The params didn\'t make it over' unless params[:by_using] == 'a_sidekiq_worker!'
  message ||= 'Exercise 3 complete!'
  {
    message: message
  }.to_json
end

get '/the_easy_stuff' do
  redis.set('ex_4:the_easy_stuff:started', Time.now.to_f)
  redis.set('ex_4:the_easy_stuff:finished', Time.now.to_f)

  {
    message: 'No sweat!'
  }.to_json
end

get '/the_hard_stuff' do
  redis.set('ex_4:the_hard_stuff:started', Time.now.to_f)
  sleep 1
  redis.set('ex_4:the_hard_stuff:finished', Time.now.to_f)

  {
    message: 'Whew! That was tough!'
  }.to_json
end

get '/touchy' do
  redis.set('ex_5:status', 'started')
  num_requests_submitted = redis.incr('ex_5:requests_submitted')
  if num_requests_submitted < 3
    status(500)
    {
      message: 'I\'m not really in the mood right now.'
    }.to_json
  else
    redis.set('ex_5:status', 'complete')
    {
      message: 'Glad to help you out however I can!'
    }.to_json
  end
end

def redis
  @redis ||= Redis.current
end

def reset_redis!
  redis.flushdb
  redis.set('ex_2:total_num_of_nums', rand(30..50))
  redis.set('ex_2:count_of_nums_requested', 0)
  redis.set('ex_5:requests_submitted', 0)
end



##############################################
