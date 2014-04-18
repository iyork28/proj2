class Peer
  
  def initialize(args)
    @ip         = IPAddr.ntop args[:ip]
    @port       = args[:port]
    @peer_id    = args[:peer_id]
    @info_hash  = args[:info_hash]
    @handshake  = gen_handshake
    
    # @sock = TC
  end
  
  private
  
  def gen_handshake
    "\x13BitTorrent protocol\x00\x00\x00\x00\x00\x00\x00\x00#{@info_hash}#{@peer_id}"
  end
  
end