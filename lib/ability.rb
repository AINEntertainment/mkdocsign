# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    # Admins: full control within their account
    if user.role == User::ADMIN_ROLE
      can :manage, :all, account_id: user.account_id
      # limit manage to account-scoped records for clarity
      can :manage, Template, account_id: user.account_id
      can :manage, TemplateFolder, account_id: user.account_id
      can :manage, TemplateSharing, template: { account_id: user.account_id }
      can :manage, Submission, account_id: user.account_id
      can :manage, Submitter, account_id: user.account_id
      can :manage, User, account_id: user.account_id
      can :manage, EncryptedConfig, account_id: user.account_id
      can :manage, EncryptedUserConfig, user_id: user.id
      can :manage, AccountConfig, account_id: user.account_id
      can :manage, UserConfig, user_id: user.id
      can :manage, Account, id: user.account_id
      can :manage, AccessToken, user_id: user.id
      can :manage, WebhookUrl, account_id: user.account_id

    elsif user.role == User::EDITOR_ROLE
      # Editors can create and edit templates, template folders and submissions, but cannot manage users or account settings
      can %i[read create update], Template, Abilities::TemplateConditions.collection(user) do |template|
        Abilities::TemplateConditions.entity(template, user:, ability: 'manage')
      end

      can %i[create update], TemplateFolder, account_id: user.account_id
      can %i[read create update], Submission, account_id: user.account_id
      can %i[read create update], Submitter, account_id: user.account_id
      can %i[create update], TemplateSharing, template: { account_id: user.account_id }

      # Personal settings
      can :manage, EncryptedUserConfig, user_id: user.id
      can :manage, UserConfig, user_id: user.id
      can :update, User, id: user.id

    else
      # Viewers: read-only access to templates and submissions within the account
      can :read, Template, account_id: user.account_id
      can :read, Submission, account_id: user.account_id
      can :read, Submitter, account_id: user.account_id
      can :read, TemplateFolder, account_id: user.account_id
      can :read, TemplateSharing, template: { account_id: user.account_id }
      # Allow viewers to manage their own user config
      can :manage, EncryptedUserConfig, user_id: user.id
      can :manage, UserConfig, user_id: user.id
    end
  end
end
