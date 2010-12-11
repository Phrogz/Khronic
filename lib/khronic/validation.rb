class Khronic
  def valid_level?( n )
    send "valid_level_#{n}?"
  end
  def valid_level_1?
    # Need at least one track
    return false unless tracks.length>0
    
    return false unless tracks.all?{ |name,track| track.lines.is_a? Array }

    lines = tracks.map{ |name,track| track.lines.length }.uniq    
    unless lines.length==1
      warn "Disparate numbers of lines: #{lines.inspect}" if $DEBUG
      return false
    end
    
    tracks.each do |name,track|
      track.lines.each do |slot|
        if slot && !samples[slot['sample']]
          warn "Missing sample '#{slot['sample']}'" if $DEBUG
          return false
        end
      end
    end
    
    return true
  end
end