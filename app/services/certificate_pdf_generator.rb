# frozen_string_literal: true

# Service object for generating certificate PDFs
# Extracts PDF generation logic from controller to maintain proper MVC separation
class CertificatePdfGenerator
  require "prawn"
  require "prawn/table"
  require "gruff"
  require "tempfile"

  attr_reader :certificate, :participant, :assignment, :config, :institute

  def initialize(certificate)
    @certificate = certificate
    @participant = certificate.participant
    @assignment = certificate.assignment
    @config = certificate.certificate_configuration
    @institute = certificate.institute
  end

  # Main method to generate PDF content
  def generate
    build_pdf
  rescue => e
    Rails.logger.error "Certificate PDF generation failed for certificate ##{certificate.id}: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    nil
  end

  private

  def build_pdf
    # Get intervals and prepare data
    intervals = calculate_intervals
    responses = fetch_responses
    responses_by_date = group_responses_by_date(responses)

    yes_no_questions = assignment.questions.where(question_type: "yes_or_no").select(:id, :title, :question_type)
    number_questions = assignment.questions.where(question_type: "number").select(:id, :title, :question_type)

    # Prepare table data and chart data
    table_data, interval_bars, full_questions, short_labels, interval_names =
      prepare_chart_data(intervals, yes_no_questions, number_questions, responses_by_date)

    # Generate chart
    chart_path = generate_chart(interval_bars, interval_names, short_labels)

    # Build PDF (pass interval_bars for value overlays)
    pdf_content = create_pdf_document(table_data, chart_path, full_questions, interval_names, interval_bars)

    # Cleanup
    File.delete(chart_path) if chart_path && File.exist?(chart_path)

    pdf_content
  end

  def calculate_intervals
    start_date = assignment.start_date.to_date
    end_date = assignment.end_date.to_date

    intervals = []
    current_date = start_date

    while current_date <= end_date
      interval_end = [ current_date + config.duration_period.days - 1, end_date ].min
      intervals << [ current_date, interval_end ]
      current_date = interval_end + 1.day
    end

    intervals
  end

  def fetch_responses
    AssignmentResponse.where(
      participant: participant,
      assignment: assignment
    ).includes(:question)
  end

  def group_responses_by_date(responses)
    responses.group_by { |r| r.response_date.to_date }
  end

  def prepare_chart_data(intervals, yes_no_questions, number_questions, responses_by_date)
    all_questions = yes_no_questions + number_questions
    full_questions = all_questions.map { |q| q.respond_to?(:title) ? q.title : "Question #{q.id}" }
    
    # Create simple, non-overlapping labels - just Q1, Q2, Q3, etc.
    # The full question text is shown in the data table below the chart
    simple_labels = full_questions.map.with_index { |q, i| "Q#{i+1}" }
    
    interval_names = intervals.each_with_index.map { |(_s, _e), idx| "#{(idx+1).ordinalize} #{config.duration_period} Days" }

    # Prepare table header
    header = [ "Question" ] + interval_names + [ "Total" ]
    table_data = [ header ]

    # Prepare interval data
    interval_bars = Array.new(intervals.size) { Array.new(full_questions.size, 0) }
    total_per_question = Array.new(full_questions.size, 0)

    all_questions.each_with_index do |question, q_idx|
      row = [ full_questions[q_idx] ]
      total = 0

      intervals.each_with_index do |(interval_start, interval_end), i_idx|
        value = calculate_interval_value(question, interval_start, interval_end, responses_by_date)
        row << value
        interval_bars[i_idx][q_idx] = value
        total += value
      end

      row << total
      total_per_question[q_idx] = total
      table_data << row
    end

    [ table_data, interval_bars, full_questions, simple_labels, interval_names ]
  end

  def calculate_interval_value(question, interval_start, interval_end, responses_by_date)
    value = 0
    (interval_start..interval_end).each do |date|
      date_responses = responses_by_date[date] || []
      question_responses = date_responses.select { |r| r.question_id == question.id }

      question_responses.each do |response|
        if question.question_type == "yes_or_no"
          value += 1 if response.answer.to_s.downcase == "yes"
        else
          value += response.answer.to_i if response.answer.present?
        end
      end
    end
    value
  end

  def generate_chart(interval_bars, interval_names, simple_labels)
    # Generate chart at higher resolution for crisp PDF rendering
    # More compact size for better fit
    chart_width = 1070   # 535 * 2 for retina quality
    chart_height = 600   # Reduced from 700 for more compact appearance

    g = Gruff::Bar.new("#{chart_width}x#{chart_height}")
    g.title = nil

    g.theme = {
      colors: [
        "#4e73df", "#1cc88a", "#36b9cc", "#f6c23e", "#e74a3b",
        "#6a5acd", "#20b2aa", "#ff6347", "#ffb347", "#4682b4"
      ],
      marker_color: "#CCCCCC",
      background_colors: [ "#ffffff", "#ffffff" ]
    }

    g.hide_legend = false
    g.legend_font_size = 20  # Slightly reduced for compact view
    g.marker_font_size = 22  # Labels on axes
    g.title_font_size = 26   # Slightly reduced
    g.bar_spacing = 0.3      # Thicker bars (reduced spacing)
    g.group_spacing = 20     # More space between question groups
    
    # Remove axis labels as requested
    g.x_axis_label = nil
    g.y_axis_label = nil
    
    g.minimum_value = 0
    g.maximum_value = [ interval_bars.flatten.max, 10 ].max
    
    # Don't show automatic value labels (they show decimals)
    g.hide_line_markers = false

    interval_names.each_with_index do |iname, i_idx|
      g.data(iname, interval_bars[i_idx])
    end

    # Use simple labels (Q1, Q2, etc.) - full questions shown in table below chart
    g.labels = simple_labels.each_with_index.map { |lbl, idx| [ idx, lbl ] }.to_h

    graph_file = Tempfile.new([ "certificate_graph", ".png" ])
    g.write(graph_file.path)
    graph_file.path
  end

  def create_pdf_document(table_data, chart_path, full_questions, interval_names, interval_bars)
    Prawn::Document.new(page_size: "A4", margin: [ 50, 30, 30, 30 ]) do |pdf|
      # Draw border
      pdf.repeat(:all) do
        pdf.stroke_color "888888"
        pdf.line_width = 1.2
        pdf.stroke_rectangle [ pdf.bounds.left, pdf.bounds.top ], pdf.bounds.width, pdf.bounds.height
      end

      # Setup fonts
      setup_fonts(pdf)

      # Header
      add_header(pdf)

      # Participant info (keep together, don't break across pages)
      add_participant_info(pdf)

      # Table (without "Detailed Statistics" header)
      add_data_table(pdf, table_data)

      # Chart (Performance Overview - centered) with value overlays
      add_chart(pdf, chart_path, interval_bars) if chart_path && File.exist?(chart_path)
    end.render
  end

  def setup_fonts(pdf)
    roboto_font_available = true
    font_paths = {
      normal: Rails.root.join("app/assets/fonts/Roboto-Regular.ttf"),
      bold: Rails.root.join("app/assets/fonts/Roboto-Bold.ttf"),
      italic: Rails.root.join("app/assets/fonts/Roboto-Italic.ttf")
    }

    font_paths.each do |style, path|
      unless File.exist?(path)
        Rails.logger.error "Font file not found: #{path}"
        roboto_font_available = false
      end
    end

    if roboto_font_available
      pdf.font_families.update(
        "Roboto" => {
          normal: font_paths[:normal].to_s,
          bold: font_paths[:bold].to_s,
          italic: font_paths[:italic].to_s
        }
      )
      pdf.font "Roboto"
    else
      pdf.font "Helvetica"
    end
  end

  def add_header(pdf)
    pdf.move_down 10

    # Configuration name as main title
    pdf.text config.name, size: 24, style: :bold, align: :center, color: "1a1a1a"
    pdf.move_down 8

    # Configuration details below (if present)
    if config.details.present?
      pdf.text config.details, size: 12, align: :center, color: "555555", leading: 3
    end

    pdf.move_down 20
    pdf.stroke_color "CCCCCC"
    pdf.stroke_horizontal_rule
    pdf.move_down 20
  end

  def add_participant_info(pdf)
    # Compact info section - all content in a table format
    pdf.move_down 5

    # Create a simple table with all participant info
    data = [
      [ "Participant:", participant.user.full_name ],
      [ "Assignment:", assignment.title ],
      [ "Period:", "#{assignment.start_date.strftime('%B %d, %Y')} - #{assignment.end_date.strftime('%B %d, %Y')}" ],
      [ "Generated:", Time.current.strftime("%B %d, %Y at %I:%M %p") ]
    ]

    pdf.table(data,
      width: pdf.bounds.width,
      cell_style: {
        borders: [],
        padding: [ 4, 8 ],
        size: 10
      }
    ) do |table|
      # First column (labels)
      table.column(0).font_style = :bold
      table.column(0).text_color = "444444"
      table.column(0).width = 90

      # Second column (values)
      table.column(1).text_color = "1a1a1a"

      # Make participant name row stand out
      table.row(0).size = 11
      table.row(0).column(1).font_style = :bold
    end

    pdf.move_down 15
  end

  def add_chart(pdf, chart_path, interval_bars)
    # Calculate box dimensions
    box_width = pdf.bounds.width
    box_height = 330  # Height for title + chart + padding (reduced from 350)
    
    # Check if there's enough space on current page, if not start a new page
    if pdf.cursor < box_height
      pdf.start_new_page
    end
    
    # Wrap Performance Overview and chart in a bordered box
    pdf.stroke_color "DDDDDD"
    pdf.line_width = 1
    
    # Store the top position for the box
    box_top = pdf.cursor
    
    # Draw border
    pdf.stroke_rectangle [0, box_top], box_width, box_height
    
    # Content inside the box
    pdf.bounding_box([5, box_top - 5], width: box_width - 10, height: box_height - 10) do
      pdf.text "Performance Overview", size: 14, style: :bold, align: :center
      pdf.move_down 8
      
      # Store the current cursor position before inserting the image
      chart_top = pdf.cursor
      
      # Render chart at more compact size (chart is generated at 2x resolution for clarity)
      # Reduced from 350 to 300 for more compact appearance
      pdf.image chart_path, width: 525, height: 300, position: :center
      
      # Overlay integer value labels on bars
      overlay_bar_values(pdf, interval_bars, chart_top)
    end
    
    # Move cursor to below the box
    pdf.move_down box_height + 15
  end
  
  def overlay_bar_values(pdf, interval_bars, chart_top)
    return if interval_bars.nil? || interval_bars.empty?
    
    # Chart dimensions
    chart_width = 525
    chart_height = 300
    chart_left = (pdf.bounds.width - chart_width) / 2  # Center position
    
    # Calculate the actual plotting area (excluding margins for legend, axis, etc.)
    plot_left = chart_left + 50    # Left margin for Y-axis
    plot_width = chart_width - 150  # Subtract left and right margins
    plot_bottom = chart_top - chart_height + 40  # Bottom margin for X-axis
    plot_height = chart_height - 80  # Subtract top and bottom margins
    
    num_questions = interval_bars[0].length
    num_intervals = interval_bars.length
    
    # Calculate max value for scaling
    max_value = interval_bars.flatten.max.to_f
    max_value = 1.0 if max_value.zero?  # Avoid division by zero
    
    # Bar dimensions
    total_bars = num_questions * num_intervals
    bar_spacing = 0.3
    group_spacing = 20
    
    # Calculate available space for bars
    total_group_spacing = (num_questions - 1) * group_spacing
    bar_section_width = (plot_width - total_group_spacing) / total_bars.to_f
    
    # Position each value label
    interval_bars.each_with_index do |interval_data, interval_idx|
      interval_data.each_with_index do |value, question_idx|
        next if value.zero?  # Don't show "0"
        
        # Calculate bar position
        group_offset = question_idx * group_spacing
        bar_index = question_idx * num_intervals + interval_idx
        bar_x = plot_left + group_offset + (bar_index * bar_section_width) + (bar_section_width / 2)
        
        # Calculate bar height
        bar_height_ratio = value / max_value
        bar_height_px = bar_height_ratio * plot_height
        bar_top = plot_bottom + bar_height_px
        
        # Draw the integer value centered above the bar
        pdf.fill_color "000000"
        pdf.draw_text value.to_i.to_s, 
                      at: [bar_x - 8, bar_top + 5],  # Offset to center text
                      size: 8,
                      style: :bold
      end
    end
    
    # Reset fill color
    pdf.fill_color "000000"
  end

  def add_data_table(pdf, table_data)
    # No header text - just the table
    pdf.move_down 10

    pdf.table(table_data,
      header: true,
      row_colors: [ "F9F9F9", "FFFFFF" ],
      cell_style: {
        borders: [ :top, :bottom, :left, :right ],
        border_width: 0.5,
        border_color: "DDDDDD",
        padding: [ 8, 10 ],
        size: 9
      },
      width: pdf.bounds.width
    ) do |table|
      table.row(0).font_style = :bold
      table.row(0).background_color = "E8E8E8"
      table.row(0).text_color = "1a1a1a"
      table.column(0).width = 180
    end

    pdf.move_down 15
  end
end
