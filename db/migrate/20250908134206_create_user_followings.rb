class CreateUserFollowings < ActiveRecord::Migration[8.0]
  def change
    create_table :user_followings do |t|
      t.references :user, null: false, foreign_key: { to_table: :users }
      t.references :following_user, null: false, foreign_key: { to_table: :users }


      add_index :user_followings, [:user_id]
      add_index :user_followings, [:following_user_id]
      t.timestamps
    end
  end
end
