require 'spec_helper'

describe 'Json compare' do
  describe 'Strings Comparison' do
    it 'should return empty String' do
      result = JsonCompare.get_diff('DummyTest', 'DummyTest')
      result.should eq('')
    end

    it 'should return new String' do
      result = JsonCompare.get_diff('Test', 'DummyTest')
      result.should eq('DummyTest')
    end
  end

  describe 'Hashes Comparison' do
    it 'should return empty Hash' do
      result = JsonCompare.get_diff({}, {})
      result.should eq({})
    end

    it 'should return empty Hash' do
      json = File.new('spec/fixtures/twitter-search.json', 'r')
      new = old = Yajl::Parser.parse(json)
      result = JsonCompare.get_diff(old, new)
      result.should eq({})
    end

    it 'should return Hash with diff' do
      json1 = File.new('spec/fixtures/twitter-search.json', 'r')
      json2 = File.new('spec/fixtures/twitter-search2.json', 'r')
      old, new = Yajl::Parser.parse(json1), Yajl::Parser.parse(json2)
      result = JsonCompare.get_diff(old, new)
      expected = {
        :update => {
          "results" => {
            :update => {
              0 => {
                :update => {
                  "to_user_id" => "8153091",
                }
              },
              1 => {
                :update => {
                  "from_user" => "AWheeler156",
                }
              }
            }
          }
        }
      }
      result.should eq(expected)
    end
  end

  describe 'Arrays Comparison' do
    it 'should return empty Hash' do
      result =  JsonCompare.get_diff([],[])
      result.should eq({})
    end

    it "should return empty Hash" do
      old = new = [{
        "ID" => "545",
        "Data" => {
          "Something" => [{"Something" => [{}]}]
        }
      }]
      result = JsonCompare.get_diff(old,new)
      result.should eq({})
    end

    it "should return Hash with diffs" do
      old = [{
        "ID" => "545",
        "Data" => {
          "Something" => [{"Something" => [{}]}]
        }
      }]
      new = [{
        "ID" => "546",
        "Data" => {
          "Something2" => [{"Something2" => [{"empty" => nil}]}]
        }
      }]

      result = JsonCompare.get_diff(old,new)
      expected_result = {
        :update => {
          0 => {
            :update => {
              "ID"=>"546",
              "Data" => {
                :append => {
                  "Something2" => [{
                    "Something2" => [{
                      "empty"=>nil
                    }]
                  }]
                }
              }
            }
          }
        }
      }
      result.should eq(expected_result)
    end
  end
end