class AddUpdateTypeToUpdates < ActiveRecord::Migration[7.0]
  def change
    # 0: general, 1: offer, 2: event
    add_column :updates, :update_type, :string, default: 'general'
    add_index :updates, :update_type
  end
end
