$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'waymarking'

def give_instance_with_correct_credentials()
  # Please do not use this credentials for purpose other than testing !!!
  Waymarking::Connector.new('waymarking-lib','<Pum&r[86M6-CasE')
end

def give_instance_with_incorrect_credentials()
  Waymarking::Connector.new('wihmx497KRYp', 'Qx2aAjAT4NYy')
end
