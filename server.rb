require "sinatra"
require "sinatra/reloader"
require "httparty"
require "json"

def api endpoint, params = {}
  HTTParty.get(endpoint, headers: {
    api_key: "c1741a3bad6145c4a5f7ccf198d460f4"
  }, query: params).parsed_response
end

get "/" do
  content_type :json
  {success: true}.to_json
end

post "/" do
  content_type :json
  out = {}
  body = JSON.parse(request.body.read)

  entranceData = api("https://api.wmata.com/Rail.svc/json/jStationEntrances", {
    Lat: body["latitude"],
    Lon: body["longitude"],
    Radius: body["radius"]
  })

  stationCode = entranceData["Entrances"][0]["StationCode1"]
  station = api("https://api.wmata.com/Rail.svc/json/jStationInfo", {
    StationCode: stationCode
  })
  out[:station] = station["Name"]
  out[:stationLat] = station["Lat"]
  out[:stationLon] = station["Lon"]

  departures = api(
    "https://excellathon.herokuapp.com/wmata/StationPrediction.svc/json/GetPrediction/#{stationCode}"
  )["Trains"]
  out[:departures] = []
  departures.each do |train|
    next if train["Line"] === "--"
    out[:departures].push({
      destination: train["DestinationName"],
      line: train["Line"],
      minutes: train["Min"]
    })
  end

  out.to_json
end
