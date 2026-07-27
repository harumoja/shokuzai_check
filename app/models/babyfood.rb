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
end