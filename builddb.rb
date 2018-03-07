
require 'sqlite3'


time = Time.new
today = time.strftime("%Y-%m-%d")

begin
db = SQLite3::Database.open "solardata.db"
solardataraw = File.readlines('rawdata.txt')
powerarray = solardataraw.map { |power| power.scan(/<em1> (.*?) kWh/)}
datearray = solardataraw.map { |date| date.scan(/--  (.*?)  --/) }
powerarray.zip(datearray).reverse.each do |power, date|
npower = power.to_s
npower.tr!('"[]','')
ndate = date.to_s
ndate.tr!('"[]','')
#puts "the power was #{npower} on #{ndate}."
#end
db.execute "INSERT INTO solarreadings(power, currentdate) values(#{npower}, \'#{ndate}\');"
end

rescue SQLite3::Exception => e
	puts "exception occured"
	puts e

ensure
	db.close if db
end
