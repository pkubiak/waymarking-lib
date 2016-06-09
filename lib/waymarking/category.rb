module Waymarking
  class Category
    @@cache = {}

    GUID_REGEXP = /waymarking.com\/cat\/details\.aspx\?f=1&guid=([-a-z0-9]*)/

    attr_reader :guid
    attr_reader :name, :description, :expanded_description
    attr_reader :posting_instruction, :visiting_instruction
    attr_reader :icon_url, :icon
    attr_reader :records_count
    attr_reader :allow_ratings, :manage_by

    def initialize(params = {})
      attrs = [:guid, :name, :description, :expanded_description, :posting_instruction,
        :visiting_instruction, :icon_url, :icon, :records_count, :allow_ratings, :manage_by
      ]
      attrs.each do |key|
        instance_variable_set("@#{key}", params[key])
      end
    end

    ####### Class methods #######

    # Load categories cache from file. It is used during .to_kml routine, to add
    #  default visiting instruction and icons.
    # @param path [String, nil] Path to categories cache, if nil default path will be used
    # @return [nil]
    def self.cache_preload(path = nil)
      @@cache = {}
      path = File.join(File.dirname(__FILE__), '..', 'data', 'categories.yml')

      File.open(path) do |f|
        cache = YAML::load f.read
        if cache.is_a? Hash
          cache.each do |key, value|
            if value.is_a? Waymarking::Category then
              @@cache[key] = value
              @@cache[key].freeze
            end
          end
        end
      end
      nil
    end
    # preload on class load
    Waymarking::Category::cache_preload()

    # Request Category instance from categories caches
    # @param id [String] category id, its parameterized name
    # @return [Category, nil] Category instance if it exists in cache, nil otherwise
    def self.from_cache(id)
      @@cache[id]
    end

    # Create new Category instance from given HTML
    # @param page [Nokogiri::Page] Page containing category details
    # @return [Waymarking::Category, nil] Category instance
    def self.from_html(page)
      options = {
        guid: GUID_REGEXP.match(page.uri.to_s)[1],
        name: page.at_css('span#ctl00_ContentBody_CategoryControl1_lblName').text.strip,
        description: page.at_css('span#ctl00_ContentBody_CategoryControl1_lblDescription').text.strip,
        expanded_description: page.at_css('span#ctl00_ContentBody_CategoryControl1_lblLongDescription').text.strip,
        posting_instruction: nil,
        visiting_instruction: page.at_css('span#ctl00_ContentBody_CategoryControl1_lblLogInstructions').text.strip,
        icon_url: URI.join('http://www.waymarking.com/', page.at_css('img#ctl00_ContentBody_CategoryControl1_imgIcon').attr('src')).to_s,
        icon: nil,
        records_count: page.at_css('#ctl00_ContentBody_WaymarkDisplayControl1_PagerControl1_lblTotalRecords').text.to_i,
        allow_ratings: !page.at_css('img[alt="allows ratings"]').nil?,
        managed_by: nil
      }

      Category.new(options)
    end

  end
end
