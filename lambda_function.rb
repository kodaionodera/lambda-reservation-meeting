# ローカル用
require 'dotenv'
require 'net/http'
require 'json/add/core'
require 'jwt'
require './zoom.rb'
require './slack.rb'
require './spread_sheet.rb'

# envの読み込み(ローカル開発用)
Dotenv.load

def lambda_handler(event:, context:)
  response = Zoom.call
  res_body = JSON.parse(response.body)

  Slack.call(res_body)
end