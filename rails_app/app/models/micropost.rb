class Micropost < ApplicationRecord
  belongs_to :user

  # モデル取得時にデフォルトで新着順になるようにする
  default_scope -> { order(created_at: :desc) }

  validates :content, presence: true, length: { maximum: 140 }
  validates :user_id, presence: true
end
