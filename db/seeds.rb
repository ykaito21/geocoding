require 'open-uri'
require 'nokogiri'
require 'json'
# require 'csv'

# key = ENV['BING_API_KEY']
yah_key = ENV['YAHOO_API_KEY']

Flat.destroy_all

urls = []
number = 1

puts "gather urls"
5.times do
  url = "https://ramendb.supleks.jp/s/#{number.to_s}.html"
  urls << url
  number += 1
end

data = []


puts "create restaurant"
urls.each do |url|
  file = open(url)
  doc = Nokogiri::HTML(file)
  shop_url = url

  unless doc.css(".shop-name").text.include?("閉店") || doc.css(".shop-name").text.include?("移転") || doc.css("#review-pickup-box div:nth-child(1) p.clearfix a img").empty?
    shop_name = doc.css(".shop-name").text.strip
    shop_address = doc.at("//span[@itemprop = 'address']").text.strip
    # pic_url = doc.css("p.clearfix a img").attribute("src").value
    # points = doc.css('#shop-status .point div:first-child').text.strip.to_f
    # open_info = doc.css("#data-table td")[3].text.strip
    # close_info = doc.css("#data-table td")[4].text.strip
    # query = URI.encode(shop_address)

    # pictures = []
    # doc.search('p.clearfix a img').each do |el|
    #   pictures.push(el.attribute("src").value)
    # end

    # json = "https://dev.virtualearth.net/REST/v1/Locations?q=#{query}&culture=ja&key=#{key}"
    # res = JSON.parse(open(json).read)
    # formatted_address = res["resourceSets"][0]["resources"][0]["address"]['formattedAddress']
    # lat = res["resourceSets"][0]["resources"][0]["geocodePoints"][0]["coordinates"][0]
    # lon = res["resourceSets"][0]["resources"][0]["geocodePoints"][0]["coordinates"][1]


    # yah_json = "https://dev.virtualearth.net/REST/v1/Locations?q=#{query}&culture=ja&key=#{yah_key}&output=json"

    base_url = 'https://map.yahooapis.jp/geocode/V1/geoCoder'
    params = {
      'appid' => yah_key,
      'query' => shop_address,
      'results' => '1',
      'output' => 'json'
    }
    url = base_url + '?' + URI.encode_www_form(params)

    yah_res = JSON.parse(open(url).read)
    yah_lon, yah_lat = yah_res['Feature'][0]['Geometry']['Coordinates'].split(',')
    yah_address = yah_res['Feature'][0]['Property']['Address']
    # puts yah_address
    # puts "経度: #{lon}"
    # puts "緯度: #{lat}"


    ramen_shop = {
    name: shop_name,
    address: yah_address,
    # pics: pictures,
    # link: shop_url,
    # points: points,
    latitude: yah_lat,
    longitude: yah_lon,
    # open: open_info,
    # close: close_info
    }

  # data.push(ramen_shop)
  Flat.create!(ramen_shop)
  end
end

# json_restaurants = {
#   restaurants: data
# }
# file_name = "#{number}_data.json"
# File.open(file_name, 'wb') do |file|
#   file.write(JSON.generate(json_restaurants))
# end

puts "finish"
