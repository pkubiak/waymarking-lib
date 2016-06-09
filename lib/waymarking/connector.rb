require 'mechanize'
require 'logger'

module Waymarking
  class Connector
    #
    # @param username [String] login name
    # @param password [String] password
    def initialize(username, password, options = {})
      @web = Mechanize.new
      @log = Logger.new(STDOUT)

      # Perform sing-in
      @web.get('https://www.waymarking.com/login/default.aspx') do |page|
        result = page.form_with(action: '/login/default.aspx') do |f|
          #pp f
          f['ctl00$ContentBody$myUsername'] = username
          f['ctl00$ContentBody$myPassword'] = password
        end.click_button

        #message = result.parser.at_css('#ctl00_ContentBody_lbMessageText').try(:text) || ''
        error = result.parser.at_css('#ctl00_ContentBody_ErrorText')
        raise Waymarking::CredentialsError, error.text unless error.nil?
      end
    end

    def request_uri(uri)

    end

    #
    # Perform advenced searching on waymarking.com
    #
    # @param keyword [String]
    # @param near [String]
    # @param radius [Integer]
    # @param type [Symbol]
    # @param published_within [Symbol]
    # @param country [Symbol]
    # @param exclude_visited [Boolean]
    # @param exclude_my [Boolean]
    # @param sort_by [Symbol] one of [:closest, :a_z, :z_a, :newest_approved, :newest_created]
    #
    # @return SearchQuery
    def search(keyword: nil, near: nil, radius: 10, type: :all, published_within: :all_dates,
      country: nil, exclude_visited: false, exclude_my: false, sort_by: :closest)

      @web.get('https://www.waymarking.com/wm/search.aspx') do |page|
        form = page.form_with(action: '/wm/search.aspx') do |f|
          f['ctl00$ContentBody$FilterControl1$txtKeyword'] = keyword.to_s
          f['ctl00$ContentBody$FilterControl1$uxSearchLocation'] = near.to_s
          f['ctl00$ContentBody$FilterControl1$ddlRadius'] = radius.to_s
          # TODO: support all paramters
        end
        result = form.click_button(form.button_with(name: 'ctl00$ContentBody$FilterControl1$btnUpdate'))

        #pp result

        #puts result.parser
        raise MalformedRequest, '' if result.title.strip != 'Waymark Search Results'


        return SearchQuery.new(@web, result)
      end
    end

    # Request profile page for given user
    #
    # @param username [String] option username
    # @param uid [String] optional uid of user
    def profile(username = nil, uid = nil)

    end

    # Load information about categories
    def categories()
      @web.get('http://www.waymarking.com/cat/categorydirectory.aspx') do |page|
        ile = 0
        #puts page.parser.to_html.to_s
        cache = {}

        page.parser.css('div#content div.gutter a').each do |cat|
          href = cat.attr('href')
          m = Category::GUID_REGEXP.match href
          key = Waymarking::Utils.parameterize(cat.text)
          unless m.nil? then
            ile +=1
            raise DuplicatedCategory if cache.has_key? key

            cache[key] = m[1]
            #puts "#{ile} #{key} #{cat.text} #{m[1]}"
          else
            puts href
          end

        end

        cache2 = {}
        cache.keys.each do |key|
          @web.get("http://www.waymarking.com/cat/details.aspx?f=1&guid=#{cache[key]}&exp=True") do |page2|
            begin
              cat = Waymarking::Category.from_html(page2)
              cache2[key] = cat
            rescue
              puts key
            end
          end
        end

        File.open('categories.yml', 'w') do |f|
          f.write YAML::dump(cache2)
        end
      end
    end
  end
end
