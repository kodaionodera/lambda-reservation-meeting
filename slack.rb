# Slack通知をするクラス
class Slack
  def initialize(join_url, deily_person)
    @join_url = join_url
    @deily_person = deily_person
  end

  def notify
    uri = URI.parse(ENV['WEB_HOOKS_URI'])
    Net::HTTP.post_form(uri, { payload: payload })
  end

  private

  def payload
    {
      username: "デイリーお知らせbot",
      icon_emoji: ":spiral_calendar_pad",
      channel: "#test",
      text: text
    }.to_json
  end

  def text
    <<-EOS
      <!here> 会議が始まります。
      担当者：#{@deily_person}

      Zoom会議には以下URLで入れます。
      #{@join_url}
    EOS
  end
end
