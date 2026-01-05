# frozen_string_literal: true

describe 'Template Preferences' do
  let(:account) { create(:account, :with_testing_account) }
  let(:author) { create(:user, account:) }
  let(:folder) { create(:template_folder, account:) }

  before do
    sign_in(author)
  end

  describe 'POST /templates/:template_id/preferences' do
    it 'saves require_phone_2fa as true' do
      template = create(:template, account:, author:, folder:)

      post template_preferences_path(template), params: { template: { preferences: { require_phone_2fa: 'true' } } }

      expect(response).to have_http_status(:ok)
      expect(template.reload.preferences['require_phone_2fa']).to eq(true)
    end

    it 'saves require_phone_2fa as false' do
      template = create(:template, account:, author:, folder:)

      post template_preferences_path(template), params: { template: { preferences: { require_phone_2fa: 'false' } } }

      expect(response).to have_http_status(:ok)
      expect(template.reload.preferences['require_phone_2fa']).to eq(false)
    end
  end
end
