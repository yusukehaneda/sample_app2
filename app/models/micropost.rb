class Micropost < ApplicationRecord
  belongs_to :user
  has_one_attached :image
  default_scope -> { self.order(created_at: :desc) }
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validates :image,   content_type: { in: %w[image/jpeg image/gif image/png],
                                      message: " must be a valid image format" },
                      size:         { less_than: 1.megabytes,
                                      message: :less_than_xmb }

  # 表示用のリサイズ済み画像を返す
  def display_image
    image.variant(resize_to_limit: [500, 500])
  end

  # 検索機能
  def self.search(keyword)
    if keyword.nil? || keyword.size > 0
      Micropost.where(['content LIKE ?', "%#{keyword}%"])
    else
      return nil
    end
  end

end
