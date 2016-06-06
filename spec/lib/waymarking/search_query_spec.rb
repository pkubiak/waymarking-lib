require 'spec_helper'

describe Waymarking::SearchQuery do
  context 'correct query' do
    it 'should work' do
      expect {
        w = give_instance_with_correct_credentials()
        q = w.search(near: 'Kraków')

        expect(q).to be_an_instance_of(Waymarking::SearchQuery)

        expect(q.size).not_to eq(0)

        expect(q[0]).to be_an_instance_of(Waymarking::Waymark)

        expect(q.take(50).size).to eq(50)

        pp q[20]
      }.not_to raise_exception
    end
  end

  context 'wrong query' do
    it 'should return no results' do
      w = give_instance_with_correct_credentials()
      q = w.search(keyword: 'wihmx497KRYp')
      expect(q.size).to eq(0)

      expect(q[0]).to be_nil
    end
  end
end
