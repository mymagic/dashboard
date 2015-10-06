module TokenAuthenticationConcern
  extend ActiveSupport::Concern

  included do
    private :authenticate_member_with_token!
    private :fetch_token
    attr_reader :current_member

    before_action :authenticate_member_with_token!
  end

  def fetch_token
    token   = params[:auth_token]
    token ||= request.headers['X-UserSession-Token']
    token ||= request.headers['X_UserSession_Token']
  end

  def authenticate_member_with_token!
    token = fetch_token

    if token.nil?
      raise ::AuthenticationError, I18n.t('authentication.failure.require_token')
    end

    @current_member ||= Member.find_by_auth_token(token)

    unless current_member
      raise ::AuthenticationError, I18n.t('authentication.failure.invalid_token')
    end
  end

end
