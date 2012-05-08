class ClubPCRMessage
  attr_accessor :mesg_subj, :mesg_approved_time
  
  def initialize(subj,approved_time)
    @mesg_subj = subj
    @mesg_approved_time = approved_time
  end 
end


class ClubPCRModerator
   attr_accessor :email,:name, :mesgs_approved, :fast_resp, :slow_resp, :avg_resp, :mesg_ids

  def initialize(email,name='unknown')
    @email = email
    @name = name
    @mesgs_approved = 0

    @fast_resp = Float::INFINITY
    @slow_resp = 0.0
    @avg_resp = 0.0
    @mesg_ids = []
  end

  def process_mesg(mesg_id, tt, approved_time=0.0)
    @mesg_ids.push( ClubPCRMessage.new(mesg_id,approved_time) )

    @fast_resp = tt if tt < @fast_resp
    @slow_resp = tt if tt > @slow_resp
    
    @avg_resp = @avg_resp * @mesgs_approved
    @mesgs_approved += 1
    @avg_resp = (@avg_resp + tt) / @mesgs_approved
  end

end



