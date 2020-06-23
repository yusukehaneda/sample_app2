class User < ApplicationRecord
  has_many :microposts, dependent: :destroy
  #Default: foreign_key: "user_id"
  # => '#{Model Name}s"となるとデフォルトでActiveRelationshipクラスを見に行ってしまうので、明記
  has_many :active_relationships,  class_name: "Relationship",
                                  foreign_key: "follower_id",
                                    dependent: :destroy

  has_many :passive_relationships, class_name: "Relationship",
                                  foreign_key: "followed_id",
                                    dependent: :destroy

  # @user.active_relationships.map(&:followed)をfollowingだけで呼び出したい
  has_many :following,                through: :active_relationships,
                                       source: :followed

  has_many :followers,                through: :passive_relationships,
                                       source: :follower


  attr_accessor :remember_token,
                :activation_token,
                :reset_token

  before_save   :downcase_email
  before_create :create_activation_digest #saveにしてしまうと、ユーザー情報更新のときにも使われてしまう

  #before_save { self.email = email.downcase }
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
    #min costは簡単なハッシュ化 この?(三項演算子)はif..else..の代わりif ActiveModel.. MIN COST..else ..COSTと同じ
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
  def authenticated?(attribute, token)
    digest = self.send("#{attribute}_digest")
    return false if digest.nil? #remember_digestがnilならBcryptを実行しない
    BCrypt::Password.new(digest).is_password?(token)
  end

  # ユーザーのログイン情報を破棄する
  def forget
    self.update_attribute(:remember_digest, nil)
  end

  # アカウントを有効にする
  def activate
    update_attribute(:activated,    true)
    update_attribute(:activated_at, Time.zone.now)
  end

  # 有効化用のメールを送信する
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # パスワード再設定の属性を設定する
  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest,  User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  # パスワード再設定のメールを送信する
  def send_password_reset_email
    # self => #<User:0x00007f376f3cf5c0>
    UserMailer.password_reset(self).deliver_now
  end

  # パスワード再設定の期限が切れている場合はtrueを返す
  # 3.hours.ago < 2.hours.ago 3時間前は有効期限切れ
  #パスワード再設定メールの送信時刻が、現在時刻より2時間以上前（早い）の場合
  def password_reset_expired?
    self.reset_sent_at < 2.hours.ago
  end

  # 試作feedの定義
  # 完全な実装は次章の「ユーザーをフォローする」を参照
  def feed
    following_ids = "SELECT followed_id FROM relationships
                     WHERE follower_id = :user_id"
    Micropost.where("user_id IN (#{following_ids})
                     OR user_id = :user_id", user_id: self.id)
    #Micropost.where("user_id IN (:following_ids) OR user_id = :user_id",
    # following_ids: following_ids, user_id: self.id)
    #Micropost.where("user_id IN (?) OR user_id = ?", following_ids, self.id)
    #Micropost.where("user_id = ?", id)
  end

  # ユーザーをフォローする
  def follow(other_user)
    following << other_user
  end

  # ユーザーをフォロー解除する
  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end

  # 現在のユーザーがフォローしてたらtrueを返す
  def following?(other_user)
    following.include?(other_user)
  end

  def self.search(keyword)
    if keyword.nil? || keyword.size > 0 
      User.where(['name LIKE ?', "%#{keyword}%"])
    else
      return nil
    end
  end


  private

    # メールアドレスをすべて小文字にする
    def downcase_email
      self.email = email.downcase
    end

    # 有効化トークンとダイジェストを作成および代入する
    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
    end


end
