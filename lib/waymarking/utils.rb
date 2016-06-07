require 'nokogiri'
module Waymarking
  class Utils

    # Convert results of given search query to KML format, with category
    #  icons support as POI icons
    #
    # @param search_query [Waymarking::SearchQuery] search query to convert
    # @param amount [Integer, :all] number of elements to convert
    #
    # @return [Nokogiri::XML] XML document
    #
    def self.to_kml(search_query, amount = :all)
      Nokogiri::XML::Builder.new do |xml|
        xml.kml(xmlns: 'http://www.opengis.net/kml/2.2') do
          items = if amount == :all
            search_query.all
          else
            search_query.take(amount)
          end

          items.each do |wm|
            xml.Placemark do
              xml.name "#{wm.waypoint} #{wm.title}"
              xml.description wm.short_description
              xml.Point do
                xml.coordinates "#{wm.lng},#{wm.lat}"
              end
            end
          end
        end
      end
    end
  end
end
