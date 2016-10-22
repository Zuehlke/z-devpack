require "rake/file_utils"
require "yaml"

module DevPack
  module EnvironmentOptions
    BASE_DIR = File.expand_path(File.dirname(__FILE__),"..")
    VERSION = '1.0'
    def version
      ver=ENV["VERSION"]
      ver||=VERSION
      return ver
    end
    def base_dir
      return BASE_DIR
    end
    def build_dir
      ddir=ENV["BUILD_DIR"]
      ddir||=File.join(base_dir,"build")
      File.expand_path(ddir)
    end
    def tools_dir
      ddir=ENV["TARGET_DIR"]
      ddir||=File.join(build_dir,"tools")
      File.expand_path(ddir)
    end
    def cache_dir
      ddir=ENV["CACHE_DIR"]
      ddir||=File.join(base_dir,"cache")
      File.expand_path(ddir)
    end
    def config_dir
      ddir=ENV["CONFIG_DIR"]
      ddir||=File.join(base_dir,"config")
      File.expand_path(ddir)
    end
    def zip_exe
      zip=ENV["ZIP_EXE"]
      zip||='C:\Program Files\7-Zip\7z.exe'
      return File.expand_path(zip)
    end
    def verbose
      val=ENV["VERBOSE"]
      val||=false
      return val
    end
  end
  include EnvironmentOptions
  
  def devpack_config
    unless @_tool_config
      cfg_file=File.join(config_dir,"tools.yaml")
      raise "Cannot find the tool configuration in #{cfg_file}" unless File.exist?(cfg_file)
      @_tool_config||=YAML.load(File.read("#{base_dir}/config/tools.yaml"))
    end
    return @_tool_config
  end

  def has_tool? tool_name
    devpack_config.keys.include?(tool_name)
  end

  def tool_config tool_name
    devpack_config.fethc(tool_name,{})
  end

  def create_devpack_structure
    %w{ home repo tools }.each do |dir|
      mkdir_p("#{build_dir}/#{dir}",:verbose=>verbose)
    end
    mkdir_p(cache_dir,:verbose=>verbose)
  end
  
  def download_tools tools_config
    tools_config.each do |tname,cfg|
      download_and_unpack(cfg["url"], File.join(tools_dir,tname), [])
    end
  end
  
  def copy_files
    Rake::FileList["#{base_dir}/files/*"].each do |el|
      FileUtils.cp_r el,build_dir,:verbose=>false,:remove_destination=>true
    end
  end

  def generate_docs
    Dir.glob("#{base_dir}/*.md").each do |md_file|
      html = MarkIt.to_html(IO.read(md_file))
      outfile = "#{build_dir}/_#{File.basename(md_file, '.md')}.html"
      File.open(outfile, 'w') {|f| f.write(html) }
    end
  end
  
  def assemble devpack_name
    pack(build_dir, "#{devpack_name}-#{version}.7z")
  end

  def clean_cache
    rm_rf cache_dir, secure: true,:verbose=>verbose
  end
  
  def clean_build
    rm_rf build_dir, secure: true,:verbose=>verbose
  end

  def download_and_unpack(url, target_dir, includes = [])
    Dir.mktmpdir do |tmp_dir|
      outfile = "#{tmp_dir}/#{File.basename(url)}"
      download(url, outfile)
      if File.extname(target_dir).empty?
        unpack(outfile, target_dir, includes)
      else
        FileUtils.mkdir_p File.dirname(target_dir)
        FileUtils.cp outfile, target_dir
      end
    end
  end

  def download(url, outfile)
    puts "checking cache for '#{url}'" if verbose
    url_hash = Digest::MD5.hexdigest(url)
    cached_file = "#{cache_dir}/#{url_hash}"
    if File.exist? cached_file
      puts "cache-hit: read from '#{url_hash}'" if verbose
      FileUtils.cp cached_file, outfile
    else
      download_no_cache(url, outfile)
      puts "caching as '#{url_hash}'" if verbose
      FileUtils.cp outfile, cached_file
    end
  end

  def download_no_cache(url, outfile, limit=5)

    raise ArgumentError, 'HTTP redirect too deep' if limit == 0

    puts "download '#{url}'"
    uri = URI.parse url
    if ENV['HTTP_PROXY']
      proxy_host, proxy_port = ENV['HTTP_PROXY'].sub(/https?:\/\//, '').split ':'
      puts "using proxy #{proxy_host}:#{proxy_port}"
      http = Net::HTTP::Proxy(proxy_host, proxy_port.to_i).new uri.host, uri.port
    else
      http = Net::HTTP.new uri.host, uri.port
    end

    if uri.port == 443
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http.use_ssl = true
    end

    http.start do |agent|
      agent.request_get(uri.path + (uri.query ? "?#{uri.query}" : '')) do |response|
        # handle 301/302 redirects
        redirect_url = response['location']
        if(redirect_url)
          unless redirect_url.start_with? "http"
            redirect_url = "#{uri.scheme}://#{uri.host}:#{uri.port}#{redirect_url}"
          end
          puts "redirecting to #{redirect_url}"
          download_no_cache(redirect_url, outfile, limit - 1)
        else
          File.open(outfile, 'wb') do |f|
            response.read_body do |segment|
              f.write(segment)
            end
          end
        end
      end
    end
  end

  def unpack(archive, target_dir, includes = [])
    puts "extracting '#{archive}' to '#{target_dir}'"
    case File.extname(archive)
    when '.zip', '.7z', '.exe'
      system("\"#{zip_exe}\" x -o\"#{target_dir}\" -y \"#{archive}\" -r #{includes.join(' ')} 1> NUL")
    when '.msi'
      system("start /wait msiexec /a \"#{archive.gsub('/', '\\')}\" /qb TARGETDIR=\"#{target_dir.gsub('/', '\\')}\"")
    else
      raise "don't know how to unpack '#{archive}'"
    end
  end

  def pack(target_dir, archive)
    puts "packing '#{target_dir}' into '#{archive}'"
    Dir.chdir(target_dir) do
      system("\"#{zip_exe}\" a -t7z -y \"#{archive}\" \".\" 1> NUL")
    end
  end
end