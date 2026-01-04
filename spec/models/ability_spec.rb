# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ability do
  let(:account) { create(:account) }
  let(:template) { create(:template, account: account) }

  context 'admin user' do
    let(:user) { create(:user, account: account, role: User::ADMIN_ROLE) }

    it 'can manage templates and account resources' do
      ability = Ability.new(user)

      expect(ability.can?(:manage, template)).to be true
      expect(ability.can?(:manage, User.new(account: account))).to be true
      expect(ability.can?(:manage, Account.new(id: account.id))).to be true
    end
  end

  context 'editor user' do
    let(:user) { create(:user, account: account, role: User::EDITOR_ROLE) }

    it 'can create and update templates but not manage users or account' do
      ability = Ability.new(user)

      expect(ability.can?(:update, template)).to be true
      expect(ability.can?(:create, TemplateFolder.new(account: account))).to be true
      expect(ability.can?(:destroy, template)).to be false
      expect(ability.can?(:manage, User.new(account: account))).to be false
      # can update own user
      expect(ability.can?(:update, user)).to be true
    end
  end

  context 'viewer user' do
    let(:user) { create(:user, account: account, role: User::VIEWER_ROLE) }

    it 'has read only access to templates and submissions' do
      ability = Ability.new(user)

      expect(ability.can?(:read, template)).to be true
      expect(ability.can?(:update, template)).to be false
      expect(ability.can?(:create, TemplateFolder.new(account: account))).to be false
    end
  end
end
