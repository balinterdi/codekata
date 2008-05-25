# http://codekata.pragprog.com/2007/01/kata_four_data_.html
def extract_smallest_temp_diff
  min_day = nil
  min_temp_diff = -1
  open("4-weather.dat", "r") do |f|
    f.each_line do |line|
      if line =~ /^\s*(\d+)\s+(\d+)\s+(\d+).*$/
        temp_diff = ($3.to_i - $2.to_i).abs
        if min_temp_diff == -1 || temp_diff < min_temp_diff
          # puts "New min temp diff found at: #{$1}"
          min_temp_diff = temp_diff
          min_day = $1
        end
      end
    end
  end
  min_day
end

def extract_smallest_goal_difference
  team_with_min_goal_diff = nil
  min_goal_diff = -1
  open("4-football.dat", "r") do |f|
    f.each_line do |line|
#      All these operators all greedy (I'll show you examples). To make
#      non-greedy operator you must add '?' after operator. So non-greedy
#      operators are:
#      *?, +?, ??, {m,n}?
      if line =~ /^\s*\d+\.\s*(\w+).*?(\d+)\s*-\s*(\d+).*$/
        # puts "#{$1} F: #{$2} A: #{$3}"
        goal_diff = ($3.to_i - $2.to_i).abs
        if min_goal_diff == -1 || goal_diff < min_goal_diff
          # puts "New min goal_diff found at: #{$1}"
          min_goal_diff = goal_diff
          team_with_min_goal_diff = $1
        end
      end
    end
  end
  team_with_min_goal_diff
end

def extract_smallest_difference(file, line_pattern, sign_col, col1, col2)
  value_at_min = nil
  min_diff = -1
  open(file, "r") do |f|
    f.each_line do |line|
      if line =~ line_pattern
        match1 = eval("$#{col1}")
        match2 = eval("$#{col2}")
        diff = (match1.to_i - match2.to_i).abs
        if min_diff == -1 || diff < min_diff
          min_diff = diff
          value_at_min = eval("$#{sign_col}")        
        end
      end
    end
  end
  value_at_min
end

if __FILE__ == $0
  puts extract_smallest_temp_diff # 14
  puts extract_smallest_goal_difference # Aston_Villa
  puts extract_smallest_difference("4-weather.dat", /^\s*(\d+)\s+(\d+)\s+(\d+).*$/, 1, 2, 3)
  puts extract_smallest_difference("4-football.dat", /^\s*\d+\.\s*(\w+).*?(\d+)\s*-\s*(\d+).*$/, 1, 2, 3)
end