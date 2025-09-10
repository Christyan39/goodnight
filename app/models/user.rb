class User < ApplicationRecord
has_many :followings, class_name: 'UserFollowing', foreign_key: :user_id, dependent: :destroy
has_many :followers, class_name: 'UserFollowing', foreign_key: :following_user_id, dependent: :destroy
has_many :sleep_records, dependent: :destroy
end
