#!/usr/bin/ruby

require 'sqlite3'

begin

db = SQLite3::Database.open "solardata.db"
db.execute "INSERT INTO solarreadings(power, currentdate) values(87, '2017-09-16');"

rescue SQLite3::Exception => e

	puts "exception occurred"
	puts e

ensure
	db.close if db
end 
