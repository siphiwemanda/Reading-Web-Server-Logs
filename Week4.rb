#!/usr/bin/ruby

class ApacheLogAnalyzer
def initialize
   @total_hits_by_ip = Hash.new(0)
   @total_hits_per_url = Hash.new(0)
   @secret_hits_by_ip = Hash.new(0)
   @error_count = 0
 end


 def analyze(file_name)
   octet = /\d{,2}|1\d{2}|2[0-4]\d|25[0-5]/
   ip_regex = /^#{octet}\.#{octet}\.#{octet}\.#{octet}/
   url_regex = /[a-zA-Z0-9]+.html/

   File.open(file_name).each do |line|

    ip=ip_regex.match(line)[0]
    url=url_regex.match(line)[0]

    if url == "secret.html"
      secret=1
    end

      if line.include?("404")
        error =1
      end


 count_hits(ip, url, secret, error)
end

 print_hits
 end
 private
 # Count the total and secret queries for a given ip
  #
  # Args:
  # - ip: string -- IP address responsible for the logged entry
  # - url: string -- URL queried for the logged entry
  # - secret: bool -- Whether or not the url queried was secret.html
  # - error: bool -- Whether or not the log entry contained a 404 error
  #
  def count_hits(ip, url, secret, error)
 @total_hits_by_ip[ip]+=1
   @total_hits_per_url[url]+=1
   if secret == 1
     @secret_hits_by_ip[ip]+=1
   end
   if error==1
     @error_count +=1
   end
  end




  def print_hits
    print_string = 'IP: %s, Total Hits: %s, Secret Hits: %s'
    @total_hits_by_ip.sort.each do |ip, total_hits|
      secret_hits = @secret_hits_by_ip[ip]
      puts sprintf(print_string, ip, total_hits, secret_hits)
    end
    url_print_string = 'URL: %s, Number of Hits: %s'
    @total_hits_per_url.sort.each do |url, url_hits|
      puts sprintf(url_print_string, url, url_hits)
    end
    puts sprintf('Total Errors: %s', @error_count)
  end
end
def usage
  puts "No log files passed, please pass at least one log file.\n\n"
  puts "USAGE: #{$PROGRAM_NAME} file1 [file2 ...]\n\n"
  puts "Analyzes apache2 log files for unique IP addresses and unique URLs."
end
def main
  if ARGV.empty?
    usage
    exit(1)
  end
  ARGV.each do |file_name|
    log_analyzer = ApacheLogAnalyzer.new
    log_analyzer.analyze(file_name)
  end
end




if __FILE__ == $PROGRAM_NAME
  main
end
