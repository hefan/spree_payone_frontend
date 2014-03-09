class AddPayoneHashToOrders < ActiveRecord::Migration
  def change
    add_column :spree_orders, :payone_hash, :string
  end
end
