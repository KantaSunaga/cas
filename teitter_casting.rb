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
    print("第１段階")
    faraday.headers['Authorization'] ="Bearer #{ENV['MY_TOKEN']}"
    nums = [0,1,2,3,4,5,6,7,8,9]
    hint = nil
    nums.combination(3).to_a.each do |ary|
      nums = ary.join(",").delete(",")
      res = faraday.post "https://apiv2.twitcasting.tv/internships/2018/games/#{start_id}", {"answer": nums}.to_json
      result = JSON.parse res.body
      puts(result)
      if result["blow"] == 2
        hint = ary
        break
      end
    end
    print("第２段階")
    sqees_nums = [0,1,2,3,4,5,6,7,8,9] - hint
    print(sqees_nums)
    pre_answer = nil

    answer = "#{hint[0]}#{hint[1]}#{sqees_nums[1]}"
    res = faraday.post "https://apiv2.twitcasting.tv/internships/2018/games/#{start_id}", {"answer": answer}.to_json
    result = JSON.parse res.body
    puts(result)
    if result["blow"] == 1

      sqees_nums.each do |num|
        answer = "#{hint[1]}#{hint[2]}#{num}"
        res = faraday.post "https://apiv2.twitcasting.tv/internships/2018/games/#{start_id}", {"answer": answer}.to_json
        result = JSON.parse res.body
        puts(result)
        if result["blow"] == 3
          pre_answer = answer.split("")
          break
        end
      end
    else

      sqees_nums.each do |num|
        answer = "#{hint[0]}#{hint[1]}#{num}"
        res = faraday.post "https://apiv2.twitcasting.tv/internships/2018/games/#{start_id}", {"answer": answer}.to_json
        result = JSON.parse res.body
        puts(result)
        if result["blow"] == 3
          pre_answer = answer.split("")
          binding.pry
          break
        end
      end
    end
    binding.pry
    puts("最終ステージ")
    p_a = pre_answer.map{|num| num.to_i}
    p_a.combination(3).to_a.each do |num|
      print(num.join(""))
      res = faraday.post "https://apiv2.twitcasting.tv/internships/2018/games/#{start_id}", {"answer": num.join("")}.to_json
      result = JSON.parse res.body
      print(result)
    end
    #成功したらメールとか飛ばしたい
  end
end

#きったねー糞コードわら
# class Calculat
#   def
# end



api = Api.new
start_id = api.get_start_id
api.post_my_answer(start_id)
