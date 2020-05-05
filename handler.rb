# ローカル用
# require 'dotenv'
require 'net/http'
require "json/add/core"

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

  # 有効期限が決まっているのでAPI KEYを使うように変更する
  headers = {
    "Content-Type" => "application/json",
    "Authorization" => "Bearer #{ENV['JWT']}"
   }

  req = Net::HTTP::Post.new(uri.path)
  req.body = payload

  req.initialize_http_header(headers)

  http.request(req)
end

def notify_slack(body)
  uri = URI.parse(ENV['WEB_HOOKS_URI'])

  payload = {
    channel: "#test",
    text: slack_text(body)
  }.to_json

  Net::HTTP.post_form(uri, { payload: payload })
end

def slack_text(body)
  <<-EOS
    <!here> デイリーが始まります
    #{body['join_url']}
  EOS
end