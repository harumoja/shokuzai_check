class BabyfoodsController < ApplicationController
  def index
    # 有効な商品だけを取得する
    # ingredientsも同時に読み込み、一覧画面から参照できるようにする
    @babyfoods = Babyfood
      .active
      .includes(:ingredients)
      .order(:manufacturer, :name)
  end

  def show
    # URLの:idに対応する、有効な商品を1件取得する
    # 詳細画面で使用する食材も同時に読み込む
    @babyfood = Babyfood
      .active
      .includes(:ingredients)
      .find(params[:id])
  end
end