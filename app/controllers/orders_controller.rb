class OrdersController < ApplicationController
  include WorkspaceProjectShell

  prepend_view_path Rails.root.join("app/views/orders")
end
