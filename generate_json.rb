require "nokogiri"
require 'open-uri'
require 'net/http'
require "colored"
require "json"

categorys = {
  NES: "http://tasvideos.org/Movies-NES-FDS.html",
  SNES: "http://tasvideos.org/Movies-SNES.html",
  N64: "http://tasvideos.org/Movies-N64.html",
  GameCube: "http://tasvideos.org/Movies-N64.html",
  Wii: "http://tasvideos.org/Movies-Wii.html",
  GameBoy: "http://tasvideos.org/Movies-GB-SGB-GBC.html",
  VirtualBoy: "http://tasvideos.org/Movies-VBoy.html",
  GBA: "http://tasvideos.org/Movies-GBA.html",
  DS: "http://tasvideos.org/Movies-DS.html",
  SMS: "http://tasvideos.org/Movies-SMS-GG.html",
  MegaDrive: "http://tasvideos.org/Movies-Genesis-32X-SegaCD.html",
  Saturn: "http://tasvideos.org/Movies-Saturn.html",
  PlayStation: "http://tasvideos.org/Movies-PSX.html",
  PCEngine: "http://tasvideos.org/Movies-PCE-PCECD-SGX.html",
  Arcade: "http://tasvideos.org/Movies-Arcade.html",
  Computer: "http://tasvideos.org/Movies-DOS-MSX-Windows.html",
  Atari2600: "http://tasvideos.org/Movies-A2600-A7800.html",
  Lynx: "http://tasvideos.org/Movies-Lynx.html",
  Colecovision: "http://tasvideos.org/Movies-Coleco.html"
}

json = []
categorys.keys.each do |key|
  url = categorys[key]
  source = Net::HTTP.get(URI.parse(url))
  doc = Nokogiri::HTML source
  movies = []
  
  puts "looking at #{key}"
  
  doc.css(".item").each do |table_element|  
    movie_name = table_element.css("th").inner_text
    movie_url  = ""
  
    table_element.css("a").each do |link|
      if link.attributes["href"]
        link_string = link.attributes["href"].value
  
        if link_string.include? "yout"
          movie_url = link_string
        end
      end
    end
  
    movies << { name: movie_name, url: movie_url }
  end
  
  json << { console: key, movies: movies }
end

File.open("metadata.json", 'w') { |f| f.write(json.to_json.to_s) }
