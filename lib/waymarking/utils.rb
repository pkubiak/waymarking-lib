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

          items =
            if amount == :all then
              search_query.all
            else
              search_query.take(amount)
            end
          styles = {}

          items.each do |wm|
            xml.Placemark do
              xml.name "#{wm.waypoint} #{wm.title}"
              style = File.basename(URI(wm.category_icon_url).path, '.*')

              unless styles.has_key? style
                styles[style] = wm.category_icon_url.gsub('https','http')
              end

              xml.styleUrl "##{style}"
              xml.description do
                last_visited_at = wm.last_visited_at.nil? ? 'never' : wm.last_visited_at.strftime('%d.%m.%Y')
                xml.cdata %Q[
                  <h3 style="margin:0px"><img src="#{wm.category_icon_url.gsub('https','http')}" /> <a href="#{wm.waymark_url}">#{wm.title}</a></h3>
                  <small>in <b>#{wm.category}</b></small>
                  <div style="margin:8px 0"><img src="#{wm.thumbnail_url}"  style="float:left;margin-right:5px"/>#{wm.short_description}</div><hr style="clear:both;margin:8px 0"/>
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

          # generate used icons
          styles.each do |k, v|
            xml.Style(id: k) do
              xml.IconStyle do
                xml.Icon do
                  xml.href v
                end
              end
            end
          end
        end
      end
    end

    # Convert given text to parameter friendly
    # @param text [String] text to convert
    # @return [String] text which contains only -, a-z, 0-9 characters
    def self.parameterize(text)
      text.downcase().gsub(/\s+/,'-').gsub(/[^-a-z0-9]/,'')
    end
  end
end
