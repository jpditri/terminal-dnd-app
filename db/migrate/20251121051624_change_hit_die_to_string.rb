class ChangeHitDieToString < ActiveRecord::Migration[7.1]
  def change
    change_column :character_classes, :hit_die, :string
  end
end
