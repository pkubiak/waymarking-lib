require 'spec_helper'

describe Waymarking::Utils do
  describe '.to_kml' do
    it 'generates KML' do
      w = give_instance_with_correct_credentials()
      q = w.search(near: 'Kraków')
      kml = Waymarking::Utils.to_kml(q, 20).to_xml
      puts kml
    end
  end

end
