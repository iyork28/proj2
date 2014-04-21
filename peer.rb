class Peer
  attr_accessor :ip, :port, :response
  
  
  def initialize(args)
    @ip         = IPAddr.ntop args[:ip]
    @port       = args[:port]
    @peer_id    = args[:peer_id]
    @info_hash  = args[:info_hash]
    @handshake  = gen_handshake
    
    # @sock = TC
  end
  
  def connect
    @connection = TCPSocket.new(@ip, @port)
  end
  
  def start_handshake
    if @connection.nil?
      connect
      @connection.write(@handshake)
    else
      @connection.write(@handshake)
    end
        
    @response = Response.new(connection: @connection)
    
    # puts @connection.getbyte
  end
  
  private
  
  def gen_handshake
    "\x13BitTorrent protocol\x00\x00\x00\x00\x00\x00\x00\x00#{@info_hash}#{@peer_id}"
  end
  
end