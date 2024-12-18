module ApplicationHelper
  def bootstrap_class_for(flash_type)
    case flash_type.to_sym
    when :notice
      "alert-success" # 成功提示
    when :alert
      "alert-danger"  # 错误提示
    when :error
      "alert-danger"  # 错误提示
    else
      "alert-info"    # 默认提示
    end
  end
end

