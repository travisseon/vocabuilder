class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email
      t.string :nickname
      t.string :password_digest
      t.integer :total_study_time, default: 0
      t.integer :streak_days, default: 0
      t.date :last_study_date

      t.timestamps
    end
    add_index :users, :email, unique: true
  end
end
