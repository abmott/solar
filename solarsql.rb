require 'net/http'
require 'uri'
require 'snitcher'
require 'sqlite3'

def open(url)
  Net::HTTP.get(URI.parse(url))
end

time = Time.new
today = time.strftime("%Y-%m-%d")

page_content = open('http://192.168.1.101/production')
production = page_content.split("Today</td>     <td> ")[1].split(" kWh")[0]
puts "Todays production #{production}"

#write to database solardata.db table solarreadings
begin
db = SQLite3::Database.open "solardata.db"
db.execute "INSERT INTO solarreadings(power, currentdate) values(#{production}, '#{today}');"
#db.execute "INSERT INTO solarreadings(power, currentdate) values(900, '2017-09-17');"
rescue SQLite3::Exception => e
	puts "exception occured"
	puts e

ensure
	db.close if db
end

graph = "|" * production.to_i

File.open('/var/www/html/tempindex2.html', 'w') do |newfile|

   newfile.puts %Q{<!DOCTYPE html>}
   newfile.puts %Q{<html>}
   newfile.puts %Q{  <head>}
   newfile.puts %Q{    <title>My Solar Production</title>}
   newfile.puts %Q{    <link rel="stylesheet" type="text/css" href="style.css">}
   newfile.puts %Q{  </head>}
   newfile.puts %Q{  <body>}
   newfile.puts %Q{  <h1> My Solar Production </h1>}
   newfile.puts %Q{<p> <em1> #{production} kWh     --  #{today}  -- </em1> <em2> #{graph} </em2> </p>}
   
   File.open('/var/www/html/index2.html', 'r+').each_with_index do |oldfile, index| next if index <= 7
        oldfile.each_line { |line| newfile.puts line}
   end
end
File.delete('/var/www/html/index2.html');
File.rename('/var/www/html/tempindex2.html', '/var/www/html/index2.html');

#Snitcher.snitch("ecd64f2684")

exit!
