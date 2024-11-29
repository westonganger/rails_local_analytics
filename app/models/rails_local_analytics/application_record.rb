module RailsLocalAnalytics
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true

    scope :multi_search, ->(full_str){
      if full_str.present?
        relation = self

        full_str.split(' ').each do |str|
          like = connection.adapter_name.downcase.to_s == "postgres" ? "ILIKE" : "LIKE"

          sql_conditions = []

          display_columns.each do |col|
            sql_conditions << "(#{col} #{like} :search)"
          end

          relation = self.where(sql_conditions.join(" OR "), search: "%#{str}%")
        end

        next relation
      end
    }

    def self.display_columns
      column_names - ["id", "created_at", "updated_at", "total", "day"]
    end

    def matches?(other_record)
      day == other_record.day && self.class.display_columns.all?{|col_name| self.send(col_name) == other_record.send(col_name) }
    end

  end
end
