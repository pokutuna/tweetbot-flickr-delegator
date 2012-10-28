# ref: http://hanklords.github.com/flickraw/
require 'flickraw'
require 'json'

keys = JSON.parse(open('./flickr_key.json').read)
FlickRaw.api_key = keys['key']
FlickRaw.shared_secret = keys['secret']

token = flickr.get_request_token
auth_url = flickr.get_authorize_url(token['oauth_token'], :perms => 'delete')

`open #{auth_url}`
puts "Open this url in your process to complete the authication process : #{auth_url}"
puts "Copy here the number given when you complete the process."
verify = gets.strip

begin
  flickr.get_access_token(token['oauth_token'], token['oauth_token_secret'], verify)
  login = flickr.test.login
  puts "You are now authenticated as #{login.username} with \n token: #{flickr.access_token}\n secret: #{flickr.access_secret}"
rescue FlickRaw::FailedResponse => e
  puts "Authentication failed : #{e.msg}"
end
