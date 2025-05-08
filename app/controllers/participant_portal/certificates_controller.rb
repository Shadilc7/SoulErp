module ParticipantPortal
  class CertificatesController < ParticipantPortal::BaseController
    def index
      @certificates = IndividualCertificate.where(participant: current_participant)
                                         .published
                                         .includes(:certificate_configuration, :assignment)
                                         .order(generated_at: :desc)
                                         .page(params[:page])
    end

    def show
      @certificate = IndividualCertificate.published
                                        .where(participant: current_participant)
                                        .find(params[:id])

      respond_to do |format|
        format.pdf do
          if params[:download]
            send_data @certificate.pdf_content,
                      filename: "#{@certificate.certificate_configuration.name.parameterize}.pdf",
                      type: "application/pdf",
                      disposition: "attachment"
          else
            send_data @certificate.pdf_content,
                      filename: "#{@certificate.certificate_configuration.name.parameterize}.pdf",
                      type: "application/pdf",
                      disposition: "inline"
          end
        end
      end
    end
  end
end
