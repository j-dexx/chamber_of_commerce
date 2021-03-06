module Optimadmin
  class ArticlesController < Optimadmin::ApplicationController

    edit_images_for Article, [[:image, { index: ['fill', 250, 250], show: ['fill', 215, 135], show_full_image: ['fit', 613, 9999], homepage: ['fill', 450, 295] }]]
    before_action :set_article, only: [:show, :edit, :update, :destroy]

    def index
      @articles = Optimadmin::BaseCollectionPresenter.new(collection: Article.where('title ILIKE ?', "%#{params[:search]}%").page(params[:page]).per(params[:per_page] || 15).order(params[:order] || "date desc"), view_template: view_context, presenter: Optimadmin::ArticlePresenter)
    end

    def show
    end

    def new
      @article = Article.new
    end

    def edit
    end

    def create
      @article = Article.new(article_params)
      if @article.save
        redirect_to_index_or_continue_editing(@article)
      else
        render :new
      end
    end

    def update
      if @article.update(article_params)
        redirect_to_index_or_continue_editing(@article)
      else
        render :edit
      end
    end

    def destroy
      @article.destroy
      redirect_to articles_url, notice: 'Article was successfully destroyed.'
    end

  private


    def set_article
      @article = Article.find(params[:id])
    end

    def article_params
      params.require(:article).permit(:title, :article_category_id, :summary, :content, :image, :image_cache, :remove_image, :remote_image_url, :date, :display,  :layout, :caption, :suggested_url)
    end
  end
end
