require 'net/http'
require 'uri'
require 'snitcher'
require 'sqlite3'

def open(url)
  Net::HTTP.get(URI.parse(url))
end

time = Time.new
today = time.strftime("%d-%m-%Y")
currenttime=time.to_i

page_content = open('http://192.168.1.101/production')
production = page_content.split("Today</td>     <td> ")[1].split(" kWh")[0]
puts "Todays production #{production}"

datadogoutput = `curl -sS -X POST -H "Content-type: application/json" -d \
   '{"series":\
         [{"metric":"solar.production",
          "points":[[#{currenttime}, #{production}]],
          "host":"1418.w.lavitt",
          "tags":["environment:home"]}
        ]
}' \
https://app.datadoghq.com/api/v1/series?api_key=#{API_KEY}`

begin
db = SQLite3::Database.open "solardata.db"
db.execute "INSERT INTO solarreadings(power, currentdate) values(#{production}, '#{today}');"
rescue SQLite3::Exception => e
	puts "exception occured"
	puts e

ensure
	db.close if db
end

graph = "|" * production.to_i

File.open('/var/www/html/tempindex.html', 'w') do |newfile|

   newfile.puts %Q{<!DOCTYPE html>}
   newfile.puts %Q{<html>}
   newfile.puts %Q{  <head>}
   newfile.puts %Q{    <title>My Solar Production</title>}
   newfile.puts %Q{    <link rel="stylesheet" type="text/css" href="style.css">}
   newfile.puts %Q{  </head>}
   newfile.puts %Q{  <body>}
   newfile.puts %Q{  <h1> My Solar Production </h1>}
   newfile.puts %Q{<p> <em1> #{production} kWh     --  #{today}  -- </em1> <em2> #{graph} </em2> </p>}

   File.open('/var/www/html/index.html', 'r+').each_with_index do |oldfile, index| next if index <= 7
        oldfile.each_line { |line| newfile.puts line}
   end
end
File.delete('/var/www/html/index.html');
File.rename('/var/www/html/tempindex.html', '/var/www/html/index.html');

Snitcher.snitch("ecd64f2684")

exit!
