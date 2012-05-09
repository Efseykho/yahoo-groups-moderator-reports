#!/usr/bin/ruby

require 'yaml'
require 'tzinfo'

load 'YahooGroupModerator.rb'
load 'GraphicsHelper.rb'

class Text_Helper
  def print_text_report(title,date,data)
    
    report = File.open(title,'w')
    report.puts('============ Yahoo Groups Administration Report ============')
    
    report.puts("\n\n")
    report.puts('Reporting Period: ' + date)
    report.puts('Total Moderators active this period: ' + data.size.to_s)
    
    num_msgs = 0.0
    cum_avg = 0.0
    data.each_value do |val|
      num_msgs += val.mesgs_approved
      cum_avg += val.mesgs_approved * val.avg_resp
    end
    report.puts('Total Messages approved this period: ' + num_msgs.to_s)
    report.puts('Total Avg approval time (minutes): ' + ((cum_avg/num_msgs)/60.0).to_s)
    
    report.puts("\n***************************\n")
    report.puts("Individual Moderator Report\n")
    report.puts("***************************\n\n")
    
    data.each_value do |val|
	 report.puts('Moderator name: ' + val.name.to_s)
	 report.puts('Messages approved: ' + val.mesgs_approved.to_s)
	 report.puts('Fastest response: ' + val.fast_resp.to_s)
	 report.puts('Slowest response: ' + val.slow_resp.to_s)
	 report.puts('Average response: ' + val.avg_resp.to_s)
	 report.puts("\n")
    end
    
    report.puts("\n\n")
    report.puts('============ Report Generated: ' + Time.now.to_s + ' ============')
    
    report.close
  end
  
end


#raise "Error: invalid args. Want: filename_to_yaml" unless ARGV.length == 1
if ARGV.length == 1 
  filename = ARGV[0]
else
  filename = 'yahoo_group[ClubPCR]_moderation_stats for 2012-05-01 to 2012-05-08.yaml'
end

puts filename

group_name = filename.slice(/\[(.*)\]/)
group_name = $1

results =  YAML.load_file(filename) 
dates = filename.split.slice(2,3).join(' ').gsub('.yaml','')

graphics = Graphics_Helper.new
graphics.print_total_mesgs_moderated_by_mod('Totals for ' + dates,results)
graphics.print_response_times('Response times for ' + dates,results)
graphics.print_response_by_day(group_name,'Response of admins by day', results)
graphics.print_response_by_hour(group_name, 'Response of admins by hour', results)

text = Text_Helper.new
text.print_text_report('[' + group_name + ']Yahoo Groups Report' + dates + '.txt',dates,results)
