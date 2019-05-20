class CreateOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :orders do |t|
      t.string :customer_email
      t.references :line_items
      t.timestamps
    end
  end
end
