require_relative "qruby/version"

module QRuby
  class Builder
    @@escape_character = "\\"

    def initialize
      @select = "*"
      @table, @join, @where, @group_by, @having, @order_by, @limit, @last_query = "", "", "", "", "", "", "", ""
      @operators = ["=", "!=", "<", ">", "<=", ">=", "<>"]
    end

    def table(name)
      @table = name.is_a?(Array) ? name.join(", ") : name.to_s
      self
    end

    def select(fields)
      value = fields.is_a?(Array) ? fields.join(", ") : fields.to_s
      @select = (@select<=>"*").eql?(0) ? value : "#{@select}, #{value}"
      self
    end

    ["max", "min", "sum", "count", "avg"].each do |method|
      define_method "#{method}" do |field, name = nil|
        value = "#{method.upcase}(#{field})"
        value += " AS #{name}" if !name.nil?
        @select = (@select<=>"*").eql?(0) ? value : "#{@select}, #{value}"
        self
      end
    end

    def join(table, field1, field2 = nil, type = "")
      @join += field2.nil? ? " #{type}JOIN #{table} ON #{field1}" : " #{type}JOIN #{table} ON #{field1} = #{field2}"
      self
    end

    ["left", "right", "inner", "full_outer", "left_outer", "right_outer"].each do |method|
      define_method "#{method}_join" do |table, field1, field2 = nil|
        join table, field1, field2, "#{method.upcase} "
      end
    end

    def where(field, operator, val = nil, type = "", and_or = "AND")
      if operator.is_a?(Array)
        query = ""
        field.split("?").map.with_index { |val, i| query += i < operator.size ? "#{type}#{val}#{escape(operator[i])}" : "#{val}" }
        where = query
      elsif @operators.include?(operator.to_s)
        where = "#{type}#{field} #{operator} #{escape(val)}"
      else
        where = "#{type}#{field} = #{escape(operator)}"
      end
      @where += @where.empty? ? where : " #{and_or} #{where}"
      self
    end

    ["or", "not", "or_not"].map.with_index do |method, i|
      define_method "#{method}_where" do |field, operator, val = nil|
        where field, operator, val, (i > 0 ? "NOT " : ""), (i == 1 ? "AND" : "OR")
      end
    end

    def in(field, values, type = "", and_or = "AND")
      keys = [] 
      values.each { |val| keys << "#{escape(val)}" }
      @where += @where.empty? ? "#{field} #{type}IN (#{keys.join(", ")})" : " #{and_or} #{field} #{type}IN (#{keys.join(", ")})"
      self
    end

    ["or", "not", "or_not"].map.with_index do |method, i|
      define_method "#{method}_in" do |field, values|
        self.in field, values, (i > 0 ? "NOT " : ""), (i == 1 ? "AND" : "OR")
      end
    end

    def between(field, value1, value2, type = "", and_or = "AND")
      @where += @where.empty? ? "#{field} #{type}BETWEEN #{escape(value1)} AND #{escape(value2)}" : " #{and_or} #{field} #{type}BETWEEN #{escape(value1)} AND #{escape(value2)}"
      self
    end

    ["or", "not", "or_not"].map.with_index do |method, i|
      define_method "#{method}_between" do |field, value1, value2|
        between field, value1, value2, (i > 0 ? "NOT " : ""), (i == 1 ? "AND" : "OR")
      end
    end

    def like(field, value, type = "", and_or = "AND")
      @where += @where.empty? ? "#{field} #{type}LIKE #{escape(value)}" : " #{and_or} #{field} #{type}LIKE #{escape(value)}"
      self
    end

    ["or", "not", "or_not"].map.with_index do |method, i|
      define_method "#{method}_like" do |field, value|
        like field, value, (i > 0 ? "NOT " : ""), (i == 1 ? "AND" : "OR")
      end
    end

    def limit(limit, limit_end = nil)
      @limit = !limit_end.nil? ? "#{limit}, #{limit_end}" : "#{limit}"
      self
    end

    def order_by(field, dir = nil)
      if !dir.nil?
        order_by = "#{field} #{dir.upcase}"
      else
        order_by = (field.include?(" ") || field == "rand()") ? field : "#{field} ASC"
      end
      @order_by += @order_by.empty? ? order_by : ", #{order_by}"
      self
    end

    def group_by(field)
      @group_by = field.is_a?(Array) ? field.join(", ") : field
      self
    end

    def having(field, operator, val = nil)
      if operator.is_a?(Array)
        query = ""
        field.split("?").map.with_index { |val, i| query += i < operator.size ? "#{val}#{escape(operator[i])}" : "#{val}" }
        @having = query
      else
        @having = @operators.include?(operator.to_s) ? "#{field} #{operator} #{escape(val)}" : "#{field} > #{escape(operator)}"
      end
      self
    end

    def get
      @limit = 1
      get_all
    end

    def get_all
      query = "SELECT #{@select} FROM #{@table}"
      query += "#{@join}" if !@join.empty?
      query += " WHERE #{@where}" if !@where.empty?
      query += " GROUP BY #{@group_by}" if !@group_by.empty?
      query += " HAVING #{@having}" if !@having.empty?
      query += " ORDER BY #{@order_by}" if !@order_by.empty?
      query += " LIMIT #{@limit}" if !@limit.to_s.empty?
      end_query query
    end

    def insert(datas)
      fields = datas.keys
      values = [] 
      datas.values.each { |val| values << "#{escape(val)}" }
      query = "INSERT INTO #{@table} (#{fields.join(", ")}) VALUES (#{values.join(", ")})"
      end_query query
    end

    def update(datas)
      query = "UPDATE #{@table} SET"
      fields = datas.keys
      values = [] 
      datas.values.map.with_index { |val, i| values << "#{fields[i]} = #{escape(val)}" }
      query += " #{values.join(", ")}"
      query += " WHERE #{@where}" if !@where.empty?
      query += " ORDER BY #{@order_by}" if !@order_by.empty?
      query += " LIMIT #{@limit}" if !@limit.to_s.empty?
      end_query query
    end

    def delete
      query = "DELETE FROM #{@table}"
      query += " WHERE #{@where}" if !@where.empty?
      query += " ORDER BY #{@order_by}" if !@order_by.empty?
      query += " LIMIT #{@limit}" if !@limit.to_s.empty?
      query = "TRUNCATE TABLE #{@table}" if query == "DELETE FROM #{@table}"
      end_query query
    end

    def drop(check_exists = false)
      query = "DROP TABLE#{check_exists ? " IF EXISTS" : ""} #{@table}"
      end_query query
    end

    def alter(command, column, data_type = "")
      query = "ALTER TABLE #{@table} #{command.gsub('_', ' ').upcase} #{column}"
      query += " #{data_type}" if !data_type.empty?
      end_query query
    end

    def query(sql, params)
      query = ""
      sql.split("?").map.with_index { |val, i| query += i < params.size ? "#{val}#{escape(params[i])}" : "#{val}" }
      end_query query
    end

    ["analyze", "check", "checksum", "optimize", "repair"].each do |method|
      define_method "#{method}" do
        query = "#{method.upcase} TABLE #{@table}"
        end_query query
      end
    end

    def last_query
      @last_query
    end

    def self.escape_character=(character)
      @@escape_character = character
    end

    private 
    
    def reset
      @table, @join, @where, @group_by, @having, @order_by, @limit, @last_query = "", "", "", "", "", "", "", ""
      @select = "*"
    end

    def end_query(query)
      reset
      @last_query = query
      query
    end

    def escape(data)
      return "NULL" if data.nil?
      "'#{data.to_s.gsub(/\\|'/) { |c| @@escape_character + c }}'"
    end
  end
end
