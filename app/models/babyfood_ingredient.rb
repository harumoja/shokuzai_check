class BabyfoodIngredient < ApplicationRecord
  belongs_to :babyfood
  belongs_to :ingredient

  validates :ingredient_id,
            uniqueness: {
              scope: :babyfood_id
            }
end