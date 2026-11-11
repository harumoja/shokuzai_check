# spec/requests/babyfoods_spec.rb

require "rails_helper"

RSpec.describe "Babyfoods", type: :request do
  # 食材を作成する共通メソッド
  def create_ingredient(name:, active: true)
    Ingredient.create!(
      name: name,
      category: "野菜",
      stage: "初期",
      sort_order: 1,
      is_active: active
    )
  end

  # 商品を作成する共通メソッド
  def create_babyfood(name:, ingredients: [], active: true, **attributes)
    Babyfood.create!(
      {
        name: name,
        manufacturer: "テストメーカー",
        stage: "初期",
        is_active: active,
        ingredients: ingredients
      }.merge(attributes)
    )
  end

  describe "GET /babyfoods" do
    it "商品一覧を正常に表示できること" do
      get babyfoods_path

      expect(response).to have_http_status(:ok)
    end

    it "OR検索でいずれかの食材を含む商品を表示すること" do
      carrot = create_ingredient(name: "にんじん")
      potato = create_ingredient(name: "じゃがいも")
      food = create_babyfood(name: "にんじん商品", ingredients: [carrot])

      get babyfoods_path, params: {
        ingredient_ids: [carrot.id, potato.id],
        search_type: "or"
      }

      expect(response.body).to include(food.name)
    end

    it "AND検索で条件を満たさない商品を除外すること" do
      carrot = create_ingredient(name: "にんじん")
      potato = create_ingredient(name: "じゃがいも")
      food = create_babyfood(name: "にんじん商品", ingredients: [carrot])

      get babyfoods_path, params: {
        ingredient_ids: [carrot.id, potato.id],
        search_type: "and"
      }

      expect(response.body).not_to include(food.name)
    end

    it "AND検索で両方の食材を含む商品を表示すること" do
      carrot = create_ingredient(name: "にんじん")
      potato = create_ingredient(name: "じゃがいも")
      food = create_babyfood(name: "野菜ミックス", ingredients: [carrot, potato])

      get babyfoods_path, params: {
        ingredient_ids: [carrot.id, potato.id],
        search_type: "and"
      }

      expect(response.body).to include(food.name)
    end

    it "検索方法が不正な場合はAND検索になること" do
      carrot = create_ingredient(name: "にんじん")
      potato = create_ingredient(name: "じゃがいも")
      food = create_babyfood(name: "にんじん商品", ingredients: [carrot])

      get babyfoods_path, params: {
        ingredient_ids: [carrot.id, potato.id],
        search_type: "unknown"
      }

      expect(response.body).not_to include(food.name)
    end

    it "食材未選択の場合は公開商品を表示すること" do
      food = create_babyfood(name: "公開商品")

      get babyfoods_path

      expect(response.body).to include(food.name)
    end

    it "非公開商品を検索結果に表示しないこと" do
      food = create_babyfood(name: "非公開商品", active: false)

      get babyfoods_path

      expect(response.body).not_to include(food.name)
    end

    it "非公開食材を検索条件から除外すること" do
      ingredient = create_ingredient(name: "非公開テスト食材", active: false)

      get babyfoods_path, params: { ingredient_ids: [ingredient.id] }

      expect(response.body).to include("食材が選択されていないため")
    end

    it "重複した食材IDを1件として扱うこと" do
      carrot = create_ingredient(name: "にんじん")
      create_babyfood(name: "にんじん商品", ingredients: [carrot])

      get babyfoods_path, params: {
        ingredient_ids: [carrot.id, carrot.id]
      }

      expect(
        response.parsed_body.at_css(".babyfood-match-count__total")&.text&.strip
      ).to eq("1")
    end

    it "空文字の食材IDを除外すること" do
      get babyfoods_path, params: { ingredient_ids: [""] }

      expect(response.body).to include("すべての商品を表示しています")
    end

    it "存在しない食材IDを検索条件から除外すること" do
      get babyfoods_path, params: { ingredient_ids: [0] }

      expect(response.body).to include("食材が選択されていないため")
    end

    it "検索結果が0件の場合に案内を表示すること" do
      carrot = create_ingredient(name: "にんじん")

      get babyfoods_path, params: { ingredient_ids: [carrot.id] }

      expect(response.body).to include("条件に一致する商品が見つかりませんでした")
    end

    it "検索結果の該当件数を表示すること" do
      create_babyfood(name: "商品A")
      create_babyfood(name: "商品B")

      get babyfoods_path

      expect(response.body).to include("2件")
    end

    it "一致食材数が多い商品を先に表示すること" do
      carrot = create_ingredient(name: "にんじん")
      potato = create_ingredient(name: "じゃがいも")
      create_babyfood(name: "商品A", ingredients: [carrot])
      create_babyfood(name: "商品B", ingredients: [carrot, potato])

      get babyfoods_path, params: {
        ingredient_ids: [carrot.id, potato.id],
        search_type: "or"
      }

      names = response.parsed_body.css(".babyfood-result-card__name").map(&:text)
      expect(names.map(&:strip)).to eq(["商品B", "商品A"])
    end
  end

  describe "GET /babyfoods/:id" do
    it "公開商品の詳細を正常に表示できること" do
      food = create_babyfood(name: "野菜ミックス")

      get babyfood_path(food)

      expect(response).to have_http_status(:ok)
    end

    it "商品名を表示すること" do
      food = create_babyfood(name: "野菜ミックス")

      get babyfood_path(food)

      expect(response.body).to include(food.name)
    end

    it "原材料を表示すること" do
      carrot = create_ingredient(name: "にんじん")
      food = create_babyfood(name: "野菜ミックス", ingredients: [carrot])

      get babyfood_path(food)

      expect(response.body).to include(carrot.name)
    end

    it "一致した食材を表示すること" do
      carrot = create_ingredient(name: "にんじん")
      food = create_babyfood(name: "野菜ミックス", ingredients: [carrot])

      get babyfood_path(food), params: { ingredient_ids: [carrot.id] }

      expect(
        response.parsed_body.at_css(
          ".babyfood-detail-matched-ingredients"
        )&.text&.strip
      ).to eq("にんじん")
    end

    it "検索条件を戻るリンクに引き継ぐこと" do
      carrot = create_ingredient(name: "にんじん")
      food = create_babyfood(name: "野菜ミックス", ingredients: [carrot])

      params = { ingredient_ids: [carrot.id], search_type: "or" }
      get babyfood_path(food), params: params

      expected_path = babyfoods_path(params)
      href = response.parsed_body.at_css(".babyfood-detail-back-link")["href"]

      expect(href).to eq(expected_path)
    end

    it "非公開商品の詳細は404になること" do
      food = create_babyfood(name: "非公開商品", active: false)

      get babyfood_path(food)

      expect(response).to have_http_status(:not_found)
    end

    it "存在しない商品IDは404になること" do
      get babyfood_path(id: 0)

      expect(response).to have_http_status(:not_found)
    end

    it "購入リンクがない場合は準備中と表示すること" do
      food = create_babyfood(name: "野菜ミックス")

      get babyfood_path(food)

      expect(response.body).to include("購入リンクは準備中です")
    end

    it "Amazonの購入リンクを表示すること" do
      food = create_babyfood(
        name: "野菜ミックス",
        amazon_url: "https://example.com/amazon"
      )

      get babyfood_path(food)

      expect(
        response.parsed_body.at_css(
          "a[href='https://example.com/amazon'][target='_blank']"
        )
      ).not_to be_nil
    end

    it "楽天市場の購入リンクを表示すること" do
      food = create_babyfood(
        name: "野菜ミックス",
        rakuten_url: "https://example.com/rakuten"
      )

      get babyfood_path(food)

      expect(
        response.parsed_body.at_css(
          "a[href='https://example.com/rakuten'][target='_blank']"
        )
      ).not_to be_nil
    end
  end
end
