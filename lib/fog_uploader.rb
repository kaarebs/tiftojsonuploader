require 'fog'
class FogUploader
  attr_reader :service, :directory
  def initialize directory_name='realtor_photos'
    @service = Fog::Storage.new(rackspace)
    @directory = service.directories.select {|d| d.key == directory_name }.first
  end

  def rackspace
    {
      :provider => ENV['PROVIDER'],
      :rackspace_username => ENV['SECRET_USERNAME'],
      :rackspace_api_key => ENV['APIKEY'],
      :rackspace_region => :ord
    }
  end

  def upload path, filename=nil
    filename = File.basename(path) if filename.nil?
    file = nil
    3.times do
      begin
        file = create_file filename, File.read(path)
        saved = file.save
      rescue Exception => e
        puts 'it was not possible to upload file ' + filename
        puts e.message
      end
      break if saved
    end
    unless file.nil?
      return file.public_url
    end
    return nil
  end

  def create_file name, content, is_public=true
    directory.files.create ({:key => name, :body => content, :public => is_public})
  end
end
