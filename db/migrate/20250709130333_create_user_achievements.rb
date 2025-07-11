class CreateUserAchievements < ActiveRecord::Migration[8.0]
  def change
    create_table :user_achievements do |t|
      t.references :user, null: false, foreign_key: true
      t.string :achievement_type
      t.text :achievement_data
      t.datetime :achieved_at

      t.timestamps
    end
    
    add_index :user_achievements, [:user_id, :achievement_type]
    add_index :user_achievements, :achievement_type
  end
end
