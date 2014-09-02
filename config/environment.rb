require 'rubygems'
require 'bundler'
Bundler.setup
require 'sinatra'
require 'active_record'
require 'sinatra/activerecord'
require 'haml'
require 'sass'
require 'twitter'

configure do
  set :server, 'webrick' # needed because sinatra thinks the twitter gem is a server.
  set :app_file, File.expand_path(File.join(File.dirname(__FILE__), "..", "app.rb"))
  set :haml, { :format => :html5 }
end

configure :development do
  set :database, 'sqlite:///db/dev.sqlite3'
  set :show_exceptions, true
  set :twitter, nil
end

configure :production do
  db = URI.parse(ENV['DATABASE_URL'] || 'postgres://localhost/mydb')

  ActiveRecord::Base.establish_connection(
    :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
    :host     => db.host,
    :username => db.user,
    :password => db.password,
    :database => db.path[1..-1],
    :encoding => 'utf8'
  )

  twitter_client = Twitter::REST::Client.new do |config|
    config.consumer_key = ENV["TWITTER_CONSUMER_KEY"]
    config.consumer_secret = ENV["TWITTER_CONSUMER_SECRET"]
    config.access_token = ENV["TWITTER_ACCESS_TOKEN"]
    config.access_token_secret = ENV["TWITTER_ACCESS_SECRET"]
  end
  #set :twitter, twitter_client
  set :twitter, nil # account got suspended for spam, stop tweeting for now until we have a solution.
end

helpers do
  def tweet(user, msg)
    settings.twitter.update(msg) if !settings.twitter.nil?
  end
end