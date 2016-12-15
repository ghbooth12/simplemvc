require 'sqlite3'

module Simplemvc
  class Mapper
    @@db = SQLite3::Database.new File.join "db", "app.db" # db: folder name
    # If these 3 class variables are provided, this Mapper file can be generic!
    @@table_name = ""
    @@model = nil
    @@mappings = {}

    def save(model)
      @model = model
      if model.id # Update action
        # Create Mapper as a proxy
        @@db.execute(<<-SQL, update_record_values)
          UPDATE #{@@table_name}
          SET #{update_record_placeholders}
          WHERE id = ?
        SQL
      else # Create action
        # ? marks will be replaced with elements in given array.
        @@db.execute "INSERT INTO #{@@table_name} (#{get_columns}) VALUES (#{new_record_placeholders})", new_record_values
      end
    end

    def update_record_placeholders
      columns = @@mappings.keys
      columns.delete(:id)
      columns.map { |col| "#{col}=?" }.join(",")
    end

    def new_record_placeholders
      (["?"] * (@@mappings.size - 1)).join(",") # no need for id. So subtract 1.
    end

    def get_columns
      columns = @@mappings.keys
      columns.delete(:id)
      columns.join(",")
    end

    def get_values
      attributes = @@mappings.values
      attributes.delete(:id)
      attributes.map { |method| self.send(method) }  # self is Mapper's instance. (Mapper.new)
    end

    def update_record_values
      get_values << self.send(:id)
    end

    def new_record_values
      get_values
    end

    # title, body, id are not method. So method_missing will be used when Ruby tries to call "title", "body", "id".
    def method_missing(method, *args)
      @model.send(method)
    end

    def self.findAll
      data = @@db.execute "SELECT #{@@mappings.keys.join(',')} FROM #{@@table_name}"
      data.map do |row|
        self.map_row_to_object(row)
      end
    end

    def self.find(id)
      row = @@db.execute("SELECT #{@@mappings.keys.join(',')} FROM #{@@table_name} WHERE id=?", id).first
      self.map_row_to_object(row)
    end

    def self.map_row_to_object(row)
      model = @@model.new

      @@mappings.each_value.with_index do |attribute, index|
        model.send("#{attribute}=", row[index])
      end

      # ===== above code is equivalent to below: =====
      # model.id = row[0]
      # model.title = row[1]
      # model.body = row[2]
      # model.created_at = row[3]

      model
    end

    def delete(id)
      @@db.execute("DELETE FROM #{@@table_name} WHERE id = ?", id)
    end
  end
end
