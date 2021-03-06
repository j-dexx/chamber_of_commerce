class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include MemberSessionsHelper, Optimadmin::AdminSessionsHelper
  helper_method :current_administrator

  before_action :global_site_settings, :load_objects, :current_member
  before_action :aside_content

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render_error 404
  end

  def render_error(status)
    respond_to do |format|
      format.html { render 'errors/404', status: status }
      format.all { render nothing: true, status: status }
    end
  end

  def index
    @presented_articles       = BaseCollectionPresenter.new(collection: Article.non_member_news.limit(10), view_template: view_context, presenter: ArticlePresenter)
    @presented_member_news    = BaseCollectionPresenter.new(collection: Article.member_news.limit(5), view_template: view_context, presenter: ArticlePresenter)
    @presented_events         = BaseCollectionPresenter.new(collection: Event.upcoming.limit(10), view_template: view_context, presenter: EventPresenter)
    @presented_members_offers = BaseCollectionPresenter.new(collection: MemberOffer.includes(:member).current.verified, view_template: view_context, presenter: MemberOfferPresenter)
    @page_types = Page.where(page_type: ["members_services", "international_trade", "patrons", "policy_and_representation"], display: true).group_by(&:page_type)
    @member_news = ArticleCategory.find_by(member_related: true)
    @internal_promotions = InternalPromotionPresenter.new(object: InternalPromotion.where(display: true).order(created_at: :desc), view_template: view_context)
    @magazine = MagazinePresenter.new(object: Magazine.where("date <= ? AND display = ?", Date.today, true).order(date: :desc).first, view_template: view_context)
    @members_services_menu  = Optimadmin::Menu.new(name: "members_services")
  end

  private

    def global_site_settings
      @global_site_settings ||= Optimadmin::SiteSetting.current_environment
    end
    helper_method :global_site_settings

    def aside_content
      @presented_articles       = BaseCollectionPresenter.new(collection: Article.non_member_news.limit(3), view_template: view_context, presenter: ArticlePresenter)
      @presented_member_news    = BaseCollectionPresenter.new(collection: Article.member_news.limit(3), view_template: view_context, presenter: ArticlePresenter)
      @presented_events         = BaseCollectionPresenter.new(collection: Event.upcoming.limit(3), view_template: view_context, presenter: EventPresenter)
      @presented_members_offers = BaseCollectionPresenter.new(collection: MemberOffer.includes(:member).current.verified.limit(5), view_template: view_context, presenter: MemberOfferPresenter)
    end

    def load_objects
      @patrons = BaseCollectionPresenter.new(collection: Patron.display, view_template: view_context, presenter: PatronPresenter)
      @header_menu = Optimadmin::Menu.new(name: "header")
      @footer_menu = Optimadmin::Menu.new(name: "footer")
      @newsletter_signup = NewsletterSignup.new
    end

    def current_member
      auth_token_current_member = MemberLogin.find_by(auth_token: cookies[:member_auth_token]) if cookies.signed[:member_id]
      authenticate_member_session auth_token_current_member if auth_token_current_member
      current_member ||= MemberLogin.find(session[:member_id]) if session[:member_id]
      current_member.member if current_member
    end
    helper_method :current_member

    def members_only
      return if current_member
      session[:return_to] = request.fullpath unless blacklist_redirect_member_session.include?(request.fullpath)
      redirect_to login_member_sessions_url, flash: { error: 'You must be logged into to view this page.' }
    end
end
