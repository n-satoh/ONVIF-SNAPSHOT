# coding: utf-8

# 単純にHTTPでsnaphot取得

require 'open-uri'

def getshot
  #ここは各自変更のこと。
  url = "http://192.168.2.2/snap.jpg"

  begin
    sio = OpenURI.open_uri(url,:read_timeout => 10,:proxy => nil )
    sio.binmode
    r = sio.read #オンメモリで返す。なんていうか、ヒドイヤリカタ。
  rescue
    r = nil
  end
  r
end

