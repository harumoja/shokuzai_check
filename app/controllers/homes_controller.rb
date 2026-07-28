class HomesController < ApplicationController
  def index
    # 有効な食材だけを、検索画面で使用する順番に並べて取得する
    @ingredients = Ingredient.active.display_order
  end
end