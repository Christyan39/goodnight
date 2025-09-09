class User < ApplicationRecord
has_many :following, through: :user_followings, source: :user, dependent: :destroy
has_many :followers, through: :user_followings, source: :following_user, dependent: :destroy
has_many :sleep_records, dependent: :destroy
end
