class BabyfoodsController < ApplicationController
  def index
    #受け取った値をrequested_ingredient_idsに入れる
    requested_ingredient_ids = Array(params[:ingredient_ids])
      .reject(&:blank?)
      .map(&:to_i)
      .uniq
 
    @search_type = params[:search_type] == "or" ? "or" : "and"

    #有効な食材を取得する
    @selected_ingredients = Ingredient
      .active
      .where(id: requested_ingredient_ids)
      .display_order
      .to_a #配列にする

    @selected_ingredient_ids = @selected_ingredients.map(&:id)

    #モデルへ検索を依頼する
    babyfoods = Babyfood.search_by_ingredients(
      ingredient_ids: @selected_ingredient_ids,
      search_type: @search_type
    ).to_a

    #モデルに並び替えを依頼する
    @babyfoods =
      if @selected_ingredient_ids.present?
        Babyfood.order_by_matched_ingredients(
          babyfoods,
          @selected_ingredient_ids
        )
      else
        babyfoods
      end
  end

  def show
    @babyfood = Babyfood
      .active
      .includes(:ingredients)
      .find(params[:id])
  end
end