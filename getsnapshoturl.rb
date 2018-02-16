#!/usr/bin/ruby
# coding: utf-8
require 'socket'
require 'open-uri'

cameraip = "192.168.2.1" #適当に変えて。
onvifport = 8000 #適当に変えて。
profileToken = "CH01" #適当に変えて。

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
    while select([sock],nil,nil,3)
      unless url
        l = sock.gets
        urlMatch =~ l
        url = $1 if $1
      else
        sock.gets #読み捨て
      end
      break if sock.eof?
    end
  end
rescue
  puts "おや？"
  return nil
end

puts url
