# aaa@sample.com のようなメールアドレスかどうかをチェックする
VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

class User < ApplicationRecord
  attr_accessor :remember_token

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
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }

  def remember
    @remember_token = User.new_token

    # バリデーションをスルーしてレコードを更新
    update_attribute(:remember_digest, User.digest(@remember_token))
  end

  # 渡された文字列のハッシュ値を返す
  def self.digest(string)
    # 暗号化コスト設定
    cost =
      if ActiveModel::SecurePassword.min_cost
        BCrypt::Engine::MIN_COST
      else
        BCrypt::Engine.cost
      end

    return BCrypt::Password.create(string, cost: cost)
  end

  # ランダムなトークンを返す(22文字)
  def self.new_token
    return SecureRandom.urlsafe_base64
  end
end
