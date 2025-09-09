class UsersController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:following, :clock_in, :clock_out]
  before_action :set_user, only: %i[ show clock_in clock_out following ]

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
    new_record = @user.sleep_records.create(clock_in: Time.current)

    if new_record.persisted?
      render json: { message: "Clock-in successful", sleep_record: new_record }, status: :ok
    else
      render json: { error: "Failed to clock in" }, status: :internal_server_error
    end
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

  # POST /users/1/following
  def following
    @operation = following_params[:operation]
    @following = following_params[:following_user_id]

    # Validate presence of required parameters
    if @user.blank? || @following.blank?
      render json: { error: "Missing required parameters" }, status: :bad_request and return
    end
    unless ["follow", "unfollow"].include?(@operation)
      render json: { error: "Invalid operation parameter", operation: @operation }, status: :bad_request and return
    end
    unless @user.present? && User.exists?(@following)
      render json: { error: "User not found" }, status: :bad_request and return
    end

    # Validate that a user cannot follow/unfollow themselves
    if @user.id == @following.to_i
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
