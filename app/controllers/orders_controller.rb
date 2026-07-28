class OrdersController < ProjectsController
  prepend_view_path Rails.root.join("app/views/orders")

  helper_method :projects_path, :project_path, :new_project_path, :edit_project_path, :accept_project_path, :complete_project_path

  def projects_path(*args)
    orders_path(*args)
  end

  def project_path(*args)
    order_path(*args)
  end

  def new_project_path(*args)
    new_order_path(*args)
  end

  def edit_project_path(*args)
    edit_order_path(*args)
  end

  def accept_project_path(*args)
    accept_order_path(*args)
  end

  def complete_project_path(*args)
    complete_order_path(*args)
  end
end
