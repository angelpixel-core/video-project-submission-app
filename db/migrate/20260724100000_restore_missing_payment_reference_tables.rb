class RestoreMissingPaymentReferenceTables < ActiveRecord::Migration[8.1]
  def change
    unless table_exists?(:payment_method_references)
      create_table :payment_method_references do |t|
        t.references :payment, null: false, foreign_key: true, index: false
        t.string :provider, null: false, default: "fake"
        t.string :method_type, null: false
        t.string :reference, null: false
        t.json :metadata

        t.timestamps
      end
    end

    add_index :payment_method_references, :payment_id, unique: true unless index_exists?(:payment_method_references, :payment_id)
    add_index :payment_method_references, :reference, unique: true unless index_exists?(:payment_method_references, :reference)
    add_index :payment_method_references, %i[provider method_type] unless index_exists?(:payment_method_references, %i[provider method_type])

    add_foreign_key :payment_method_references, :payments unless foreign_key_exists?(:payment_method_references, :payments)

    unless table_exists?(:refunds)
      create_table :refunds do |t|
        t.references :payment, null: false, foreign_key: true, index: false
        t.references :payment_method_reference, null: false, foreign_key: true, index: false
        t.string :provider, null: false, default: "fake"
        t.string :provider_reference
        t.string :status, null: false, default: "pending"
        t.integer :amount_cents, null: false, default: 0
        t.text :reason
        t.datetime :processed_at

        t.timestamps
      end
    end

    add_index :refunds, :provider_reference, unique: true unless index_exists?(:refunds, :provider_reference)
    add_index :refunds, %i[payment_id status] unless index_exists?(:refunds, %i[payment_id status])
    add_index :refunds, %i[payment_method_reference_id status] unless index_exists?(:refunds, %i[payment_method_reference_id status])

    add_foreign_key :refunds, :payments unless foreign_key_exists?(:refunds, :payments)
    add_foreign_key :refunds, :payment_method_references unless foreign_key_exists?(:refunds, :payment_method_references)
  end
end
