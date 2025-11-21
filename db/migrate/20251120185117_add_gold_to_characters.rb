class AddGoldToCharacters < ActiveRecord::Migration[7.1]
  def change
    add_column :characters, :gold, :integer, default: 0, null: false
  end
end
