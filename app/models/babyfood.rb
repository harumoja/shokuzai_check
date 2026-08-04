class Babyfood < ApplicationRecord
  has_many :babyfood_ingredients, dependent: :destroy
  has_many :ingredients, through: :babyfood_ingredients

  STAGES = Ingredient::STAGES

  validates :name,
            presence: true,
            uniqueness: {
              scope: :manufacturer
            }

  validates :manufacturer,
            presence: true

  validates :stage,
            presence: true,
            inclusion: { in: STAGES }

  validates :image_url,
            format: {
              with: URI::DEFAULT_PARSER.make_regexp(%w[http https]),
              allow_blank: true
            }

  validates :amazon_url,
            format: {
              with: URI::DEFAULT_PARSER.make_regexp(%w[http https]),
              allow_blank: true
            }

  validates :rakuten_url,
            format: {
              with: URI::DEFAULT_PARSER.make_regexp(%w[http https]),
              allow_blank: true
            }

  validates :is_active,
            inclusion: { in: [true, false] }

  scope :active, -> { where(is_active: true) }

  # 選択した食材のうち、1つ以上を含む商品を取得する
  scope :containing_any_ingredients, lambda { |ingredient_ids|
    where(
      id: BabyfoodIngredient
        .where(ingredient_id: ingredient_ids)
        .select(:babyfood_id)
    )
  }

  # 選択した食材を、すべて含む商品を取得する
  scope :containing_all_ingredients, lambda { |ingredient_ids|
    where(
      id: BabyfoodIngredient
        .where(ingredient_id: ingredient_ids)
        .group(:babyfood_id)
        .having(
          "COUNT(DISTINCT ingredient_id) = ?",
          ingredient_ids.size
        )
        .select(:babyfood_id)
    )
  }

  # 検索方法に応じて、AND検索またはOR検索を行う
  def self.search_by_ingredients(ingredient_ids:, search_type:)
    return active.order(:manufacturer, :name) if ingredient_ids.blank?

    results =
      if search_type == "or"
        active.containing_any_ingredients(ingredient_ids)
      else
        active.containing_all_ingredients(ingredient_ids)
      end

    results.includes(:ingredients)
  end

  # 検索結果を、一致した食材数が多い順に並べる
  #
  # 同じ一致数の場合は、
  # 1. メーカー名
  # 2. 商品名
  # の順に並べる
  def self.order_by_matched_ingredients(babyfoods, ingredient_ids)
    babyfoods.sort_by do |babyfood|
      matched_count = babyfood.matched_ingredients_count(ingredient_ids)

      [
        -matched_count,
        babyfood.manufacturer.to_s,
        babyfood.name.to_s
      ]
    end
  end

  # この商品に含まれる食材のうち、
  # 選択された食材と一致する件数を返す
  def matched_ingredients_count(ingredient_ids)
    ingredients.count do |ingredient|
      ingredient_ids.include?(ingredient.id)
    end
  end
end