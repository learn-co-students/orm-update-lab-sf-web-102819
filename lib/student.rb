require_relative "../config/environment.rb"


class Student
  attr_accessor :id, :name, :grade

  def initialize(id = nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    sql =  <<-SQL 
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY, 
      name TEXT, 
      grade TEXT
      )
      SQL
  DB[:conn].execute(sql) 
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE students;
      SQL
      DB[:conn].execute(sql)
  end

  def save
    if !@id
      sql = <<-SQL
        INSERT INTO students (name, grade) 
        VALUES (?, ?)
      SQL
      
      DB[:conn].execute(sql, self.name, self.grade)

      self.assign_id
    else
      sql = <<-SQL
        UPDATE students SET name = ?, grade = ?
        WHERE id = ?
      SQL
      DB[:conn].execute(sql, self.name, self.grade, self.id)
    end
    
  end

  def assign_id 
    if @id == nil
      sql = <<-SQL
        SELECT id FROM students
        ORDER BY id DESC
        LIMIT 1
      SQL
      @id = (DB[:conn].execute(sql))[0][0]
    end
  end

  def self.create(name, grade)
    new_student = Student.new(name, grade)
    new_student.save
    new_student
  end

  def self.new_from_db(row)
    new_student = Student.new(row[0], row[1], row[2])
    new_student  
  end

  def self.find_by_name(name)
    sql = <<-SQL
        SELECT *
        FROM students
        WHERE name = ?
        LIMIT 1
      SQL
   
      DB[:conn].execute(sql, name).map {|row| self.new_from_db(row)}.first
  end

  def update
    sql = <<-SQL
        UPDATE students SET name = ?, grade = ?
        WHERE id = ?
      SQL
      DB[:conn].execute(sql, self.name, self.grade, self.id)
  end





end