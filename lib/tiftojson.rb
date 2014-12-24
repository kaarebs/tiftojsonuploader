require "fog_uploader"
require "json"
class TifToJson

  def initialize path
    @path = path
    @tmp_path = "/tmp/#{Time.now.to_i}"
    @result = {}
    @uploder = FogUploder.new
  end

  def generate_json
    Dir.mkdir "#{@tmp_path}"
    find_tif_files.each do |item|
      @result[get_tag_from_file(item)] = generate_png_from_tif(item)
    end
    create_json_file
  end

  def create_json_file
    json_file = "/tmp/generated.json"
    File.open(json_file, "wb") { |file| file.write(@result.to_json) }
    puts 'access your file at : ' + json_file
  end

  def find_tif_files
    files = `find #{@path } -name \"*.tif\"`
    arr = files.split "\n"
    arr
  end

  def get_tag_from_file tifpath
    tag = `exiftool \"#{tifpath}\"|grep Person`
    tag = tag.split(": ")[1].sub("\n", "")
    tag = File.basename(tifpath) if tag == ""
    tag
  end

  def generate_png_from_tif tifpath
    pngpath = "#{@tmp_path}/#{File.basename(tifpath, '.tif')}.png"
    `convert \"#{tifpath}\" \"#{pngpath}\"`
    url = @uploader.upload pngpath
    url
  end
end
