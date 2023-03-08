class Public::DictionariesController < ApplicationController
  before_action :authenticate_user!, except: [:top]
  def new
    @dictionary = Dictionary.new
    @tag_list = @dictionary.tags.pluck(:tag_name).join('、')
  end

  def create
    @dictionary = Dictionary.new(dictionary_params)
    @dictionary.user_id = current_user.id
    tag_list = params[:dictionary][:tag_name].split('、')
    if @dictionary.save
      @dictionary.save_tag(tag_list)
      redirect_to dictionary_path(@dictionary.id)
    else
      render :new
    end
  end

  def index
    @dictionaries = Dictionary.page(params[:page]).per(8)
    @tags = Tag.all
    if params[:tag_id].present?
      @tag = Tag.find(params[:tag_id])
      @dictionaries = @tag.dictionaries.page(params[:page]).per(8)
      @tag_f = Tag.find(params[:tag_id])
    end
  end

  def show
    @dictionary = Dictionary.find(params[:id])
    if @dictionary.post_status == "closing" && @dictionary.user != current_user
      flash[:notice] = "この辞書は現在非公開となっています。"
      redirect_to dictionaries_path
    end
    @tag_list = @dictionary.tags.pluck(:tag_name).join('、')
    @comment = Comment.new
  end

  def edit
    @dictionary = Dictionary.find(params[:id])
    @tag_list=@dictionary.tags.pluck(:tag_name).join('、')
  end

  def update
    @dictionary = Dictionary.find(params[:id])
    tag_list = params[:dictionary][:tag_name].split('、')
    if @dictionary.update(dictionary_params)
      @old_relations = TagPost.where(dictionary_id:@dictionary.id)
      @old_relations.each do |relations|
        relations.delete
      end
      @dictionary.save_tag(tag_list)
      redirect_to dictionary_path(@dictionary.id)
    else
      render :edit
    end
  end

  def destroy
    @dictionary = Dictionary.find(params[:id])
    @dictionary.destroy
    redirect_to dictionaries_path
  end


  private

  def dictionary_params
    params.require(:dictionary).permit(:image,:title,:summery,:post_status,:dictionary_id)
  end

end
