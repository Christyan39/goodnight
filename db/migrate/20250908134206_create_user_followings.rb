class CreateUserFollowings < ActiveRecord::Migration[8.0]
  def change
    create_table :user_followings do |t|
      t.references :user, null: false, foreign_key: { to_table: :users }
      t.references :following_user, null: false, foreign_key: { to_table: :users }
      t.timestamps
    end
  end
end
