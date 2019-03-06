require 'faraday'
require 'sinatra'

#time_zone = ActiveSupport::TimeZone["Eastern Time (US & Canada)"]

get '/building-permits' do
	url = URI('https://data.miamigov.com/resource/8vfk-ducx.json')
	thisWeek = Date.today-7
	url.query = Faraday::Utils.build_query(
		'$order' => 'applicationnumber DESC',
    		'$limit' => 1000,
		'$where' => "applicationnumber IS NOT NULL" +
		" AND statusdate IS NOT NULL" +
		" AND statusdate > '#{thisWeek.iso8601}'" +
		" AND buildingpermitstatusdescription = 'Active'"+
		" AND issueddate IS NOT NULL"+
		" AND deliveryaddress IS NOT NULL"+
		" AND companyname IS NOT NULL")


connection = Faraday.new(url: url.to_s)
response = connection.get

collection = JSON.parse(response.body)
  
  features = collection.map do |record|
    time = Time.iso8601(record['issueddate'])
title =
      "#{Time.iso8601(record['issueddate']).strftime("%Y/%m/%d  %I:%M %p")} - A new building permit (#{record['applicationnumber']}) has been issued at #{record['deliveryaddress']} to #{record['companyname']}."

  {
    'id' => record['applicationnumber'],
    'type' => 'Feature',
    'properties' => record.merge('title' => title),
    'geometry' => record['location_1']
  }
  end
  
  content_type :json
  JSON.pretty_generate('type' => 'FeatureCollection', 'features' => features)
end
