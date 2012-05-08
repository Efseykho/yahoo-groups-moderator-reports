#!/usr/bin/ruby

require 'gmail'
require 'tzinfo'

load 'YahooGroupModerator.rb'

raise "Error: invalid args. Want: user_name, password, group_name, start_date, end_date. Date format: yyyy-mm-dd\n" unless ARGV.length >= 3

uname = ARGV[0]
pass = ARGV[1]
group_name = ARGV[2]

if ARGV[3] == nil
  start_date = (Date.today - 7)
else
  start_date = Date.parse(ARGV[3])
end


if ARGV[4] == nil
  stop_date = start_date + 7
else
  stop_date = Date.parse(ARGV[4])
end

mods = Hash.new #storage for statistics about mods

g = Gmail.connect(uname,pass)
raise 'Error: could not login with credentials' if !g.logged_in?
  
#collect all labels with given range
g.inbox.find(:mailed_by => 'returns.groups.yahoo.com', :to => group_name+'.yahoogroups.com',:before => stop_date, :after => start_date).each  do |email|
  printf("Retrieving email: %s\n",email.subject)
  
  time_sent = Time.parse(email.date).localtime
  
  time_str = email.header.to_s.scan(/^X-eGroups-Approved-By:(.*)Mailing-List/m)
  next if time_str == []
  time_str = time_str[0][0].strip.gsub(/[<>\n\r]/,'')
  
  approver_name = time_str.split[0]
  approver_email = time_str.split[1]
  approved_time = Time.parse(time_str.split.slice(4,5).join(' ')).localtime
   
  #if mod email doesnt exist add it
  if !mods.has_key?(approver_email)
    mods[approver_email] = YahooGroupModerator.new(approver_email,approver_name)
  end
    
  #process email for this mod
  mods[approver_email].process_mesg(email.subject,approved_time - time_sent,approved_time)

end  
  
g.logout

fname = sprintf('yahoo_group[%s]_moderation_stats for %s to %s.yaml', group_name,start_date.to_s, stop_date.to_s)
                
                
#File.open('yahoo_group_moderation_stats for ' + start_date.to_s + ' to ' + stop_date.to_s + '.yaml', 'w') {|f| f.write(mods.to_yaml) }
File.open(fname, 'w') {|f| f.write(mods.to_yaml) }

