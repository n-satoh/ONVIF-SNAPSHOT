#!/usr/bin/ruby
# coding: utf-8

# ONVIFでプライベートIPなサブネットの監視カメラのスナップショット機能で
# 画像を取得するプロキシサーバ。
# おウチルータをLinuxとかで作る系の人用。
# あと、ダミー用にてきとーなフォルダにテキトーな画像入れとくと
# てきとーなURLで画像拾おうとしたときにランダムに返す。

require 'resolv-replace'
require 'webrick'
include WEBrick::HTTPUtils

require_relative 'lib/getonvifshot'
require_relative 'lib/getshot'
require_relative 'lib/getrandomphoto'

#公開するポートを指定しよう
outport = 8080

#このURLは単純HTTPで拾うところにプロキシされる
shotMatch = /notonvif_IWASHISUZUKEDESYOKUATARI.jpg/
#このURLはONVIF経由で拾うところにプロキシされる
onvifMatch = /onvif_MEZASHITOMARUBOSHITOKAPERINTO.jpg/
#このURLはダミー用画像ファイルを返すところ。
randomMatch = /.+.jpg/

#ハラタツアクセスをちょいちょいする
warumonoMatch = []
warumonoMatch << /.*(\.com).*/
warumonoMatch << /(\/script).*/
warumonoMatch << /.*(\/manager\/html).*/
warumonoMatch << /.*(\/HNAP1\/).*/
warumonoMatch << /.*(\?rands=).*/

srv = WEBrick::HTTPServer.new({:Port => outport})

srv.mount_proc '/' do |req, res|
  if shotMatch =~ req.path
    res.content_type = mime_type('.jpg', DefaultMimeTypes)
    res.body = getshot
  elsif onvifMatch =~ req.path
    res.content_type = mime_type('.jpg', DefaultMimeTypes)
    res.body = getonvifshot
  elsif randomMatch =~ req.path
    res.content_type = mime_type('.jpg', DefaultMimeTypes)
    res.body = getrandomphoto
  else
    warumono = false
    warumonoMatch.each do |match|
      if match =~ req.path
        warumono  = true
        break
      end
    end
    if  warumono
      redirecturl = 'http://' + req.peeraddr[2] + '/'
      res.set_redirect(WEBrick::HTTPStatus::MovedPermanently,redirecturl)
      res.body = 'Do you like BUBUDUKE?\n\n' #ぶぶ漬けについての意見を問う
    else
      res.set_redirect(WEBrick::HTTPStatus::MovedPermanently, 'http://google.co.jp')
      res.body = ""
    end
  end
  
  
end

Signal.trap(:INT){ srv.shutdown }
srv.start
