# Slack通知をするクラス
class Slack
  class << self
    def call(body)
      uri = URI.parse(ENV['WEB_HOOKS_URI'])

      Net::HTTP.post_form(uri, { payload: payload(body) })
    end

    private

    def payload(body)
      payload = {
        username: "デイリーお知らせbot",
        icon_emoji: ":spiral_calendar_pad",
        channel: "#test",
        text: text(body)
      }.to_json
    end

    def text(body)
      person = SpreadSheet.call(ENV['SPREAD_SHEET_URL'])

      <<-EOS
        <!here> デイリーが始まります

        デイリー担当者: #{person}
        #{body['join_url']}
      EOS
    end
  end
end
