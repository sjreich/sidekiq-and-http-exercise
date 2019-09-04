require 'json'
require 'pry'

require_relative 'http_connection'
require_relative 'sidekiq_workers'
require_relative '../exercise_verification'

##################################################
# Exercise 1: Simple HTTP communication with a server
# A. Use HttpConnection (defined in client/http_connection.rb) to send a GET 
# request to the root route of the server.  (This is done for you.)
# B. Parse the JSON response, and use `puts` to print the message portion to the
# screen.

module HTTParty
  module ClassMethods
    methods = [:get, :post]
    methods.each do |method|
      old = instance_method(method)

      # The real trick here would be to take the instance_variables of response
      # and turn those into the keys of the JSON object
      define_method(method) do |path, options = {}, &block|
        response = old.bind(self).call(path, options, &block)
        result = JSON.parse(response.body)
        result["code"] = response.code
        result
      end
    end
  end
end


response = HttpConnection.get('/')
puts response["message"]


##################################################
# Exercise 2: Extended interaction with a server
# The server has a big list of numbers.  But it's not very good at math :-(, and
# it was hoping you could maybe help it sum them up.  
# A. Send GET requests to /number until it tells you you've got them all.
# B. Send a POST to /sum with 'sum: <the sum>' as a parameter in the post body.
# C. Use `puts` to print the message portion of the response to the screen.

numbers = []

loop do
  response = HttpConnection.get('/number')
  numbers.push(response["number"].to_i)
  break if response["stop_asking"]
end

puts HttpConnection.post('/sum', 'body': { 'the_sum': numbers.inject(:+)})["message"]

##################################################
# Exercise 3: Introducing sidekiq
# A. Complete the definition of `GetRequestSender#perform` in client/sidekiq_workers.rb, 
# so that the message part of the response appears in the logs.  (Don't change anything here.)

GetRequestSender.new.perform('/i_am_making_requests', by_using: 'a_sidekiq_worker!')


##################################################
# Exercise 4: Using sidekiq for asynchronous work
# In the last exercise, sidekiq didn't really provide any new functionality.  
# Here, we'll make better use of it.
#
# The server has two pieces of information you want, but one is easy for the
# server to produce, and the other is more difficult.  Use the existing sidekiq 
# worker twice, first to send an *asynchronous* GET request to /the_hard_stuff,
# and second to send an *asynchronous* GET request to /the_easy_stuff.

# You should be able to verify that the 'easy' response-message appears before 
# the hard response, even though you sent the hard request first.  

# Important notes!
#  - After you edit the sidekiq file, you will have to restart sidekiq
#    - Use `ctrl-C` to kill off the old sidekiq job(s)
#    - To start them again, the command is `bundle exec sidekiq -r ./client/sidekiq_workers.rb`
#  - Output from Sidekiq workers won't appear in the terminal where you ran 'main.rb'.
#    Instead, it'll appear in the sidekiq terminal.
#  - Question to think about: why does all of this have to be this way?

GetRequestSender.perform_async('/the_hard_stuff')
sleep 0.1
GetRequestSender.perform_async('/the_easy_stuff')

verify_ex_4!


##################################################
# Exercise 5: Retrying through error-handling
# This server is a bit...touchy, and it doesn't always respond positively to 
# your requests.  Fortunately, it's not too hard to set up sidekiq to just
# try your requests again in a bit and hope that the server is in a better mood.
# A. Change the sidekiq worker so that it will retry requests unless the response
#    code is 200.
# B. Use the updated worker, asynchronously, to send a GET request to /touchy
#
# (Remember to restart sidekiq after editing the file.)

GetRequestSender.perform_async('/touchy')
verify_ex_5! # This can take up to 30 seconds



