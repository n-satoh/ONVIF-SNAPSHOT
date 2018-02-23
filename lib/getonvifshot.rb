# coding: utf-8

# ONVIFでURLを拾って、httpで画像拾って、中身返す。

require 'socket'
require 'open-uri'

def getonvifshot
  # ここにONVIFの接続情報を。
  cameraip = "192.168.2.1"
  onvifport = 8000
  profileToken = "CH01"

  url = ""
  urlMatch = /\<tt\:Uri\>(.*)\<\/tt\:Uri\>/
  
  reqUrl = <<"EOS"
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope"
 xmlns:trt="http://www.onvif.org/ver10/media/wsdl"
 xmlns:tt="http://www.onvif.org/ver10/schema">
  <soap:Body>
    <trt:GetSnapshotUri>
      <trt:ProfileToken>#{profileToken}</trt:ProfileToken>
    </trt:GetSnapshotUri>
  </soap:Body>
</soap:Envelope>
EOS

  url = nil
  l = ""
  begin
    TCPSocket.open(cameraip,onvifport) do |sock|
      sock.puts(reqUrl)
      sock.puts ""
      while select([sock],nil,nil,3)#3秒だけ待つ。
        unless url
          l = sock.gets
          urlMatch =~ l
          url = $1 if $1
         else
          sock.gets #欲しいものは手に入った。あとは捨てる。
        end
        break if sock.eof?
      end
    end
  rescue
    puts "ERROR Can't get Snapshot URL.(Probably, ONVIF is not working.)"
    return nil
  end
  
  begin #面倒なのでどろりと拾ってくるし、オンメモリで渡す。
    sio = OpenURI.open_uri(url,:read_timeout => 10,:proxy => nil )
    sio.binmode
    r = sio.read
  rescue
    puts "ERROR Can't get Snapshot.(Maybe, intercepted.)"
    return nil
  end
  r
end

