class Khronic
  def valid_level?( n )
    send "valid_level_#{n}?"
  end
  def valid_level_1?
    # Need at least one channel
    return false unless channels.length>0
    
    return false unless channels.all?{ |name,channel| channel.lines.is_a? Array }

    lines = channels.map{ |name,channel| channel.lines.length }.uniq    
    return false unless lines.length==1
    
    channels.each do |name,channel|
      
    end
    
    return true
  end
end