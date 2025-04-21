class CertificateConfiguration < ApplicationRecord
  belongs_to :institute
  
  # Enum for status to track if configuration is active or inactive
  enum :status, {
    active: 0,
    inactive: 1
  }
  
  # Set default values
  after_initialize :set_default_values, if: :new_record?
  
  # Validations
  validates :name, presence: true
  validates :duration_period, presence: true, numericality: { greater_than: 0 }
  
  # Scopes
  scope :active, -> { where(status: :active) }
  scope :by_institute, -> (institute_id) { where(institute_id: institute_id) }
  
  # Methods
  def formatted_duration
    if duration_period == 1
      "1 month"
    else
      "#{duration_period} months"
    end
  end
  
  private
  
  def set_default_values
    self.status ||= :active
  end
end
