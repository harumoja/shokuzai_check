require "rails_helper"

RSpec.describe "StaticPages", type: :request do
  describe "GET /terms" do
    it "利用規約ページが正常に表示されること" do
      get terms_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("利用規約")
    end
  end

  describe "GET /privacy" do
    it "プライバシーポリシーページが正常に表示されること" do
      get privacy_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("プライバシーポリシー")
    end
  end
end
