require 'rails_helper'

RSpec.describe SessionsController, type: :request do
  describe "GET login_path" do
    it "ログイン画面にアクセスできる" do
      get login_path
      expect(response).to have_http_status(:success)
    end
  end
end
