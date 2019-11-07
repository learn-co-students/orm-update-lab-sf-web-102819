require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade, :id

  @@all = []

  def initialize(name, grade, id = nil)
    @name = name
    @grade = grade
    @id = id
    @@all << self
  end

  def self.all
    @@all
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE students (id INTEGER PRIMARY KEY, name TEXT, grade INTEGER)
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE students 
    SQL
    DB[:conn].execute(sql)
  end

  def save
    if self.in_db?
      update
    else
    sql = <<-SQL
      INSERT INTO students (name, grade) VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.grade)
    sql2 = "SELECT id FROM students WHERE name = ?"
    self.id = DB[:conn].execute(sql2, self.name)[0][0]
    Student.all.each do |student| 
      if student.name == self.name
         student.id = self.id
      end
    end
    end
  end

  def in_db?
    new_sql = <<-SQL
    SELECT * FROM students WHERE id = ?
    SQL
   executed = DB[:conn].execute(new_sql, self.id) 
   !executed.empty?
  end

  def self.create(name, grade)
    new_stu = self.new(name, grade)
    new_stu.save
  end

  def self.new_from_db(row)
    Student.new(row[1], row[2], row[0])
  end

  def self.find_by_name(name)
    self.all.find {|student| student.name == name}
  end

  def update 
    sql = <<-SQL
        UPDATE students SET name = ?, grade = ? WHERE id = ?
      SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end
    
end
