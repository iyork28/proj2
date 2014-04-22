class Block
  attr_accessor :data, :status, :index, :begn, :len
  
  Statuses = {
    0 => :pending,
    1 => :active
  }
  
  def initialize(args)
    @index  = args[:index]
    @begn   = args[:begn]
    @len    = args[:len]
    
    @status = Statuses[0]
    @data = nil
  end
  
end