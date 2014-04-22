class BlockQueue
  attr_accessor :queue
  
  def initialize(args)
    @size = args[:size]
    @queue = Queue.new
    enqueue_block_requests
  end
  
  def enqueue_block_requests
    block_length = 2**14
    blocks = @size / block_length
    rem = @size - blocks
    
    for i in 0..(blocks-1)
      @queue.push Block.new(index: 0, begn: (i*block_length), len: block_length)
    end
    
    if rem != 0
      @queue.push Block.new(index: 0, begn: blocks*block_length, len: block_length)
    end
    
    def push block
      @queue.push block
    end
    
    def pop
      @queue.pop
    end
    
  end
  
end