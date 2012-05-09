load 'YahooGroupModerator.rb'

#check for gruff installed
#ugh, this is yucky.
#via: http://stackoverflow.com/questions/1032114/check-for-ruby-gem-availability
begin
  Gem::Specification.find_by_name('gruff')
  require 'gruff'

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
    
    
    def print_response_by_day(group_name,title,data)
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
      
      graph.write(group_name + ' admin response by day-of-week.png')
    end
    
    def print_response_by_hour(group_name,title,data)
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
        
        graph.write(group_name + ' admin response by hour-of-day.png') 
    end
  end

rescue LoadError
  puts 'Loading gruff gem failed, no graphics for you!'
  
  #fake out graphics ops cause i cant be arsed to figure out right way of doing this bit
   class Graphics_Helper
    def print_response_by_hour(group_name,title,data)  end
    def print_response_by_day(group_name,title,data)   end
    def print_response_times(title,data)               end
    def print_total_mesgs_moderated_by_mod(title,data) end
   end
  
end


