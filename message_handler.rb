class MessageHandler
  
  def initialize(args)
    @peer = args[:peer]
    @peer.connection.write(interested)
    receive_messages
  end
  
  def interested
    "\0\0\0\1\2"
  end
  
  def receive_messages
    loop do
      begin
        length = peer.connection.read(4).unpack("N")[0]
      rescue
        
      end
  end
  
end