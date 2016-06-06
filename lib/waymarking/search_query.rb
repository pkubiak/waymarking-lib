require 'uri'
require 'json'
require 'date'

module Waymarking
  class SearchQuery
    attr_reader :size

    def initialize(web, result)
      @web = web
      @cache = {}
      @uri = result.uri.clone

      unless result.parser.at_css('table.wmd_errorTABLE').nil?
        @size = 0
      else
        @size = result.parser.at_css('#ctl00_ContentBody_WaymarkDisplayControl1_PagerControl1_lblTotalRecords').text.to_i
        parse_page(result)
      end
    end

    # iterate over collection
    # @return [Enumerator]
    def each()

    end



    # Return nth waymark from this search query
    # @param index [Integer] waymark index
    # @return [Waymark, nil] Nth waymark or nil if it doesn't exists
    def [](index)
      return nil if index < 0 or index >= @size

      unless @cache.has_key? index
        page = index / self.per_page
        self.request_nth_page(page)
      end

      @cache[index]
    end

    private

    # Load selected page and parse waymarks on it
    # @param index [Integer] page index
    # @return nil
    def request_nth_page(index)
      params = URI::decode_www_form(@uri.query)
      params['p'] = (index+1).to_i
      uri = @uri.clone
      uri.query = URI::encode_www_form(params)

      @web.get(uri) do |page|
        parse_page(page)
      end

      nil
    end

    # Parse waymarks from given page
    # @param page [Nokogiri] request page
    def parse_page(page)
      doc = page.parser
      page_no = doc.at_css('#ctl00_ContentBody_WaymarkDisplayControl1_PagerControl1_lblPage').text.to_i - 1

      coords = {}

      doc.to_s.match(/var markers = \[(.*?)\];/) { |m|
        m[1].strip.split('},{').compact.each do |item|
          item.gsub(/\s/, '').tap do |x|
            wm = x.match(/code:\"([^\"]+)\"/)[1]
            lat = x.match(/lat:([\.0-9]+)/)[1]
            lng = x.match(/lng:([\.0-9]+)/)[1]
            coords[wm] = [lat.to_f, lng.to_f]
          end
        end
      }

      doc.css('tr.wmd_alt').each_with_index do |item, i|
        params = {
          state: :mini,
          category: item.at_css('.wmd_cat a').text,
          posted_by: item.at_css('.wmd_submitter a').text,
          short_description: item.at_css('.wmd_desc').text,
          thumbnail_url: item.at_css('.wmd_img img').attr('src')
        }

        item.at_css('.wmd_namebold').tap { |x|
          x.at_css('a > img').tap { |y|
            params[:category_icon_url] = URI.join('https://www.waymarking.com', y.attr('src')).to_s
            y.parent.remove
          }
          x.at_css('a').tap { |url|
            params[:title] = url.text
            params[:waymark_url] = url.attr('href')
            params[:waypoint] = url.attr('href').match(/\Ahttp:\/\/www.waymarking.com\/waymarks\/(WM[0-9A-Z]+)/)[1]
          }
        }

        item.at_css('.wmd_location').tap { |x|
          x.at_css('b').remove
          params[:location] = x.text.strip
        }

        # parse creation date
        item.at_css('.wmd_created').text.tap { |x|
          params[:approved_at] =
            if x.include? 'never'
              nil
            else
              DateTime.strptime(
                x.split(':')[1].strip(),
                '%m/%d/%Y'
              )
            end
        }

        # parse last visited date
        item.at_css('.wmd_lastvisited').text.tap { |x|
          params[:last_visited_at] =
            if x.include? 'never'
              nil
            else
              DateTime.strptime(
                x.split(':')[1].strip(),
                '%m/%d/%Y'
              )
            end
        }

        # join location
        if coords.has_key? params[:waypoint]
          x = coords[params[:waypoint]]
          if x.size == 2
            params[:lat] = x[0]
            params[:lng] = x[1]
          end
        end
        wm = Waymarking::Waymark.new(params)

        # store waymark
        @cache[per_page * page_no + i] = wm
      end
    end

    def per_page
      25
    end

  end
end
