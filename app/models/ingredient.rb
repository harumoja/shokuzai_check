class Ingredient < ApplicationRecord
  # BabyfoodIngredientを経由して、複数のBabyfoodと関連付ける
  has_many :babyfood_ingredients, dependent: :destroy
  has_many :babyfoods, through: :babyfood_ingredients

  # 食材カテゴリーとして登録できる値
  CATEGORIES = [
    "穀類・いも類",
    "野菜",
    "たんぱく質",
    "果物",
    "調味料・その他"
  ].freeze

  # 食材を初めて試せる時期として登録できる値
  STAGES = [
    "初期",
    "中期",
    "後期",
    "完了期"
  ].freeze

  validates :name,
            presence: true,
            uniqueness: true

  validates :category,
            presence: true,
            inclusion: { in: CATEGORIES }

  validates :stage,
            presence: true,
            inclusion: { in: STAGES }

  validates :sort_order,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 0
            }

  validates :is_active,
            inclusion: { in: [true, false] }

  # 検索画面に表示する、有効な食材だけを取得する
  scope :active, -> { where(is_active: true) }

  # カテゴリー・月齢・表示順に並べる
  scope :display_order, lambda {
    order(
      Arel.sql(
        <<~SQL.squish
          CASE category
            WHEN '穀類・いも類' THEN 1
            WHEN '野菜' THEN 2
            WHEN 'たんぱく質食品' THEN 3
            WHEN '果物' THEN 4
            WHEN '調味料・その他' THEN 5
            ELSE 99
          END,
          CASE stage
            WHEN '初期' THEN 1
            WHEN '中期' THEN 2
            WHEN '後期' THEN 3
            WHEN '完了期' THEN 4
            ELSE 99
          END,
          sort_order ASC,
          id ASC
        SQL
      )
    )
  }
end