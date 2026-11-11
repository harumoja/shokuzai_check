# spec/requests/homes_spec.rb

require "rails_helper"

RSpec.describe "Homes", type: :request do
  # テスト用の食材を作成する共通メソッド
  def create_ingredient(name:, active: true)
    Ingredient.create!(
      name: name,
      category: "野菜",
      stage: "初期",
      sort_order: 1,
      is_active: active
    )
  end

  describe "GET /" do
    it "トップページを正常に表示できること" do
      get root_path

      expect(response).to have_http_status(:ok)
    end

    it "公開中の食材が表示されること" do
      ingredient = create_ingredient(name: "にんじん")

      get root_path

      expect(response.body).to include(ingredient.name)
    end

    it "非公開の食材が表示されないこと" do
      ingredient = create_ingredient(name: "非公開テスト食材", active: false)

      get root_path

      expect(response.body).not_to include(ingredient.name)
    end

    it "食材のチェックボックスが生成されること" do
      ingredient = create_ingredient(name: "にんじん")

      get root_path

      expect(
        response.parsed_body.at_css(
          "input[type='checkbox'][name='ingredient_ids[]'][value='#{ingredient.id}']"
        )
      ).not_to be_nil
    end

    it "AND検索が初期選択されていること" do
      get root_path

      expect(
        response.parsed_body.at_css("input#search_type_and[checked]")
      ).not_to be_nil
    end

    it "OR検索を選択できること" do
      get root_path

      expect(
        response.parsed_body.at_css("input#search_type_or[value='or']")
      ).not_to be_nil
    end

    it "検索フォームがGET形式で商品一覧に送信されること" do
      get root_path

      expect(
        response.parsed_body.at_css("form[action='#{babyfoods_path}'][method='get']")
      ).not_to be_nil
    end

    it "カテゴリーと離乳食の時期が表示されること" do
      create_ingredient(name: "にんじん")

      get root_path

      expect(response.body).to include("初期（5〜6ヶ月）")
    end
  end
end
