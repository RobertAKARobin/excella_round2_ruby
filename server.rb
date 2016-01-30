require "sinatra"
require "sinatra/reloader"
require "httparty"
require "json"

def api endpoint, params
  HTTParty.get("https://api.wmata.com/Rail.svc/json/#{endpoint}", headers: {
    api_key: "c1741a3bad6145c4a5f7ccf198d460f4"
  }, query: params)
end

get "/" do
  content_type :json
  {success: true}.to_json
end

post "/" do
  content_type :json
  body = JSON.parse(request.body.read)

  entranceData = api("jStationEntrances", {
    Lat: body["latitude"],
    Lon: body["longitude"],
    Radius: body["radius"]
  }).parsed_response

  station = api("jStationInfo", {
    StationCode: entranceData["Entrances"][0]["StationCode1"]
  }).parsed_response

  {
    station: station["Name"],
    stationLat: station["Lat"],
    stationLon: station["Lon"]
  }.to_json
end
