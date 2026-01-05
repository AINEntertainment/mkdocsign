# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Phone verification', type: :system do
  let(:account) { create(:account, :with_testing_account) }
  let(:author) { create(:user, account:) }
  let(:folder) { create(:template_folder, account:) }

  before do
    sign_in(author)
  end

  it 'does not require OTP when template phone 2FA is disabled' do
    template = create(:template, account:, author:, folder:)

    # Ensure preference is explicitly false
    template.preferences = (template.preferences || {}).merge('require_phone_2fa' => false)
    template.save!

    submitter = template.submissions.create!(account_id: account.id, created_by_user: author, name: 'Invite')

    visit start_form_path(template.slug)

    # Fill phone field and submit; should not show verification step
    within 'form' do
      fill_in 'submitter_phone', with: '+15551234567'
      click_button I18n.t('continue') rescue click_button 'Continue'
    end

    expect(page).not_to have_content(I18n.t('verification_required_refresh_the_page_and_pass_2fa'))
  end

  it 'rejects invalid phone numbers even when OTP is disabled' do
    template = create(:template, account:, author:, folder:)

    template.preferences = (template.preferences || {}).merge('require_phone_2fa' => false)
    template.save!

    visit start_form_path(template.slug)

    within 'form' do
      fill_in 'submitter_phone', with: '+1'
      # the JS uses alert(...) on validation error
      accept_alert do
        click_button I18n.t('continue') rescue click_button 'Continue'
      end
    end

    expect(page).to have_current_path(start_form_path(template.slug))
  end
end
