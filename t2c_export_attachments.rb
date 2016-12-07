require 'rubygems'
require 'mysql'
require 'fileutils'
require 'date'
require 'uri'
require 'cgi'

if not ARGV[0] then
  puts("エラー：第一引数にtracプロジェクト名を指定して下さい")
  exit(1)
end
PRJNAME = ARGV[0].to_s
DOMAIN = "http://localhost/trac/#{PRJNAME}"

PRJ_PATH  = "./#{PRJNAME}"
ATTCH_PATH = "#{PRJ_PATH}/attachments/wiki"

FileUtils.mkdir_p(WIKI_PATH) unless FileTest.exist?(WIKI_PATH)

client = Mysql::new("localhost", "username", "password", "tracdb")

## 添付ファイル
# ファイル名がencodeされていてdecodeするのめんどいのでhttp経由で取ってしまう（雑）
# ページ名に相当するフォルダを作って、そこに添付ファイルを格納する
sql = %q{SELECT type, id, filename FROM attachment WHERE type = 'wiki'}
client.query(sql).each do |type, id, filename|
  ## FilenameHierarchy
  #dirpath = id.split("/").last
  ## FilepathHierarchy
  dirpath = id.gsub(/\//){"_"}
  attpath = "#{PRJ_PATH}/attachments/#{type}/#{dirpath}"
  FileUtils.mkdir_p(attpath) unless FileTest.exist?(attpath)
  encid = URI.encode("#{id}")
  encfilename = CGI.escape("#{filename}")
  encfilename = encfilename.gsub("+", "%20")
  atturl = "#{DOMAIN}/raw-attachment/#{type}/#{encid}/#{encfilename}"
  command = "wget --no-check-certificate --http-user='username' --http-password='password' '#{atturl}' -O '#{attpath}/#{encfilename}' -a #{PRJ_PATH}/output.txt"
  system(command)
  print "#{$?}"
end

client.close