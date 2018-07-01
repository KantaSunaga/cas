require "rubygems"
require 'pry-rails'
require 'pry-byebug'
require "faraday"
require 'json'
require 'logger'


class Api
  def get_start_id
    client = Faraday.new( "https://apiv2.twitcasting.tv/internships/2018/games?level=3")
    res = nil ;body = nil
    loop{
      res = client.get do |req|
        req.headers['Authorization'] ="Bearer #{ENV['MY_TOKEN']}"
      end
      body = JSON.parse res.body
      break if body.include?("id")
    }
    body["id"]
  end

  def post_my_answer(start_id)
    faraday = Faraday.new
    faraday.headers['Authorization'] ="Bearer #{ENV['MY_TOKEN']}"
    array = [0,1,2,3,4,5,6,7,8,9]
    array.combination(3).to_a.each do |ary|
      nums = ary.join(",").delete(",")
      res = faraday.post "https://apiv2.twitcasting.tv/internships/2018/games/#{start_id}", {"answer": nums}.to_json
      puts JSON.parse res.body
    end
    #成功したらメールとか飛ばしたい
  end
end


api = Api.new
start_id = api.get_start_id
api.post_my_answer(start_id)
