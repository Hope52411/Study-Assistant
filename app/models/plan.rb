class Plan < ApplicationRecord
  belongs_to :user
  validates :name, :description, :start_time, :end_time, presence: true
end
