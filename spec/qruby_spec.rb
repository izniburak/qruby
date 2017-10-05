require 'spec_helper'
require './lib/qruby'

describe QRuby::Builder do
  subject { QRuby::Builder.new }

  it "determine the table name" do 
    expect( subject.table('test').get_all ).to eq 'SELECT * FROM test'
    expect( subject.table('test').get ).to eq 'SELECT * FROM test LIMIT 1'
  end

  it "select method" do
    expect( subject.table('test').select(["foo", "bar"]).get_all ).to eq 'SELECT foo, bar FROM test'
    expect( subject.table('test').select("foo, bar, baz").get_all ).to eq 'SELECT foo, bar, baz FROM test'
  end

  it "select functions (max, min, count, sum, avg)" do
    query = subject.table("test").max("price", "maxPrice").get_all
    expect(query).to eq "SELECT MAX(price) AS maxPrice FROM test"

    query = subject.table("test").avg("score").get_all
    expect(query).to eq "SELECT AVG(score) FROM test"
  end

  it "sql join" do
    query = subject.table("test").left_join("foo", "test.id", "foo.page_id").get_all
    expect(query).to eq "SELECT * FROM test LEFT JOIN foo ON test.id = foo.page_id"

    query = subject.table("test").inner_join("foo", "test.id", "foo.cat_id").get_all
    expect(query).to eq "SELECT * FROM test INNER JOIN foo ON test.id = foo.cat_id"
  end
end