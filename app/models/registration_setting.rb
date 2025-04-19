class RegistrationSetting < ApplicationRecord
  serialize :enabled_institutes, coder: YAML  # Specify YAML as the coder

  validates :enabled_institutes, presence: true

  before_validation :ensure_enabled_institutes

  def self.instance
    first || begin
      # Get all active institute IDs for default value
      default_institutes = Institute.active.pluck(:id)
      create!(enabled_institutes: default_institutes) if default_institutes.any?
    end
  end

  # Helper method to ensure we always work with integers
  def enabled_institute_ids
    (enabled_institutes || []).map(&:to_i)
  end

  private

  def ensure_enabled_institutes
    self.enabled_institutes ||= []
  end
end
