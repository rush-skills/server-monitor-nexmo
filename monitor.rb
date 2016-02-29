# -*- coding: utf-8 -*-

require 'nexmo'

THRESHOLD = ENV["THRESHOLD"].to_f
SENDER = ENV["SENDER"]
MESSAGE_NUMBER = ENV["MESSAGE_NUMBER"]
NEXMO_KEY = ENV["NEXMO_KEY"]
NEXMO_SECRET = ENV["NEXMO_SECRET"]

def get_disk_usage
	df = `df --total`  
	df.split(" ")[-2].to_f.round(2) 
end

def get_memory_usage
	free = `free`  
	lines = free.split("\n")  
	memline = lines[2].split()  
	used = memline[2].to_f  
	free = memline[3].to_f  
	total = used + free  
	(used/total * 100).round(2)  
end

def get_cpu_usage
	@proc0 = File.readlines('/proc/stat').grep(/^cpu /).first.split(" ")
	sleep 1  
	@proc1 = File.readlines('/proc/stat').grep(/^cpu /).first.split(" ")

	@proc0usagesum = @proc0[1].to_i + @proc0[2].to_i + @proc0[3].to_i
	@proc1usagesum = @proc1[1].to_i + @proc1[2].to_i + @proc1[3].to_i
	@procusage = @proc1usagesum - @proc0usagesum

	@proc0total = 0
	for i in (1..4) do  
	  @proc0total += @proc0[i].to_i
	end  
	@proc1total = 0
	for i in (1..4) do  
	  @proc1total += @proc1[i].to_i
	end  
	@proctotal = (@proc1total - @proc0total)

	@cpuusage = (@procusage.to_f / @proctotal.to_f)
	(100 * @cpuusage).to_f.round(2)
end

def check
	while true
		disk = get_disk_usage
		mem = get_memory_usage
		cpu = get_cpu_usage
		if disk > THRESHOLD
			send("You disk usage is now #{disk}. Please do something about it.")
		end
		if mem > THRESHOLD
			send("You memory usage is now #{mem}. Please do something about it.")
		end
		if cpu > THRESHOLD
			send("You cpu usage is now #{cpu}. Please do something about it.")
		end
	end
end

def send(message)
	puts message
	@nexmo.send_message(from: SENDER, to: MESSAGE_NUMBER, text: message)
	sleep 3600
end

@nexmo = Nexmo::Client.new(key: NEXMO_KEY, secret: NEXMO_SECRET)
check