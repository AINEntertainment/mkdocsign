# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    # 1. Safety Guard
    return unless user

    # 2. Skydive Pharaohs Admin Override
    # This unlocks the "Pro" menus like SSO, SMTP, and White-labeling globally.
    if user.email.ends_with?('@mkenterprise-eg.com')
      can :manage, :all
      
      # Explicitly grant access to the "Pro" modules you want to use
      can :manage, :saml_sso 
      can :manage, EncryptedConfig
    else
      # 3. Standard User Permissions (Original Docuseal Logic)
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