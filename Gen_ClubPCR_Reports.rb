#!/usr/bin/ruby

require 'gruff'
require 'yaml'
require 'tzinfo'

load 'ClubPCRModerator.rb'

class Graphics_Helper
  
  def print_total_mesgs_moderated_by_mod(title,data)
    g = Gruff::Mini::Pie.new
    g.title = title
    
    data.each_value do |val|
      g.data(val.name, val.mesgs_approved)
    end
    g.write('mesgs by mod.png')
  end
  
  def print_response_times(title,data)
 
    fast = Gruff::Bar.new
    slow = Gruff::Bar.new
    avg = Gruff::Bar.new
    
    fast.title = title
    slow.title = title
    avg.title = title
    
    fast.y_axis_label = 'Seconds to respond'
    slow.y_axis_label = 'Seconds to respond'
    avg.y_axis_label = 'Seconds to respond'
    
    fast.labels = {0=>'Fastest Response (sec)'}
    slow.labels = {0=>'Slowest Response (sec)'}
    avg.labels = {0=>'Avg Response (sec)'}
    
    data.each_value do |val|
      
      fast.data(val.name, [val.fast_resp])
      slow.data(val.name, [val.slow_resp])
      avg.data(val.name, [val.avg_resp])
    end
    
    fast.write('fast response times.png')
    slow.write('slow response times.png')
    avg.write('avg response times.png')
  end
  
  
  def print_response_by_day(title,data)
    graph = Gruff::Bar.new
    graph.title = title
    graph.y_axis_label = '% of approved messages'
    graph.labels = {0=>'Sun',1=>'Mon',2=>'Tue',3=>'Wen',4=>'Thu',5=>'Fri',6=>'Sat'}      

    data.each_value do |mod|
      arr = Array.new(7,0)
      mod.mesg_ids.each do |mesg|
	arr[Time.parse(mesg.mesg_approved_time.to_s).wday] += 1
      end
      
      #normalize to percentages
      arr.each_index{ |i| arr[i] /= (mod.mesgs_approved * 1.0) }
      
      graph.data(mod.name,arr)
    end
    
    graph.write('ClubPCR admin response by day-of-week.png')
  end
  
  def print_response_by_hour(title,data)
      graph = Gruff::Bar.new
      graph.title = title
      graph.y_axis_label = '% of approved messages'
  
      temp = Hash.new
      0.upto(23){ |i| temp[i] = i.to_s }
      
      graph.labels = temp
      
      data.each_value do |mod|
	arr = Array.new(24,0)
	mod.mesg_ids.each do |mesg|
	  arr[Time.parse(mesg.mesg_approved_time.to_s).hour] += 1
	end
	
	#normalize to percentages
	arr.each_index{ |i| arr[i] /= (mod.mesgs_approved * 1.0) }
	
	graph.data(mod.name,arr)
      end 
      
      graph.write('ClubPCR admin response by hour-of-day.png') 
  end

end






class Text_Helper
  def print_text_report(title,date,data)
    
    report = File.open(title,'w')
    report.puts('============ ClubPCR Administration Report ============')
    
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
  filename = 'clubpcr_moderation_stats for 2012-03-16 to 2012-03-23.yaml'
end

p filename

results =  YAML.load_file(filename) 
dates = filename.split.slice(2,3).join(' ').gsub('.yaml','')

graphics = Graphics_Helper.new
graphics.print_total_mesgs_moderated_by_mod('Totals for ' + dates,results)
graphics.print_response_times('Response times for ' + dates,results)
graphics.print_response_by_day('Response of admins by day', results)
graphics.print_response_by_hour('Response of admins by hour', results)

text = Text_Helper.new
text.print_text_report('ClubPCR Report ' + dates + '.txt',dates,results)





