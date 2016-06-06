module Waymarking

  class Waymark
    attr_reader :state
    attr_reader :waypoint
    attr_reader :title, :category, :posted_by, :short_description
    attr_reader :location, :lat, :lng
    attr_reader :waymark_url, :thumbnail_url, :category_icon_url
    attr_reader :approved_at, :last_visited_at

    def initialize(params)
      attrs = [:state, :waypoint, :title, :category, :posted_by, :short_description,
        :location, :lat, :lng, :waymark_url, :thumbnail_url, :category_icon_url,
        :approved_at, :last_visited_at]
      attrs.each do |key|
        instance_variable_set("@#{key}", params[key])
      end
    end
  end
end
