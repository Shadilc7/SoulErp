module ApplicationHelper
  def active_link?(controller_name)
    case controller_name
    when "dashboard"
      controller.controller_name == "dashboard"
    when "sections"
      controller.controller_name == "sections"
    when "trainers"
      controller.controller_name == "trainers"
    when "participants"
      controller.controller_name == "participants"
    when "questions"
      controller.controller_name == "questions"
    when "training_programs"
      controller.controller_name == "training_programs"
    else
      false
    end
  end

  def bootstrap_class_for_flash(flash_type)
    case flash_type.to_sym
    when :success
      "success"
    when :error
      "danger"
    when :alert
      "warning"
    when :notice
      "info"
    else
      flash_type.to_s
    end
  end
end
