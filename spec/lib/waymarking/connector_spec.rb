require 'spec_helper'

describe Waymarking::Connector do
  context 'user provided correct credentials' do
    it 'should sign-in successfully' do
      expect {
        give_instance_with_correct_credentials()
      }.not_to raise_exception
    end
  end

  context 'user provided incorrect credentials' do
    it 'should not sign-in' do
      expect {
        give_instance_with_incorrect_credentials()
      }.to raise_exception Waymarking::CredentialsError
    end
  end
end
