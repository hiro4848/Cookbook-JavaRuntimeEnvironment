


module Windows
  module Helper


    # if a file is local it returns a windows friendly path version
    # if a file is remote it caches it locally
    def cached_file(source, checksum=nil, windows_path=true)

      @installer_file_path ||= begin

        if source =~ ::URI::ABS_URI && %w[ftp http https].include?(URI.parse(source).scheme)
          uri = ::URI.parse(source)
          cache_file_path = "#{Chef::Config[:file_cache_path]}/#{::File.basename(::URI.unescape(uri.path))}.exe"
          Chef::Log.debug("Caching a copy of file #{source} at #{cache_file_path}")
          r = Chef::Resource::RemoteFile.new(cache_file_path, run_context)
          r.source(source)
          r.backup(false)
          r.checksum(checksum) if checksum
          r.run_action(:create)
 
       else
          cache_file_path = source
        end

        windows_path ? win_friendly_path(cache_file_path) : cache_file_path
      end
    end

  end
end




class Chef
  class HTTP

    def stream_to_tempfile(url, response)
      tf = Tempfile.open("chef-rest")
      if Chef::Platform.windows?
        tf.binmode # required for binary files on Windows platforms
      end
      Chef::Log.debug("Streaming download from #{url.to_s} to tempfile #{tf.path}")
      # Stolen from http://www.ruby-forum.com/topic/166423
      # Kudos to _why!

      stream_handler = StreamHandler.new(middlewares, response)

      response.read_body do |chunk|
  puts "foooo\n"
        tf.write(stream_handler.handle_chunk(chunk))
      end
      tf.close
      tf
    rescue Exception
      tf.close!
      raise
    end


  end
end








def load_helpers

  cookbook_path = run_context.cookbook_collection[cookbook_name].root_dir
  helpers_dir = File.join(cookbook_path, 'helpers')

  Dir.entries(helpers_dir).each do |filename|
    next if (filename == '.' || filename == '..')

    helper_filepath = File.join(helpers_dir, filename)
    self.instance_eval(IO.read(helper_filepath))
  end

end