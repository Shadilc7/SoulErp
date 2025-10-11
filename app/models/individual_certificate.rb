class IndividualCertificate < ApplicationRecord
  belongs_to :participant
  belongs_to :assignment
  belongs_to :certificate_configuration
  belongs_to :institute

  # Validations
  validates :generated_at, presence: true, if: :persisted?
  validates :participant_id, uniqueness: { scope: [ :assignment_id, :certificate_configuration_id ],
                                         message: "already has a certificate for this assignment and configuration" }

  # Scopes
  scope :generated, -> { where.not(generated_at: nil) }
  scope :by_institute, ->(institute_id) { where(institute_id: institute_id) }
  scope :by_participant, ->(participant_id) { where(participant_id: participant_id) }
  scope :by_assignment, ->(assignment_id) { where(assignment_id: assignment_id) }
  scope :ordered, -> { order(generated_at: :desc) }
  scope :published, -> { where(published: true) }

  # Callbacks
  before_create :set_generation_timestamp

  # Helper methods
  def generated?
    generated_at.present?
  end

  def pdf_content
    # Use service object for PDF generation
    CertificatePdfGenerator.new(self).generate
  end

  private

  def set_generation_timestamp
    self.generated_at ||= Time.current
  end
end
