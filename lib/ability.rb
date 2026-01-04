# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    # 1. Safety Guard: If no user is logged in, no permissions granted
    return unless user

    # 2. Super Admin Override (The "Skydive Pharaohs" Power User)
    # This unlocks SSO, API, Branding, and all "Pro" features for your team.
    if user.email.ends_with?('@mkenterprise-eg.com')
      can :manage, :all
      
      # Explicitly ensure these "Pro" modules are unlocked for the UI
      can :manage, :saml_sso 
      can :manage, EncryptedConfig
    else
      # 3. Standard Staff/User Permissions
      # They can only manage things within their own account scope.
      
      can %i[read create update], Template, Abilities::TemplateConditions.collection(user) do |template|
        Abilities::TemplateConditions.entity(template, user:, ability: 'manage')
      end

      can :destroy, Template, account_id: user.account_id
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
    end
  end
end