# coding: utf-8

# 指定のディレクトリに放り込んであるファイルのどれかを
# てきとーに読み出して中身を返す

def getrandomphoto
  #画像ファイルのディレクトリを指定
  photos = "photos"

  fl = Dir.glob(photos + "/*") #リストをとって
  fn = fl[rand(fl.size)] #ランダムに一つ選んで
  r = nil
  File.open(fn) do |file|
    r = file.read #中身をどーんと返す、オンメモリで。
  end
  r
end
