class UsersController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:following]
  before_action :set_user, only: %i[ show edit update destroy ]

  # GET /users or /users.json
  def index
    @users = User.all
    render json: @users
  end

  # GET /users/1 or /users/1.json
  def show
    render json: @user
  end

  # POST /users/1/following
  def following
    @user = params[:id]
    @operation = following_params[:operation]
    @following = following_params[:following_user_id]

    # Validate presence of required parameters
    if @user.blank? || @following.blank?
      render json: { error: "Missing required parameters" }, status: :bad_request and return
    end
    unless ["follow", "unfollow"].include?(@operation)
      render json: { error: "Invalid operation parameter", operation: @operation }, status: :bad_request and return
    end
    unless User.exists?(@user) && User.exists?(@following)
      render json: { error: "User not found" }, status: :bad_request and return
    end

    # Validate that a user cannot follow/unfollow themselves
    if @user.to_i == @following.to_i
      render json: { error: "A user cannot follow/unfollow themselves" }, status: :bad_request and return
    end

    #Validate that the follow/unfollow operation is idempotent
    if @operation == "follow" && UserFollowing.exists?(user_id: @user, following_user_id: @following)
      render json: { error: "User is already following the specified user", operation: @operation }, status: :bad_request and return
    elsif @operation == "unfollow" && !UserFollowing.exists?(user_id: @user, following_user_id: @following)
      render json: { error: "User is not following the specified user", operation: @operation }, status: :bad_request and return
    end

    # Perform follow/unfollow operation here
    if @operation == "follow"
      UserFollowing.create(user_id: @user, following_user_id: @following)
    elsif @operation == "unfollow"
      UserFollowing.find_by(user_id: @user, following_user_id: @following)&.destroy
    end

    render json: { user: @user, operation: @operation, following: @following }
  end

  # GET /users/new
  def new
    @user = User.new
    render json: {status: "success"}
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users or /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: "User was successfully created." }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1 or /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: "User was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1 or /users/1.json
  def destroy
    @user.destroy!

    respond_to do |format|
      format.html { redirect_to users_path, notice: "User was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.expect(user: [ :name ])
    end

    def following_params
      params.permit(:id, :operation, :following_user_id)
    end
end
