class Peer
  attr_accessor :ip, :port, :response, :connection, :id
  
  
  def initialize(args)
    @ip         = IPAddr.ntop args[:ip]
    @port       = args[:port]
    @id    = args[:peer_id]
    @info_hash  = args[:info_hash]
    @handshake  = gen_handshake
    
    # @sock = TC
  end
  
  def connect
    begin
      @connection = TCPSocket.new(@ip, @port)
    rescue => exception
      puts "Connection with #{@ip} failed"
      return false
    end
    
  end
  
  def start_handshake
    if @connection.nil?
      if connect
        @connection.write(@handshake)
      else
        return false
      end
    else
      @connection.write(@handshake)
    end
    
    @handshake_response = HandshakeResponse.new(connection: @connection)
    
    if @handshake_response.info_hash == @info_hash
      @bitfield = get_bitfield
      
    end
    true
  end
  
  def start! args
    # send interested
    # t = Thread.new { @message_handler = MessageHandler.new({peer: self, queue: args[:block_queue], data_hash: args[:data_hash], mutex: args[:mutex]} )}
    # t.join
    
    @message_handler = MessageHandler.new({ peer: self, queue: args[:block_queue], data_hash: args[:data_hash], mutex: args[:mutex] })
    
    # @message_handler = MessageHandler.new(peer: self)
    
  end
  
  def close_connection
    @connection.close
  end
  
  private
  
  def gen_handshake
    "\x13BitTorrent protocol\x00\x00\x00\x00\x00\x00\x00\x00#{@info_hash}#{@id}"
  end
  
  def get_bitfield
    length = @connection.read(4).unpack('N').first
    id = @connection.read(1).bytes.first
    if id == 5
      @bitfield = @connection.read(length-1).unpack('B8'*(length-1))
      # puts @bitfield
    else
      @bitfield=nil
    end
  end
  
  def gen_interested
    
  end
  
end