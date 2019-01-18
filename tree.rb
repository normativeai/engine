require 'bundler/inline'
require 'open3'

$facts = ARGV[0].split(",").collect{|x| x.strip || x }
$unknowns = ARGV[1].split(",").collect{|x| x.strip || x }
$goals = ARGV[2].split(",").collect{|x| x.strip || x }

def array_to_tree (arr, branch)
  if arr.empty?
    if !branch.empty?
      compute_branch(branch)
    end
  else
    array_to_tree(arr.drop(1), branch + [arr.first])
    array_to_tree(arr.drop(1), branch + ['(~ ' + arr.first + ')'])
    array_to_tree(arr.drop(1), branch)
  end
end

def node(arr, qt=true)
  (qt ? "\"" : "") + (arr.length == 1 ? arr.first : arr.drop(1).reduce(arr.first) { |str,val| str + "," + val}) + (qt ? "\"" : "")
end

def res(str)
  / Theorem/ =~ str
end

def theorem?(branch, goal)
  ex = "ruby prove1.rb \"([un,#{node($facts, false)},#{node(branch,false)}],#{goal})\""
  stdout, stderr, status = Open3.capture3(ex)
  $stderr.puts ex
  $stderr.puts stdout
  res(stdout)
end

def compute_branch(branch)
  puts "#{node($facts)} -- #{node(branch.first(1))};"
  print (node(branch.first(1)))
  for i in 2..branch.length
    print " -- #{node(branch.first(i))}"
  end
  puts ";"
  for i in 1..branch.length
    puts "#{node(branch.first(i))} [label=\"#{branch[i-1]}\"];"
  end

  $goals.each { |goal| theorem?(branch,goal) ? (puts "#{node(branch)} -- \"#{goal}\"") : ""}
end


puts "graph un {"
array_to_tree($unknowns,[])
puts "}"
