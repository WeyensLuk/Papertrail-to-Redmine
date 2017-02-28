require 'sinatra/base'
require 'yajl/yajl'
require 'active_support/core_ext/hash/indifferent_access'
require './RedmineIntegrator'

class PapertrailWebHook < Sinatra::Application
  post '/' do
    parser = Yajl::Parser.new
    data = ActiveSupport::HashWithIndifferentAccess.new(parser.parse(params[:payload]))

    data[:events].each do |event|
      CreateRedmineIssue event
    end

    'ok'
  end

  get '/' do
    'Sup!'
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
