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
end
