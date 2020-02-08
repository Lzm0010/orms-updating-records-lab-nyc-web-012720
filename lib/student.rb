require_relative "../config/environment.rb"

class Student
  attr_accessor :id, :name, :grade

  def initialize(id=nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

  ### CLASS METHODS ###

  def self.create_table
    sql = <<-SQL
          CREATE TABLE IF NOT EXISTS students (
            id INTEGER PRIMARY KEY,
            name TEXT,
            grade INTEGER
          );
          SQL

    Student.db_touch(sql)
  end

  def self.drop_table
    sql = <<-SQL
          DROP TABLE students;
          SQL

    Student.db_touch(sql)
  end

  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
  end

  def self.new_from_db(row)
    Student.new(row[0], row[1], row[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
          SELECT * FROM students
          WHERE name = ?
          LIMIT 1;
          SQL

    Student.db_touch(sql, {name: name})
           .map{|row| Student.new_from_db(row)}[0]
  end

  ### INSTANCE METHODS ###

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
            INSERT INTO students (name, grade)
            VALUES (?, ?);
      SQL

      Student.db_touch(sql, {name: self.name, grade: self.grade})

      last_row_sql = "SELECT last_insert_rowid() FROM students;"
      @id = Student.db_touch(last_row_sql)[0][0]
    end
  end

  
  def update
    sql = <<-SQL
        UPDATE students
        SET name = ?, grade = ?
        WHERE id = ?;
        SQL

    Student.db_touch(sql, {name:self.name, grade:self.grade, id:self.id})
  end


  ### HELPER METHODS ###
  def self.db_touch(sql, hash=nil)
    if hash != nil && hash.has_key?(:id)
      DB[:conn].execute(sql, hash[:name], hash[:grade], hash[:id])
    elsif hash != nil && hash.has_key?(:grade)
      DB[:conn].execute(sql, hash[:name], hash[:grade])
    elsif hash != nil && hash.has_key?(:name)
      DB[:conn].execute(sql, hash[:name])
    else
      DB[:conn].execute(sql)
    end
  end

end
