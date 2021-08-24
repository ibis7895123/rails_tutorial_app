class Micropost < ApplicationRecord
  belongs_to :user

  # モデル取得時にデフォルトで新着順になるようにする
  default_scope -> { order(created_at: :desc) }

  # 画像のアップローダーとの紐付け
  mount_uploader :picture, PictureUploader

  validates :content, presence: true, length: { maximum: 140 }
  validates :user_id, presence: true
end
