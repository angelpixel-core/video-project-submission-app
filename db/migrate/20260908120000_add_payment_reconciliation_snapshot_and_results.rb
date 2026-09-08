class AddPaymentReconciliationSnapshotAndResults < ActiveRecord::Migration[8.1]
  def change
    add_column :payments, :payment_reconciliation_snapshot, :json

    create_table :payment_reconciliation_results do |t|
      t.references :payment, null: false, foreign_key: true
      t.string :status, null: false
      t.string :result_code
      t.string :expected_status
      t.string :actual_status
      t.string :provider_reference
      t.text :message
      t.json :snapshot, null: false
      t.json :details
      t.datetime :reconciled_at, null: false

      t.timestamps
    end

    add_index :payment_reconciliation_results, %i[payment_id reconciled_at], name: "index_payment_reconciliation_results_on_payment_and_time"
    add_index :payment_reconciliation_results, :status
  end
end
