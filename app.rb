require 'sinatra'
require 'httparty'
require 'flickraw'

SCREEN_NAME = 'pokutuna'
FLICKR = {
  :api_key       => 'hogehogehogehogehogehogehogehogehoge',
  :shared_secret => 'fugafugafugafugafuga',
  :access_token  => 'piyopiyopiyopiyopiyopiyopiyopiyopiyo',
  :access_secret => 'foobarfoobarfoobarfoo'
}

helpers do
  def me?(provider, credential)
    auth = HTTParty.get(provider, :headers => {'Authorization' => credential})
    SCREEN_NAME == auth.parsed_response['screen_name']
  end

  def flickr
    FLICKR[:instance] ||= lambda{
      FlickRaw.api_key = FLICKR[:api_key]
      FlickRaw.shared_secret = FLICKR[:shared_secret]
      flickr = FlickRaw::Flickr.new
      flickr.access_token  = FLICKR[:access_token]
      flickr.access_secret = FLICKR[:access_secret]
      return flickr
    }.call
  end
end

post '/flickr.json' do
  provider = request.env['HTTP_X_AUTH_SERVICE_PROVIDER']
  credential = request.env['HTTP_X_VERIFY_CREDENTIALS_AUTHORIZATION']
  return 401 unless me?(provider, credential)

  photo_id = flickr.upload_photo(
    params['media'][:tempfile],
    :title => params['message'],
    :description => "Posted from #{params["source"]}"
    )

  url = FlickRaw.url_short(flickr.photos.getInfo(:photo_id => photo_id))

  return { :url => url }.to_json
end
