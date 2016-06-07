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
              xml.description do
                last_visited_at = wm.last_visited_at.nil? ? 'never' : wm.last_visited_at.strftime('%d.%m.%Y')
                xml.cdata %Q[
                  <h2 style="margin:0px">#{wm.title}</h2>
                  <small>in <b>#{wm.category}</b></small>
                  <div><img src="#{wm.thumbnail_url}"  style="float:left;margin-right:5px"/>#{wm.short_description}</div><hr/>
                  <div><b>posted by: </b>#{wm.posted_by}</div>
                  <div><b>location: </b>#{wm.location}</div>
                  <div><b>date approved: </b>#{wm.approved_at.strftime('%d.%m.%Y')}</div>
                  <div><b>last visited: </b>#{last_visited_at}</div>
                ].gsub(/\s+/,' ')
              end
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
