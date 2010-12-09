class Khronic
  def valid_level?( n )
    send "valid_level_#{n}?"
  end
  def valid_level_1?
    # Need at least one channel
    return false unless channels.length>0
    
    return false unless channels.all?{ |name,channel| channel.lines.is_a? Array }

    lines = channels.map{ |name,channel| channel.lines.length }.uniq    
    unless lines.length==1
      warn "Disparate numbers of lines: #{lines.inspect}" if $DEBUG
      return false
    end
    
    channels.each do |name,channel|
      channel.lines.each do |slot|
        if slot && !samples[slot['sample']]
          warn "Missing sample '#{slot['sample']}'" if $DEBUG
          return false
        end
      end
    end
    
    return true
  end
end