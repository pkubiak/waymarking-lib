require 'spec_helper'

describe Waymarking::Category do
  describe '.cache_preload()' do
    it 'preload all categories' do
      expect(Waymarking::Category.class_variable_get('@@cache').size).to eq(5)
    end

    it 'preload cache on start' do
      category = Waymarking::Category.from_cache('animal-hospitals')
      expect(category).to be_instance_of(Waymarking::Category)
    end
  end

  describe '.from_cache()' do
    it 'returns frozen instances' do
      expect(Waymarking::Category.from_cache('animal-hospitals').frozen?).to eq(true)      
    end
  end

  describe '.from_html()' do
    it 'correctyl parse all fields available'
  end
end
