require 'net/http'
require 'uri'


api_key = "API_KEY"
application_key = "APP_KEY"

def open(url)
  Net::HTTP.get(URI.parse(url))
end

time = Time.new
today = time.strftime("%d-%m-%Y")
currenttime=time.to_i

puts currenttime

page_content = open('http://192.168.1.101/production')
production = page_content.split("Today</td>     <td> ")[1].split(" kWh")[0]
puts "Todays production #{production}"


datadogoutput = `curl -sS -X POST -H "Content-type: application/json" -d \
   '{"series":\
         [{"metric":"test.metric",
          "points":[[#{currenttime}, #{production}]],
          "host":"test.example.com",
          "tags":["environment:test"]}
        ]
}' \
https://app.datadoghq.com/api/v1/series?api_key=b628c6c3f64c0495c61704af77d065f6`
