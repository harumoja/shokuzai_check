class BabyfoodIngredient < ApplicationRecord
  belongs_to :babyfood
  belongs_to :ingredient

  validates :raw_name,
            presence: true,
            uniqueness: {
              scope: %i[babyfood_id ingredient_id]
            }

  validates :sort_order,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 0
            }
end
