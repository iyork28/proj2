class HandshakeResponse
  
  attr_reader :info_hash
  
  def initialize(args)
    @connection = args[:connection]
    parse_connection(@connection)
  end
  
  def to_string
    "#{@pstrlen} #{@pstr} #{@info_hash} #{@peer_id}"
  end
  
  def compare_info_hash(info_hash)
    @info_hash == info_hash
  end
  
  private
  
  def parse_connection(connection)
    @pstrlen  = @connection.getbyte
    @pstr     = @connection.read(@pstrlen)
    reserved  = @connection.read(8).unpack('a8')
    @info_hash= @connection.read(20)
    @peer_id  = @connection.read(20).unpack('a20')
  end
    
end