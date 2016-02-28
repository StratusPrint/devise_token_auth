module DeviseTokenAuth::Concerns::UserOmniauthCallbacks
  extend ActiveSupport::Concern

  included do
    validates :email, presence: true, email: true, if: Proc.new { |u| u.provider == 'email' }
    validates :api_token, presence: true, if: Proc.new { |u| u.provider == 'api_token' }
    validates_presence_of :uid, if: :not_token_or_email?

    # only validate unique emails and api tokens
    validate :unique_token_or_email, on: :create

    # keep uid in sync with email or api_token
    before_save :sync_uid
    before_create :sync_uid
  end

  protected

  def not_token_or_email?
    provider != 'email' && provider != 'api_token'
  end

  def unique_token_or_email
    if provider == 'email' and self.class.where(provider: 'email', email: email).count > 0
      errors.add(:email, I18n.t("errors.messages.already_in_use"))
    elsif provider == 'api_token' and self.class.where(provider: 'api_token', api_token: api_token).count > 0
      errors.add(:api_token, I18n.t("errors.messages.already_in_use"))
    end
  end

  def sync_uid
    self.uid = email if provider == 'email'
    self.uid = api_token if provider == 'api_token'
  end
end
