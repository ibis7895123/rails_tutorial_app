# aaa@sample.com のようなメールアドレスかどうかをチェックする
VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

class User < ApplicationRecord
  # モデル保存前にメールアドレスを小文字に変換する
  before_save { email.downcase! }
  validates :name, presence: true, length: { maximum: 50 }
  validates :email,
            presence: true,
            length: {
              maximum: 255
            },
            format: {
              with: VALID_EMAIL_REGEX
            },
            uniqueness: {
              case_sensitive: false
            }
end
