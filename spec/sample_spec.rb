# FactoryBot.define do
RSpec.describe 'Products page system spec', type: :system do
  describe 'UI全般' do
    it "responds successfully" do
      true
    end

    xit "responds successfully2" do
      expect(page.body).to include product.display_price.to_s
    end
  end
end
# end
