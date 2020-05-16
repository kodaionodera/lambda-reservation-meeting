# GASを叩きデイリー当番を取得するクラス
class SpreadSheet
  class << self
    def call(path)
      uri = URI.parse(path)
      http = Net::HTTP.new(uri.hostname, uri.port)
      req = Net::HTTP::Get.new(uri.request_uri)
      http.use_ssl = true
      res = http.request(req)

      case res
      when Net::HTTPOK
        return res.body.force_encoding("UTF-8")
      when Net::HTTPFound
        SpreadSheet.call(res["location"])
      end
    end
  end
end
