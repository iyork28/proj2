class Client
  
  def initialize(args)
    @torrent = decode(args[:torrent_file])
    @peer_id = Digest::SHA1.digest('2d554d313834302d137503b00b2564d256e6a9f4')
    @info_hash = Digest::SHA1.digest @torrent["info"].bencode
    @peers = []
  end
  
  def decode(torrent_file)
    File.bdecode(torrent_file)
  end
  
  def run!
    uri = URI(@torrent["announce"])
    uri.query = URI.encode_www_form make_params_hash
    res = Net::HTTP.get_response(uri)
    
    # puts res.body.bdecode
    
    body = res.body.bdecode

    peers = body["peers"].scan(/.{6}/).map {|p| p.unpack('a4n')}
    
    peers.each do |ip, port|
      peer = Peer.new({
        ip:         ip,
        port:       port,
        peer_id:    @peer_id,
        info_hash:  @info_hash
      })
      @peers << peer
      
    end
    
    @block_queue = BlockQueue.new(size: @total_size)
    @data_hash = {}
    @mutex = Mutex.new
    
    # @peers[1].start_handshake # until I do multithreading
    # @peers[1].start!({block_queue: @block_queue, data_hash: @data_hash, mutex: @mutex})
    # Thread.abort_on_exception = true
    threads = []
    @peers.each do |peer|
      threads << Thread.new {
        if peer.start_handshake
          peer.start!({block_queue: @block_queue, data_hash: @data_hash, mutex: @mutex})
        end
      }
    end
    
    threads.each { |thread| thread.join }
    
    write_files
  end
  
  def write_files
    name = @torrent["info"]["name"]
    block_len = 2**14
    if @torrent["info"]["files"].nil? # single?
      len = file["length"]
      blocks = len / (block_len)
      rem = len - (blocks*(block_len))
      
      data = ""
      (0..blocks).each { |block| new_file << @data_hash[(block * block_len).to_s(2)] }
      
      if rem == 0
        # done
      else
        offset = true
        offset_string = @data_hash[((blocks+1) * block_len).to_s].to_s(2)
        puts offset_string.class
        new_file << (offset_string[0,rem-1])
        last_block = (blocks+1) * block_len
        last_bit = rem
      end
    else
      f = []
      files = @torrent["info"]["files"]
      offset = false
      last_block = nil
      last_bit = nil
      
      files.each do |file|
        new_file = File.new(file["path"].first, "w+")
        if offset == true
          
        else
          len = file["length"]
          blocks = len / (block_len)
          rem = len - (blocks*(block_len))
          
          data = ""
          (0..blocks).each { |block| new_file << @data_hash[(block * block_len).to_s(2)] }
          
          if rem == 0
            # done
          else
            offset = true
            offset_string = @data_hash[((blocks+1) * block_len).to_s].to_s(2)
            puts offset_string.class
            new_file << (offset_string[0,rem-1])
            last_block = (blocks+1) * block_len
            last_bit = rem
          end
        end
      end
    end
  end
  
  private
  
  def make_params_hash
    @total_size = 0
    @torrent["info"]["files"].each { |file| @total_size += file["length"] }
    {
      info_hash:  @info_hash,
      peer_id:    @peer_id,
      port:       6881,
      uploaded:   0,
      downloaded: 0,
      left:       @total_size,
      compact:    1,
      no_peer_id: 0
    }
  end
  
end