class GroupsController < ApplicationController

before_action :authenticate_user! , only: [:new, :create, :edit, :update, :destroy]
before_action :find_group_and_check_permission, only: [:edit, :update, :destroy]
  def index
    @groups = Group.all
  end

  def new
    @group = Group.new
  end

  def show
    @group = Group.find(params[:id])
    #@posts = @group.posts.order("created_at DESC")
    @posts = @group.posts.recent.paginate(:page => params[:page], :per_page => 5)
  end

  def create
    @group = Group.new(group_params)
    @group.user = current_user
    if @group.save
      redirect_to groups_path
    else
      render :new
    end
  end

  def edit
    #find_group_and_check_permission
  end

  def update
    #@group = Group.find(params[:id])
    #find_group_and_check_permission

    if @group.update(group_params)
      redirect_to group_path, notice: "Group has been updated successfully."
    else
      render :edit
    end
  end

  def destroy
    #@group = Group.find(params[:id])
    #find_group_and_check_permission

    @group.destroy
    flash[:alert] = "Group has been deleted."
    redirect_to groups_path
  end

  def join
    @group = Group.find(params[:id])

    if !current_user.is_member_of?(@group)
      current_user.join!(@group)
      flash[:notice] = "You've joined this group"
    end

    redirect_to group_path(@group)
  end

  def quit
    @group = Group.find(params[:id])

    if current_user.is_member_of?(@group)
      current_user.quit!(@group)
      flash[:alert] = "You've quit this group"
    else
      flash[:warning] = "You are not in this group"
    end

    redirect_to group_path(@group)
  end

  private

  def group_params
    params.require(:group).permit(:title, :description)
  end

  def find_group_and_check_permission

    @group = Group.find(params[:id])
    if current_user != @group.user
      redirect_to root_path, alert: "you have no permission"
    end
  end
end
