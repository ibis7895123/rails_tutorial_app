# aaa@sample.com のようなメールアドレスかどうかをチェックする
VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token

  # モデル保存前にメールアドレスを小文字に変換する
  before_save :downcase_email

  # モデル作成前に有効化トークンを作成
  before_create :create_activation_digest

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
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  has_secure_password

  def remember
    @remember_token = User.new_token

    # バリデーションをスルーしてレコードを更新
    update_attribute(:remember_digest, User.digest(@remember_token))
  end

  # 渡されたトークンがダイジェストと一致したらtrueを返す
  def authenticated?(attribute, token)
    # attributeに応じたダイジェストを取得
    digest = self.send("#{attribute}_digest")

    # ダイジェストが空のときはfalseを返す
    return false if digest.nil?

    # トークンとダイジェストを突き合わせて、同じならtrue
    return BCrypt::Password.new(digest).is_password?(token)
  end

  # DBに保存していたユーザーのログイントークンを破棄する
  def forget(user)
    user.update_attribute(:remember_digest, nil)
  end

  # アカウントを有効にする
  def activate
    # 有効化フラグをONにして日付を記録
    self.update_attributes(activated: true, activated_at: Time.zone.now)
  end

  # 有効化用のメールを送信する
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # メールアドレスをすべて小文字にする
  def downcase_email
    self.email = email.downcase
  end
  private :downcase_email

  # 有効化トークンとダイジェストを作成、代入する
  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(self.activation_token)
  end
  private :create_activation_digest

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
