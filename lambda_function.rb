# ローカル用
# require 'dotenv'
require 'net/http'
require 'json/add/core'
require 'jwt'
require './zoom.rb'
require './slack.rb'
require './spread_sheet.rb'

# envの読み込み(ローカル開発用)
# Dotenv.load

def lambda_handler(event:, context:)
  join_url = Zoom.reservation_meeting

  daily_person = SpreadSheet.fetch_daily_person

  slack = Slack.new(join_url, daily_person)
  slack.notify
end
