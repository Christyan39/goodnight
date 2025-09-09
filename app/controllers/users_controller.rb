class UsersController < ApplicationController
  rescue_from StandardError, with: :internal_error
  rescue_from ActiveRecord::RecordInvalid, with: :bad_request
  skip_before_action :verify_authenticity_token, only: [ :clock_in, :clock_out, :sleep_records, :follow, :unfollow]
  before_action :set_user, only: %i[ show clock_in clock_out sleep_records follow unfollow]
  before_action :set_following_user, only: %i[ follow unfollow ]

  # GET /users or /users.json
  def index
    @users = User.all
    render json: @users
  end

  # GET /users/1 or /users/1.json
  def show
    render json: @user
  end

  #POST /users/1/clock_in
  def clock_in
    # Find the latest sleep record for the user
    latest_record = @user.sleep_records.order(created_at: :desc).first

    if latest_record && latest_record.clock_out.nil?
      render json: { error: "User has already clocked in and not clocked out yet." }, status: :bad_request and return
    end

    # Create a new sleep record with the current time as clock_in
    @user.sleep_records.create(clock_in: Time.current)
    render json: { message: "Clock-in successful", sleep_record: new_record }, status: :ok
  end

  #POST /users/1/clock_out
  def clock_out
    # Find the latest sleep record for the user
    latest_record = @user.sleep_records.order(created_at: :desc).first

    if latest_record && latest_record.clock_out.nil?
      latest_record.update(clock_out: Time.current, duration: ((Time.current - latest_record.clock_in) / 3600.0).round(2))
      render json: { message: "Clock-out successful", sleep_record: latest_record }, status: :ok
    else
      render json: { error: "User has not clocked in yet or has already clocked out." }, status: :bad_request and return
    end
  end

  # POST /users/1/follow
  def follow
    # Validate that a user cannot follow/unfollow themselves
    if @user.id == @following.id
      render json: { error: "A user cannot follow/unfollow themselves" }, status: :bad_request and return
    end

    #Validate that the follow operation is idempotent
    if UserFollowing.exists?(user_id: @user.id, following_user_id: @following.id)
      render json: { error: "User is already following the specified user"}, status: :bad_request and return
    end

    # Perform follow operation here
    UserFollowing.create!(user_id: @user.id, following_user_id: @following.id)
    render json: { message: "Follow successful", user: @user.name, following: @following.name }
  end

  # POST /users/1/unfollow
  def unfollow
    # Validate presence of required parameters
    unless @user.present? && @following.present?
      render json: { error: "User not found" }, status: :bad_request and return
    end

    # Validate that a user cannot follow/unfollow themselves
    if @user.id == @following.id
      render json: { error: "A user cannot follow/unfollow themselves" }, status: :bad_request and return
    end

    user_following = UserFollowing.find_by(user_id: @user.id, following_user_id: @following.id)
    #Validate that the follow/unfollow operation is idempotent
    if user_following.nil?
      render json: { error: "User is not following the specified user", operation: @operation }, status: :bad_request and return
    end

    # Perform follow/unfollow operation here
    user_following&.destroy
    render json: { message: "Unfollow successful", user: @user.name, unfollowed: @following.name }
  end

  # GET /users/1/sleep_records
  def sleep_records
    limit = params[:limit] || 10
    page = params[:page] || 1
    offset = (page.to_i - 1) * limit.to_i
    sleep_records = @user.sleep_records.order(created_at: :desc).limit(limit).offset(offset)
    if sleep_records.present?
      render json: sleep_records, status: :ok
    else
      render json: { error: "No sleep records found" }, status: :not_found
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      begin
        @user = User.find(params.expect(:id))
      rescue ActiveRecord::RecordNotFound
        render json: { error: "User not found" }, status: :not_found
      end
    end
    def set_following_user
      begin
        @following = User.find(params.expect(:following_user_id))
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Following user not found" }, status: :not_found
      end
    end

    # Only allow a list of trusted parameters through.
    def following_params
      params.permit(:following_user_id)
    end

    def internal_error(exception)
      render json: { error: "Internal server error", details: exception.message }, status: :internal_server_error
    end

    def bad_request(exception)
      render json: { error: "Bad request", details: exception.message }, status: :bad_request
    end
  end
