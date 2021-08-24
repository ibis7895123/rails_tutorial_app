class Micropost < ApplicationRecord
  belongs_to :user

  # モデル取得時にデフォルトで新着順になるようにする
  default_scope -> { order(created_at: :desc) }

  # 画像のアップローダーとの紐付け
  mount_uploader :picture, PictureUploader

  validates :content, presence: true, length: { maximum: 140 }
  validates :user_id, presence: true
  validate :picture_size

  # アップロードされた画像のサイズをチェック
  def picture_size
    if picture.size > 5.megabytes
      errors.add(:picture, 'should be less than 5MB')
    end
  end
  private :picture_size
end
