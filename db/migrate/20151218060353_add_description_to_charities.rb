class AddDescriptionToCharities < ActiveRecord::Migration[4.2]
  def change
    add_column :charities, :description, :text, default: ""
  end
end
