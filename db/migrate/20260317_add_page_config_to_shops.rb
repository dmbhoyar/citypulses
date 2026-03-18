class AddPageConfigToShops < ActiveRecord::Migration[8.1]
  def change
    # Use :json for MySQL compatibility (MySQL does not support jsonb)
    # MySQL does not allow default values on JSON columns, so create nullable column
    add_column :shops, :page_config, :json, null: true
  end
end
