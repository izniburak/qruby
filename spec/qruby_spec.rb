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

  it "where conditions" do
    query = subject.table("test").where("status", 1).get_all
    expect(query).to eq "SELECT * FROM test WHERE status = '1'"

    query = subject.table("test").where("status", 1).or_where("status", 2).get_all
    expect(query).to eq "SELECT * FROM test WHERE status = '1' OR status = '2'"

    query = subject.table("test").where("status", 1).not_where("role", 0).get_all
    expect(query).to eq "SELECT * FROM test WHERE status = '1' AND NOT role = '0'"
  end

  it "where in conditions" do
    query = subject.table("test").where("active", 1).in("id", [1, 2, 3]).get_all
    expect(query).to eq "SELECT * FROM test WHERE active = '1' AND id IN ('1', '2', '3')"
  end

  it "where between conditions" do
    query = subject.table("test").where("status", 1).between("age", 18, 30).get_all
    expect(query).to eq "SELECT * FROM test WHERE status = '1' AND age BETWEEN '18' AND '30'"
  end

  it "where like conditions" do
    query = subject.table("test").where("status", 1).like("title", "%ruby%").limit(10).get_all
    expect(query).to eq "SELECT * FROM test WHERE status = '1' AND title LIKE '%ruby%' LIMIT 10"

    query = subject.table("test").where("status", 1).not_like("title", "%php%").get_all
    expect(query).to eq "SELECT * FROM test WHERE status = '1' AND title NOT LIKE '%php%'"
  end

  it "sql group by" do
    query = subject.table("test").where("status", 1).group_by("cat_id").get_all
    expect(query).to eq "SELECT * FROM test WHERE status = '1' GROUP BY cat_id"
  end

  it "sql having" do
    query = subject.table("test").where("status", 1).group_by("city").having("COUNT(person)", 100).get_all
    expect(query).to eq "SELECT * FROM test WHERE status = '1' GROUP BY city HAVING COUNT(person) > '100'"
  end

  it "sql order by" do
    query = subject.table("test").where("active", 1).order_by("created_at").get_all
    expect(query).to eq "SELECT * FROM test WHERE active = '1' ORDER BY created_at ASC"
    
    query = subject.table("test").where("active", 1).order_by("id", "desc").get_all
    expect(query).to eq "SELECT * FROM test WHERE active = '1' ORDER BY id DESC"

    query = subject.table("test").where("active", 1).order_by("rand()").get_all
    expect(query).to eq "SELECT * FROM test WHERE active = '1' ORDER BY rand()"
  end

  it "sql limit" do
    query = subject.table("test").limit(10).get_all
    expect(query).to eq "SELECT * FROM test LIMIT 10"

    query = subject.table("test").limit(10, 20).get_all
    expect(query).to eq "SELECT * FROM test LIMIT 10, 20"
  end

  it "sql delete" do
    query = subject.table("test").where("id", 1).delete
    expect(query).to eq "DELETE FROM test WHERE id = '1'"
  end

  it "truncate table" do
    query = subject.table("test").delete
    expect(query).to eq "TRUNCATE TABLE test"
  end

  it "insert data" do
    time = Time.now
    data = {
      "title"   => "QRuby",
      "content" => "sql query builder library for Ruby...",
      "tags"    => nil,
      "time"    => time,
      "status"  => 1
    }
    query = subject.table("test").insert(data)
    expect(query).to eq "INSERT INTO test (title, content, tags, time, status) VALUES ('QRuby', 'sql query builder library for Ruby...', NULL, '#{time}', '1')"
  end

  it "update data" do
    data = {
      "tags"    => "make, love, with, ruby",
      "status"  => 1
    }
    query = subject.table("test").where("id", 1).update(data)
    expect(query).to eq "UPDATE test SET tags = 'make, love, with, ruby', status = '1' WHERE id = '1'"
  end

  it "sql table maintenance methods" do
    expect( subject.table("test").analyze ).to eq "ANALYZE TABLE test"
    expect( subject.table("test").check ).to eq "CHECK TABLE test"
    expect( subject.table("test").checksum ).to eq "CHECKSUM TABLE test"
    expect( subject.table("test").optimize ).to eq "OPTIMIZE TABLE test"
    expect( subject.table("test").repair ).to eq "REPAIR TABLE test"
  end

  it "drop table" do
    expect( subject.table("test").drop ).to eq "DROP TABLE test"
    # check table(s) exists
    expect( subject.table("test").drop(true) ).to eq "DROP TABLE IF EXISTS test"
  end

  it "sql alter table command" do
    query = subject.table("test").alter("add", "test_column", "varchar(255)")
    expect(query).to eq "ALTER TABLE test ADD test_column varchar(255)"

    query = subject.table("test").alter("modify_column", "test_column", "int NOT NULL")
    expect(query).to eq "ALTER TABLE test MODIFY COLUMN test_column int NOT NULL"

    query = subject.table("test").alter("modify", "test_date", "datetime NOT NULL")
    expect(query).to eq "ALTER TABLE test MODIFY test_date datetime NOT NULL"

    query = subject.table("test").alter("drop_column", "test_column")
    expect(query).to eq "ALTER TABLE test DROP COLUMN test_column"

    query = subject.table("test").alter("drop_index", "index_name")
    expect(query).to eq "ALTER TABLE test DROP INDEX index_name"

    query = subject.table("test").alter("add_constraint", "my_primary_key", "PRIMARY KEY (column1, column2)")
    expect(query).to eq "ALTER TABLE test ADD CONSTRAINT my_primary_key PRIMARY KEY (column1, column2)"
  end

  it "write own query" do
    query = subject.query("SELECT id, title FROM test_table WHERE id = ? AND title = ? ORDER BY id DESC LIMIT 5", [7, "Ruby"])
    expect(query).to eq "SELECT id, title FROM test_table WHERE id = '7' AND title = 'Ruby' ORDER BY id DESC LIMIT 5"
  end
end