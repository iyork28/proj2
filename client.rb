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
    
    # puts @peers
    @peers[1].start_handshake # until I do multithreading
    
    @peers[1].start! @block_queue
    
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