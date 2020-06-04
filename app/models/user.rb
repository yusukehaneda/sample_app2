class User < ApplicationRecord

  attr_accessor :remember_token

  before_save { self.email = email.downcase }
  #右辺のselfを省略している before_save { self.email = self.email.downcase }
  validates :name,  presence: true, 
                      length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, 
                      length: { maximum: 255 },
                      format: { with: VALID_EMAIL_REGEX },
                      uniqueness: true
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  # 渡された文字列のハッシュ値を返す(test用 リスト8.23)
  def User.digest(string)
    #min costは簡単なハッシュ化 この?(三項演算子)はif..else..の代わりif ActiveModel.. MIN COST..else ..COSと同じ
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # ランダムなトークンを返す(リスト9.2)
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # 永続セッションのためにユーザーをデータベースに記憶する
  def remember
    self.remember_token = User.new_token
    self.update_attribute(:remember_digest, User.digest(remember_token))
  end

  # 渡されたトークンがダイジェストと一致したらtrueを返す
  def authenticated?(remember_token)
    return false if remember_digest.nil? #remember_digestがnilならBcryptを実行しない
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # ユーザーのログイン情報を破棄する
  def forget
    self.update_attribute(:remember_digest, nil)
  end

end
