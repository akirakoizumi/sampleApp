# frozen_string_literal: true

class Task < ApplicationRecord
  has_one_attached :image

  validates :name, presence: true
  validates :name, length: { maximum: 30 }
  validate :validate_name_not_including_comma
  # before_validation :set_nameless_name

  belongs_to :user

  scope :recent, -> { order(created_at: :desc) }

  def self.ransackable_attributes(_auth_object = nil)
    %w(name created_at)
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end

  def self.csv_attributes
    %w(name description created_at updated_at)
  end

  def self.generate_csv
    CSV.generate(headers: true) do |csv|
      csv << csv_attributes
      all.each do |task|
        csv << csv_attributes.map { |attr| task.send(attr) }
      end
    end
  end

  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      task = new
      task.attributes = row.to_hash.slice(*csv_attributes)
      task.save!
    end
  end

  private

  def validate_name_not_including_comma
    errors.add(:name, 'にカンマを含めることはできません') if name&.include?(',')
  end

  # def set_nameless_name
  #  self.name = '名前無し' if name.blank?
  # end
end
