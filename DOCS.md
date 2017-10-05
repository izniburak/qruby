# QRuby Documentation

sql query builder library for Ruby 

Documentation Page

## Installation

Add this to your application's `Gemfile` and run `gem update` command:

```yaml
gem 'qruby'
```

OR run the following command directly on terminal:

```
gem install qruby
```

## Quick Usage

```ruby
require "qruby"
builder = QRuby::Builder.new

p builder.table("test").where("id", 1).get

# Output:
# "SELECT * FROM test WHERE id = '1' LIMIT 1"
```

# Usage and Methods

Create a new QRuby Object

```ruby
require "qruby"
builder = QRuby::Builder.new
```


> **NOTE**: You must trigger with the **get** or **get_all** methods to execute the queries.

## escape_character

This method is used to set the escape character for your queries.

Default value: "\\\\" (for SQL syntax)

For sql syntax: 
```ruby
QRuby::Builder.escape_character = "\\"
```

For PostgreSQL syntax:
```ruby
QRuby::Builder.escape_character = "'"
```

### table
```ruby
# Usage 1: String Parameter
builder.table("test")

# Output: "SELECT * FROM test"
```
```ruby
# Usage 2: Array Parameter
builder.table(["foo", "bar"])

# Output: "SELECT * FROM foo, bar"
```

### select
```ruby
# Usage 1: String Parameter
builder.table("test").select("id, title, content, tags")

# Output: "SELECT id, title, content, tags FROM test"
```
```ruby
# Usage 2: Array Parameter
builder.table("test").select(["id", "title", "content", "tags"])

# Output: "SELECT id, title, content, tags FROM test"
```

### select functions (min, max, sum, avg, count)
```ruby
# Usage 1:
builder.table("test").max("price")

# Output: "SELECT MAX(price) FROM test"
```
```ruby
# Usage 2:
builder.table("test").count("id", "total_row")

# Output: "SELECT COUNT(id) AS total_row FROM test"
```

### join
```ruby
builder.table("test as t").join("foo as f", "t.id", "f.t_id").where("t.status", 1).get_all

# Output: "SELECT * FROM test as t JOIN foo as f ON t.id = f.t_id WHERE t.status = '1'"
```

You can use this method in 7 ways. These;

- join
- left_join
- right_join
- inner_join
- full_outer_join
- left_outer_join
- right_outer_join

Examples:
```ruby
builder.table("test as t").left_join("foo as f", "t.id", "f.t_id").get_all

# Output: "SELECT * FROM test as t LEFT JOIN foo as f ON t.id = f.t_id"
```

```ruby
builder.table("test as t").full_outer_join("foo as f", "t.id", "f.t_id").get_all

# Output: "SELECT * FROM test as t FULL OUTER JOIN foo as f ON t.id = f.t_id"
```

### where
```ruby
builder.table("test").where("active", 1).get_all

# Output: "SELECT * FROM test WHERE active = '1'"

# OR

builder.table("test").where("age", ">=", 18).get_all

# Output: "SELECT * FROM test WHERE age >= '18'"

# OR

builder.table("test").where("age = ? OR age = ?", [18, 20]).get_all

# Output: "SELECT * FROM test WHERE age = '18' OR age = '20'"
```

You can use this method in 4 ways. These;

- where
- or_where
- not_where
- or_not_where

Example:
```ruby
builder.table("test").where("active", 1).not_where("auth", 1).get_all

# Output: "SELECT * FROM test WHERE active = '1' AND NOT auth = '1'"

# OR

builder.table("test").where("age", 20).or_where("age", '>', 25).get_all

# Output: "SELECT * FROM test WHERE age = '20' OR age > '25'"
```

### in
```ruby
builder.table("test").where("active", 1).in("id", [1, 2, 3]).get_all

# Output: "SELECT * FROM test WHERE active = '1' AND id IN ('1', '2', '3')"
```

You can use this method in 4 ways. These;

- in
- or_in
- not_in
- or_not_in

Example:
```ruby
builder.table("test").where("active", 1).not_in("id", [1, 2, 3]).get_all

# Output: "SELECT * FROM test WHERE active = '1' AND id NOT IN ('1', '2', '3')"

# OR

builder.table("test").where("active", 1).or_in("id", [1, 2, 3]).get_all

# Output: "SELECT * FROM test WHERE active = '1' OR id IN ('1', '2', '3')"
```

### between
```ruby
builder.table("test").where("active", 1).between("age", 18, 25).get_all

# Output: "SELECT * FROM test WHERE active = '1' AND age BETWEEN '18' AND '25'"
```

You can use this method in 4 ways. These;

- between
- or_between
- not_between
- or_not_between

Example:
```ruby
builder.table("test").where("active", 1).not_between("age", 18, 25).get_all

# Output: "SELECT * FROM test WHERE active = '1' AND age NOT BETWEEN '18' AND '25'"

# OR

builder.table("test").where("active", 1).or_between("age", 18, 25).get_all

# Output: "SELECT * FROM test WHERE active = '1' OR age BETWEEN '18' AND '25'"
```

### like
```ruby
builder.table("test").where("active", 1).like("title", "%ruby%").get_all

# Output: "SELECT * FROM test WHERE active = '1' AND title LIKE '%ruby%'"
```

You can use this method in 4 ways. These;

- like
- or_like
- not_like
- or_not_like

Example:
```ruby
builder.table("test").where("active", 1).not_like("tags", "%dot-net%").get_all

# Output: "SELECT * FROM test WHERE active = '1' AND tags NOT LIKE '%dot-net%'"

# OR

builder.table("test").like("bio", "%ruby%").or_like("bio", "%php%").get_all

# Output: "SELECT * FROM test WHERE bio LIKE '%ruby%' OR bio LIKE '%php%'"
```

### group_by
```ruby
# Usage 1: One parameter
builder.table("test").where("status", 1).group_by("cat_id").get_all

# Output: "SELECT * FROM test WHERE status = '1' GROUP BY cat_id"
```

```ruby
# Usage 1: Array parameter
builder.table("test").where("status", 1).group_by(["cat_id", "user_id"]).get_all

# Output: "SELECT * FROM test WHERE status = '1' GROUP BY cat_id, user_id"
```

### having
```ruby
builder.table("test").where("status", 1).group_by("city").having("COUNT(person)", 100).get_all

# Output: "SELECT * FROM test WHERE status = '1' GROUP BY city HAVING COUNT(person) > '100'"

# OR

builder.table("test").where("active", 1).group_by("department_id").having("AVG(salary)", "<=", 500).get_all

# Output: "SELECT * FROM test WHERE active = '1' GROUP BY department_id HAVING AVG(salary) <= '500'"

# OR

builder.table("test").where("active", 1).group_by("department_id").having("AVG(salary) > ? AND MAX(salary) < ?", [250, 1000]).get_all

# Output: "SELECT * FROM test WHERE active = '1' GROUP BY department_id HAVING AVG(salary) > '250' AND MAX(salary) < '1000'"
```

### order_by
```ruby
# Usage 1: One parameter
builder.table("test").where("status", 1).order_by("id").get_all

# Output: "SELECT * FROM test WHERE status = '1' ORDER BY id ASC"

### OR

builder.table("test").where("status", 1).order_by("id desc").get_all

# Output: "SELECT * FROM test WHERE status = '1' ORDER BY id desc"
```

```ruby
# Usage 1: Two parameters
builder.table("test").where("status", 1).order_by("id", "desc").get_all

# Output: "SELECT * FROM test WHERE status = '1' ORDER BY id DESC"
```

```ruby
# Usage 3: Rand()
builder.table("test").where("status", 1).order_by("rand()").limit(10).get_all

# Output: "SELECT * FROM test WHERE status = '1' ORDER BY rand() LIMIT 10"
```

### limit
```ruby
# Usage 1: One parameter
builder.table("test").limit(10).get_all

# Output: "SELECT * FROM test LIMIT 10"
```
```ruby
# Usage 2: Two parameters
builder.table("test").limit(10, 20).get_all

# Output: "SELECT * FROM test LIMIT 10, 20"
```

### get - get_all
```ruby
# 1. get
# Return 1 record.
builder.table("test").get

# Output: "SELECT * FROM test LIMIT 1"
```
```ruby
# 2. get_all
# Return many records.
builder.table("test").get_all

# Output: "SELECT * FROM test"
```

### insert
```ruby
data = {
  "title" => "QRuby",
  "content" => "sql query builder library for Ruby...",
  "tags" => "ruby, query, builder",
  "time" => Time.new(2015, 2, 4),
  "status" => 1
}

builder.table("test").insert(data)

# Output:
# "INSERT INTO test (title, content, tags, time, status) VALUES ('QRuby', 'sql query builder library for Ruby...', 'ruby, query, builder', '2015-02-04 00:00:00 +0200', '1')"
```

### update
```ruby
data = {
  "title" => "Ruby on Rails",
  "content" => "A superb web framework for Ruby.",
  "tags" => "ruby, framework, rails",
  "status" => 1
}

builder.table("test").where("id", 5).update(data)

# Output:
# "UPDATE test SET title = 'Ruby on Rails', content = 'A superb web framework for Ruby.', tags = 'ruby, framework, rails', status = '1' WHERE id = '5'"
```

### delete
```ruby
builder.table("test").where("id", 5).delete

# Output: "DELETE FROM test WHERE id = '5'"

# OR

builder.table("test").delete

# Output: "TRUNCATE TABLE delete"
```

### query
```ruby
builder.query("SELECT id, title, content FROM pages WHERE id = ? AND active = ? ORDER BY updated_at DESC", [10, 1])

# Output: "SELECT id, title, content FROM pages WHERE id = '10' AND active = '1' ORDER BY updated_at DESC"

# OR

builder.query("SELECT * FROM test WHERE title LIKE ? AND status = ? LIMIT 10", ["%Ruby%", 1])

# Output: "SELECT * FROM test WHERE title LIKE '%Ruby%' AND status = '1' LIMIT 10"
```

### analyze
```ruby
builder.table("test").analyze

# Output: "ANALYZE TABLE test"

# OR

builder.table(["foo", "bar", "baz"]).analyze

# Output: "ANALYZE TABLE foo, bar, baz"
```

### check
```ruby
builder.table("test").check

# Output: "CHECK TABLE test"

# OR

builder.table(["foo", "bar", "baz"]).check

# Output: "CHECK TABLE foo, bar, baz"
```

### checksum
```ruby
builder.table("test").checksum

# Output: "CHECKSUM TABLE test"

# OR

builder.table(["foo", "bar", "baz"]).checksum

# Output: "CHECKSUM TABLE foo, bar, baz"
```

### optimize
```ruby
builder.table("test").optimize

# Output: "OPTIMIZE TABLE test"

# OR

builder.table(["foo", "bar", "baz"]).optimize

# Output: "OPTIMIZE TABLE foo, bar, baz"
```

### repair
```ruby
builder.table("test").repair

# Output: "REPAIR TABLE test"

# OR

builder.table(["foo", "bar", "baz"]).repair

# Output: "REPAIR TABLE foo, bar, baz"
```

### last_query
```ruby
builder.table("test").where("active", 1).order_by("id", "desc").limit(10).get_all

# Output: "SELECT * FROM test WHERE active = '1' ORDER BY id DESC LIMIT 10"

builder.last_query

# Output: "SELECT * FROM test WHERE active = '1' ORDER BY id DESC LIMIT 10"
```
