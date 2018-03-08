require 'net/http'
require 'uri'
require 'snitcher'
require 'yaml'

def open(url)
  Net::HTTP.get(URI.parse(url))
end

time = Time.new
currenttime=time.to_i
config = YAML::load_file('/home/pi/solar/solar-config.yml')

#puts config["secrets"][0]["secret"]

page_content = open('http://192.168.1.101/production')
production = page_content.split("Today</td>     <td> ")[1].split(" kWh")[0]
#puts "Todays production #{production}"

hr_file = File.open('/home/pi/solar/solar_prod_hr.txt', 'r')
previous_prod_hr = hr_file.read

#puts previous_prod_hr

last_hr_prod = production.to_f - previous_prod_hr.to_f

#puts last_hr_prod

File.open('solar_prod_hr.txt', 'w') do |today|
  today.puts production
end

datadogoutput = `curl -sS -X POST -H "Content-type: application/json" -d \
   '{"series":\
         [{"metric":"solar.production",
          "points":[[#{currenttime}, #{production}]],
          "host":"1418.w.lavitt",
          "tags":["environment:home"]}
        ]
}' \
https://app.datadoghq.com/api/v1/series?api_key=#{config["secrets"][0]["secret"]}`

exit!
