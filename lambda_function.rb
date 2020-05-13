# ローカル用
# require 'dotenv'
require 'net/http'
require 'json/add/core'
require 'jwt'

# envの読み込み(ローカル開発用)
# Dotenv.load

def lambda_handler(event:, context:)
  response = post_zoom_api
  res_body = JSON.parse(response.body)

  notify_slack(res_body)
end

def post_zoom_api
  path = "https://api.zoom.us/v2/users/#{ENV['USER_ID']}/meetings"
  uri = URI.parse(path)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  payload = {
    topic: "デイリー",
    type: "1",
    duration: "40",
    timezone: "Asia/Tokyo",
    password: "",
    agenda: "進捗報告"
  }.to_json

  headers = {
    "Content-Type" => "application/json",
    "Authorization" => "Bearer #{generate_jwt}"
   }

  req = Net::HTTP::Post.new(uri.path)
  req.body = payload
  req.initialize_http_header(headers)
  http.request(req)
end

def generate_jwt
  payload = {
      iss: ENV['API_KEY'],
      exp: Time.now.to_i + 36000
  }

  JWT.encode(payload, ENV['API_SECRET'], 'HS256')
end

def notify_slack(body)
  uri = URI.parse(ENV['WEB_HOOKS_URI'])

  payload = {
    username: "デイリーお知らせbot",
    icon_emoji: ":spiral_calendar_pad",
    channel: ENV['CHANNEL'],
    text: slack_text(body)
  }.to_json

  Net::HTTP.post_form(uri, { payload: payload })
end

def slack_text(body)
  person = call_spread_sheet(ENV['SPREAD_SHEET_URL'])

  <<-EOS
    <!here> デイリーが始まります

    デイリー担当者: #{person}
    #{body['join_url']}
  EOS
end

def call_spread_sheet(uri)
  uri = URI.parse(uri)
  http = Net::HTTP.new(uri.hostname, uri.port)
  req = Net::HTTP::Get.new(uri.request_uri)
  http.use_ssl = true
  res = http.request(req)

  case res
  when Net::HTTPOK
    return res.body.force_encoding("UTF-8")
  when Net::HTTPFound
    call_spread_sheet(res["location"])
  else
　　break
  end
end