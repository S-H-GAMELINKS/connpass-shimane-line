load_paths = Dir["/vendor/bundle/ruby/2.5.0/gems/2.5.0/**/lib"]
$LOAD_PATH.unshift(*load_paths)

require 'line/bot'
require 'dotenv'
require 'net/http'
require 'uri'
require 'json'
require 'date'

Dotenv.load

day = Date.today

url = "https://connpass.com/api/v1/event/?keyword=#{URI.encode "島根"}"

for i in 0..6 do 
    url += "&ymd=#{day.next_day(i).to_s.gsub!(/-/, '')}"
end

puts url

uri = URI.parse(url)
response = Net::HTTP.get_response(uri)

client = Line::Bot::Client.new { |config|
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
}

events = JSON.parse(response.body)["events"]

info_message = {
    type: 'text',
    text: '直近一週間の島根県でのIT勉強会です'
}

response = client.push_message(ENV["LINE_USER_ID"], info_message)

events.each do |event|
    message = {
        type: 'text',
        text: "#{event["title"]} #{event["event_url"]}"
    }

    response = client.push_message(ENV["LINE_USER_ID"], message)
    p response
end