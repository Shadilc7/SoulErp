module InstituteAdmin
  class ReportsController < InstituteAdmin::BaseController
    def index
      # Just show the main reports navigation page
    end

    def assignment_reports
      @date_range = params[:date_range]
      @start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : Date.current
      @end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.current
      @section_id = params[:section_id]
      @assignment_id = params[:assignment_id]

      # Always fetch reports for CSV/PDF format, or when filter is applied in HTML format
      if params[:format].in?(['csv', 'pdf']) || (params[:commit].present? && params[:submission_status].present?)
        fetch_assignment_reports
      end

      respond_to do |format|
        format.html
        format.csv { 
          if @submitted_logs.nil? && @not_submitted_participants.nil?
            # Initialize empty collections to prevent nil errors
            @submitted_logs = []
            @not_submitted_participants = []
          end
          send_data generate_assignment_csv, filename: "assignment_report_#{Date.current}.csv" 
        }
        format.pdf {
          if @submitted_logs.nil? && @not_submitted_participants.nil?
            # Initialize empty collections to prevent nil errors
            @submitted_logs = []
            @not_submitted_participants = []
          end
          
          # Render PDF using Prawn or WickedPDF
          render_assignment_report_pdf
        }
      end
    end

    def feedback_reports
      @date_range = params[:date_range]
      @start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : Date.current
      @end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.current
      @section_id = params[:section_id]

      # Always fetch reports for CSV format, or when filter is applied in HTML format
      if params[:format] == 'csv' || (params[:commit].present? && params[:submission_status].present?)
        fetch_feedback_reports
      end

      respond_to do |format|
        format.html
        format.csv { 
          if @submitted_feedbacks.nil? && @not_submitted_participants.nil?
            # Initialize empty collections to prevent nil errors
            @submitted_feedbacks = []
            @not_submitted_participants = []
          end
          send_data generate_feedback_csv, filename: "feedback_report_#{Date.current}.csv" 
        }
      end
    end

    def certificates
      # Handle certificate options page
    end

    private

    def fetch_assignment_reports
      base_query = AssignmentResponseLog.includes(:participant, :assignment, participant: :section)
                                      .where(institute: current_institute)
      
      # Apply date filters
      base_query = case @date_range
                  when 'today'
                    base_query.where(response_date: Date.current)
                  when 'yesterday'
                    base_query.where(response_date: Date.yesterday)
                  when 'last_7_days'
                    base_query.where(response_date: 7.days.ago.beginning_of_day..Time.current)
                  when 'this_month'
                    base_query.where(response_date: Time.current.beginning_of_month..Time.current)
                  when 'custom'
                    base_query.where(response_date: @start_date.beginning_of_day..@end_date.end_of_day)
                  else
                    base_query.where(response_date: Date.current)
                  end

      # Apply section filter if selected
      if @section_id.present? && @section_id != 'all'
        base_query = base_query.joins(participant: :section)
                              .where(sections: { id: @section_id })
      end
      
      # Apply assignment filter if selected
      if @assignment_id.present? && @assignment_id != 'all'
        base_query = base_query.where(assignment_id: @assignment_id)
      end

      @submitted_logs = base_query.order(response_date: :desc)

      # Preload assignment responses for performance
      @assignment_responses = AssignmentResponse.where(id: @submitted_logs.map(&:assignment_response_ids).flatten).index_by(&:id)

      # Get all participants who should have submitted
      all_participants = if @section_id.present? && @section_id != 'all'
                         current_institute.participants.includes(:section).where(section_id: @section_id)
                       else
                         current_institute.participants.includes(:section)
                       end

      # Get participants who haven't submitted
      submitted_participant_ids = @submitted_logs.pluck(:participant_id).uniq
      @not_submitted_participants = all_participants.where.not(id: submitted_participant_ids)

      # For assignment filter in non-submitted participants
      if @assignment_id.present? && @assignment_id != 'all'
        assignment = current_institute.assignments.find(@assignment_id)
        @assignment_title = assignment.title
      end

      # Clear the data that's not needed based on submission status
      if params[:submission_status] == 'submitted'
        @not_submitted_participants = []
      else
        @submitted_logs = []
      end
    end

    def fetch_feedback_reports
      base_query = TrainingProgramFeedback.includes(:participant, :training_program, participant: :section)
                                        .where(training_programs: { institute_id: current_institute.id })

      # Apply date filters
      base_query = case @date_range
                  when 'today'
                    base_query.where(created_at: Date.current.all_day)
                  when 'yesterday'
                    base_query.where(created_at: Date.yesterday.all_day)
                  when 'last_7_days'
                    base_query.where(created_at: 7.days.ago.beginning_of_day..Time.current)
                  when 'this_month'
                    base_query.where(created_at: Time.current.beginning_of_month..Time.current)
                  when 'custom'
                    base_query.where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
                  else
                    base_query.where(created_at: Date.current.all_day)
                  end

      # Apply section filter if selected
      if @section_id.present? && @section_id != 'all'
        base_query = base_query.joins(participant: :section)
                              .where(sections: { id: @section_id })
      end

      @submitted_feedbacks = base_query.order(created_at: :desc)

      # Get all participants who should have submitted feedback
      all_participants = if @section_id.present? && @section_id != 'all'
                         current_institute.participants.includes(:section).where(section_id: @section_id)
                       else
                         current_institute.participants.includes(:section)
                       end

      # Get participants who haven't submitted feedback
      submitted_participant_ids = @submitted_feedbacks.pluck(:participant_id).uniq
      @not_submitted_participants = all_participants.where.not(id: submitted_participant_ids)

      # Clear the data that's not needed based on submission status
      if params[:submission_status] == 'submitted'
        @not_submitted_participants = []
      else
        @submitted_feedbacks = []
      end
    end

    def generate_assignment_csv
      require 'csv'

      CSV.generate(headers: true) do |csv|
        if params[:submission_status] == 'submitted'
          # Generate submitted assignments CSV
          header_row = ['Date', 'Participant', 'Section', 'Responses']
          
          # Add assignment column to the header if no specific assignment is selected
          header_row.insert(3, 'Assignment') if @assignment_id.blank? || @assignment_id == 'all'
          
          csv << header_row
          
          @submitted_logs.each do |log|
            row = [
              log.response_date.strftime("%B %d, %Y"),
              log.participant.full_name,
              log.participant.section.name
            ]
            
            # Add assignment title if no specific assignment is selected
            row << log.assignment.title if @assignment_id.blank? || @assignment_id == 'all'
            
            row << log.assignment_response_ids.size
            
            csv << row
          end
        else
          # Generate not submitted assignments CSV
          header_row = ['Participant', 'Section', 'Email']
          
          # Add assignment column to the header if specific assignment is selected
          header_row << 'Assignment' if @assignment_id.present? && @assignment_id != 'all'
          
          csv << header_row
          
          @not_submitted_participants.each do |participant|
            row = [
              participant.full_name,
              participant.section.name,
              participant.email
            ]
            
            # Add assignment title if specific assignment is selected
            row << @assignment_title if @assignment_id.present? && @assignment_id != 'all'
            
            csv << row
          end
        end
      end
    end

    def generate_feedback_csv
      require 'csv'

      CSV.generate(headers: true) do |csv|
        if params[:submission_status] == 'submitted'
          # Generate submitted feedbacks CSV
          csv << ['Date', 'Participant', 'Section', 'Training Program', 'Rating', 'Content']
          @submitted_feedbacks.each do |feedback|
            csv << [
              feedback.created_at.strftime("%B %d, %Y"),
              feedback.participant.full_name,
              feedback.participant.section.name,
              feedback.training_program.title,
              feedback.rating,
              feedback.content
            ]
          end
        else
          # Generate not submitted feedbacks CSV
          csv << ['Participant', 'Section', 'Email']
          @not_submitted_participants.each do |participant|
            csv << [
              participant.full_name,
              participant.section.name,
              participant.email
            ]
          end
        end
      end
    end

    def render_assignment_report_pdf
      submission_status = params[:submission_status] || 'submitted'
      report_title = submission_status == 'submitted' ? "Submitted Assignments Report" : "Not Submitted Assignments Report"
      
      # Get filter information for the report header
      date_range_text = case @date_range
                        when 'today'
                          "Today (#{Date.current.strftime('%b %d, %Y')})"
                        when 'yesterday'
                          "Yesterday (#{Date.yesterday.strftime('%b %d, %Y')})"
                        when 'last_7_days'
                          "Last 7 Days"
                        when 'this_month'
                          "This Month (#{Date.current.strftime('%B %Y')})"
                        when 'custom'
                          "#{@start_date.strftime('%b %d, %Y')} to #{@end_date.strftime('%b %d, %Y')}"
                        else
                          "All Dates"
                        end
                        
      section_text = if @section_id.present? && @section_id != 'all'
                      section = current_institute.sections.find(@section_id)
                      "Section: #{section.name}"
                    else
                      "All Sections"
                    end
                    
      assignment_text = if @assignment_id.present? && @assignment_id != 'all'
                        assignment = current_institute.assignments.find(@assignment_id)
                        "Assignment: #{assignment.title}"
                      else
                        "All Assignments"
                      end

      # Generate PDF using Prawn directly
      pdf = generate_assignment_pdf(
        report_title: report_title,
        date_range: date_range_text,
        section: section_text,
        assignment: assignment_text,
        institute_name: current_institute.name,
        submission_status: submission_status
      )
      
      # Check if the user wants to download or preview
      disposition = params[:download] == 'true' ? 'attachment' : 'inline'
      
      send_data pdf.render, 
        filename: "assignment_report_#{Date.current.strftime('%Y%m%d')}.pdf",
        type: 'application/pdf',
        disposition: disposition
    end

    def generate_assignment_pdf(options = {})
      require 'prawn'
      require 'prawn/table'
      
      pdf = Prawn::Document.new(
        page_size: 'A4',
        margin: [30, 30, 30, 30],
        info: {
          Title: options[:report_title],
          Author: current_institute.name,
          Subject: 'Assignment Report',
          Creator: 'Soul ERP',
          CreationDate: Time.now
        }
      )
      
      # Add logo if present
      if current_institute.respond_to?(:logo) && 
         current_institute.logo.present? && 
         current_institute.logo.respond_to?(:attached?) && 
         current_institute.logo.attached?
        begin
          logo_path = ActiveStorage::Blob.service.path_for(current_institute.logo.key)
          pdf.image logo_path, position: :center, width: 120
        rescue => e
          # Skip logo if it can't be processed
          Rails.logger.warn "Failed to add logo to PDF: #{e.message}"
        end
      end
      
      # Report header
      pdf.font_size(18) { pdf.text options[:report_title], align: :center, style: :bold }
      pdf.move_down 10
      
      # Institute info
      pdf.font_size(14) { pdf.text options[:institute_name], align: :center, style: :bold }
      pdf.font_size(10) { pdf.text "Generated on #{Date.current.strftime('%B %d, %Y')}", align: :center, color: '666666' }
      pdf.move_down 20
      
      # Filter info
      filter_data = [
        ["Date Range:", options[:date_range]],
        ["Section:", options[:section]],
        ["Assignment:", options[:assignment]]
      ]
      
      pdf.table(filter_data, width: pdf.bounds.width * 0.7, position: :center) do
        cells.borders = []
        column(0).font_style = :bold
        column(0).width = 100
        column(0).align = :right
        column(1).align = :left
        cells.padding = [5, 10]
      end
      
      pdf.move_down 20
      
      # Report data
      if options[:submission_status] == 'submitted'
        if @submitted_logs.any?
          # Table header
          header = ['Date', 'Participant', 'Section']
          
          # Add assignment column if showing all assignments
          header << 'Assignment' if @assignment_id.blank? || @assignment_id == 'all'
          
          header << 'Responses'
          
          # Table data
          data = []
          @submitted_logs.each do |log|
            row = [
              log.response_date.strftime("%b %d, %Y"),
              log.participant.full_name,
              log.participant.section.name
            ]
            
            row << log.assignment.title if @assignment_id.blank? || @assignment_id == 'all'
            
            row << log.assignment_response_ids.size.to_s
            
            data << row
          end
          
          # Generate table
          pdf.table([header] + data, header: true, width: pdf.bounds.width) do
            cells.padding = [8, 10]
            
            row(0).font_style = :bold
            row(0).background_color = 'EEEEEE'
            
            # Zebra striping
            rows(1..data.length).each_with_index do |row, i|
              row.background_color = 'F5F5F5' if i.even?
            end
          end
        else
          pdf.text "No submitted assignments found for the selected criteria.", align: :center, style: :italic, color: '666666'
          pdf.stroke do
            pdf.rectangle [0, pdf.cursor], pdf.bounds.width, 50
          end
        end
      else
        if @not_submitted_participants.any?
          # Table header
          header = ['Participant', 'Section', 'Email']
          
          # Add assignment column if specific assignment is selected
          header << 'Assignment' if @assignment_id.present? && @assignment_id != 'all'
          
          # Table data
          data = []
          @not_submitted_participants.each do |participant|
            row = [
              participant.full_name,
              participant.section.name,
              participant.email
            ]
            
            row << @assignment_title if @assignment_id.present? && @assignment_id != 'all'
            
            data << row
          end
          
          # Generate table
          pdf.table([header] + data, header: true, width: pdf.bounds.width) do
            cells.padding = [8, 10]
            
            row(0).font_style = :bold
            row(0).background_color = 'EEEEEE'
            
            # Zebra striping
            rows(1..data.length).each_with_index do |row, i|
              row.background_color = 'F5F5F5' if i.even?
            end
          end
        else
          pdf.text "No pending submissions found for the selected criteria.", align: :center, style: :italic, color: '666666'
          pdf.stroke do
            pdf.rectangle [0, pdf.cursor], pdf.bounds.width, 50
          end
        end
      end
      
      # Footer
      pdf.number_pages "Page <page> of <total>", 
                       at: [pdf.bounds.right - 150, 0],
                       width: 150,
                       align: :right,
                       size: 9
      
      # Add footer note
      pdf.go_to_page(pdf.page_count)
      pdf.move_down 10
      pdf.horizontal_rule
      pdf.move_down 5
      pdf.text "This is a system generated report.", align: :center, size: 9, color: '666666'
      
      pdf
    end
  end
end 