require_relative "../config/environment.rb"

class Student
	attr_accessor :id, :name, :grade
	
	def initialize(name, grade)
		@name = name
		@grade = grade
		@id = nil
	end
	
	def self.create_table
		sql = <<~SQL
					CREATE TABLE IF NOT EXISTS students (
						id INTEGER PRIMARY KEY,
						name TEXT,
						grade TEXT
					)
					SQL
		DB[:conn].execute(sql)
	end
	
	def self.drop_table
		sql = "DROP TABLE IF EXISTS students"
		DB[:conn].execute(sql)
	end
	
	def self.create(name, grade)
		student = self.new(name, grade)
		student.save
	end
	
	def self.new_from_db(row)
		student = self.new(row[1], row[2])
		student.id = row[0]
		student
	end
	
	def self.find_by_name(name)
		sql = "SELECT * from students WHERE name = ? LIMIT 1"
		DB[:conn].execute(sql, name).map {|row| self.new_from_db(row)} [0]
	end
	
	def update
		sql = <<~SQL
					UPDATE students
					SET name = ?, grade = ?
					WHERE id = ?
					SQL
		DB[:conn].execute(sql, self.name, self.grade, self.id)
	end
	
	def save
		if self.id
			self.update
		else
			sql = <<~SQL
						INSERT INTO students (name, grade)
						VALUES (?, ?)
						SQL
			DB[:conn].execute(sql, self.name, self.grade)
			@id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
		end
	end
end