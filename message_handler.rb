class MessageHandler
  
  def initialize(args)
    @peer = args[:peer]
    @block_queue = args[:queue]
    @peer.connection.write(interested)
    receive_messages
  end
  
  def interested
    "\0\0\0\1\2"
  end
  
  def receive_messages
    loop do
      begin
        length = @peer.connection.read(4).unpack("N").first
        message_id = @peer.connection.read(1).bytes.first
        
        case message_id
        when 0
          puts "choked by #{@peer.id}" # do nothing
        when 1
          puts "unchoked by #{@peer.id}"
          
          request_block
        when 2
          puts "#{@peer.id} is interested"
          cancel
        when 3
          puts "#{@peer.id} is not interested"
          cancel
        when 4
          puts "#{@peer.id} has stuff"
          cancel
        when 5
          puts "bitfield from #{@peer.id}"
          cancel
        when 6
          puts "request from #{@peer.id}"
          cancel
        when 7
          puts "piece from #{@peer.id}"
          
          cancel
        when 8
          puts "cancel from #{@peer.id}"
          cancel
        when 9
          puts "port message from #{@peer.id}"
          cancel
        end
      rescue => exception
        puts exception
        break
      end
    end
  end
  
  def request_block
    len = "\0\0\0\x0d"
    id = "\6"
    @block = @block_queue.pop
    @block.status = :active
    # index = "\0\0\0\0"
    # begn = "\0\0\0\0"
    # length = "\x00\x00\x40\x00"
    index   = [block.index].pack('N')
    begn    = [block.begn].pack('N')
    length  = [block.len].pack('N')
    
    @peer.connection.write(len+id+index+begn+length)
    @block_queue.push @block
    # @peer.connection.write("test")
    puts "sent message"
  end
  
  def cancel
    @peer.close_connection
  end
  
  def receive_block
    
  end
  
end