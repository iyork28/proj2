class Client
  
  def initialize(args)
    @torrent = decode(args[:torrent_file])
    
  end
  
  def decode(torrent_file)
    File.bdecode(torrent_file)
  end
  
  def run!
    uri = URI(@torrent["announce"])
    uri.query = URI.encode_www_form make_params_hash
    res = Net::HTTP.get_response(uri)
    
    puts res.body.bdecode
    
  end
  
  private
  
  def make_params_hash
    sum = 0
    @torrent["info"]["files"].each { |file| sum += file["length"] }
    sha = Digest::SHA1.digest @torrent["info"].bencode
    {
      info_hash:  sha,
      peer_id:    Digest::SHA1.digest('2d554d313834302d137503b00b2564d256e6a9f4'),
      port:       6881,
      uploaded:   0,
      downloaded: 0,
      left:       sum,
      compact:    1,
      no_peer_id: 0
    }
  end
  
end