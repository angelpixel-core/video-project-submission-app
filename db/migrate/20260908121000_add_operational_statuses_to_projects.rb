class AddOperationalStatusesToProjects < ActiveRecord::Migration[8.0]
  def change
    add_column :projects, :production_status, :string, null: false, default: "not_started"
    add_column :projects, :delivery_status, :string, null: false, default: "not_ready"
  end
end
