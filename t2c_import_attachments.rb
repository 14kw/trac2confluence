require "find"
require "filemagic"
require "uri"

if not ARGV[0] then
  puts("エラー：第一引数にtrac名を指定して下さい")
  exit(1)
end
PRJNAME = ARGV[0].to_s

if not ARGV[1] then
  puts("エラー：第一引数にスペース名を指定して下さい")
  exit(1)
end
CONFNAME = ARGV[1].to_s

ATTDIR = "./#{PRJNAME}/attachments/wiki/**"
dirs = Dir.glob("#{ATTDIR}")

dirs.each {|d|
  puts "==== #{d} ===="
  dirname = d.split("/").last
  Find.find("#{d}") {|f|
    next unless FileTest.file?(f)
    puts f
    contenttype = FileMagic.new(FileMagic::MAGIC_MIME_TYPE).file(File.join("#{f}"))

    if File.extname(f) == ".xlsx"
      contenttype = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    elsif File.extname(f) == ".pptx"
      contenttype = "application/vnd.openxmlformats-officedocument.presentationml.presentation"
    elsif File.extname(f) == ".pdf"
      contenttype = "application/pdf"
    end
    command = "python ./wikiFileAttachments.py #{CONFNAME} \"#{dirname}\" #{contenttype} \"#{f}\""
    puts command
    system(command)
  }
}