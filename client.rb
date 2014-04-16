class Client
  
  def initialize(args)
    @torrent = decode(args[:torrent_file])
    
  end
  
  def decode(torrent_file)
    File.bdecode(torrent_file)
  end
  
  def run!
    # test = HTTP.get @torrent["announce"], params: make_params_hash
    uri = URI(@torrent["announce"])
    uri.query = URI.encode_www_form make_params_hash
    
    res = Net::HTTP.get_response(uri)
    
    puts res
  end
  
  private
  
  def make_params_hash
    {
      info_hash:  URI::encode(Digest::SHA1.hexdigest @torrent["info"].bencode),
      peer_id:    URI::encode(Mac.addr.tr(':','').concat "12345678"),
      port:       6681,
      uploaded:   0,
      downloaded: 0,
      left:       0,
      compact:    0,
      no_peer_id: 0 
    }
  end
  
end