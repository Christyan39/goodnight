class UsersController < ApplicationController
  skip_before_action :authenticate_jwt, only: [:login, :index, :show]
  before_action :set_user, only: %i[ show ]
  before_action :set_following_user, only: %i[ follow unfollow ]

  # public methods
  # POST /login
  def login
    @user = User.find_by(name: params[:name])
    unless @user
      render json: { error: "User not found" }, status: :not_found and return
    end
        
    # Logic for user login
    payload = { user_id: @user.id, exp: 24.hours.from_now.to_i }
    token = JwtServices.encode(payload)
    render json: { token: token }, status: :ok
  end

  # GET /users or /users.json
  def index
    # Find users by name if name param is provided
    limit = params[:limit] || -1
    page = params[:page] || 1
    offset = (page.to_i - 1) * limit.to_i

    if limit.to_i <= 0
      @users = User.where("name ILIKE ?", "%#{params[:name]}%")
    else
      @users = User.where("name ILIKE ?", "%#{params[:name]}%").limit(limit).offset(offset)
    end

    # Pagination metadata
    total_records = User.where("name ILIKE ?", "%#{params[:name]}%").count
    if limit.to_i <= 0
      limit = total_records
    end
    render json: { data: @users, meta: { total: total_records, page: page, per_page: limit } }, status: :ok
  end

  # GET /users/1 or /users/1.json
  def show
    render json: {data: @user}
  end

  # Authenticated actions
  # GET self/profile
  def profile
    render json: {
      data: @current_user,
    }
  end

  # POST /self/clock_in
  def clock_in
    # Find the latest sleep record for the user
    latest_record = @current_user.sleep_records.order(created_at: :desc).first

    if latest_record && latest_record.clock_out.nil?
      render json: { error: "User has already clocked in and not clocked out yet." }, status: :bad_request and return
    end

    # Create a new sleep record with the current time as clock_in
    new_record = @current_user.sleep_records.create(clock_in: Time.current)
    render json: { message: "Clock-in successful", sleep_record: new_record }, status: :ok
  end

  #POST /self/clock_out
  def clock_out
    # Find the latest sleep record for the user
    latest_record = @current_user.sleep_records.order(created_at: :desc).first

    if latest_record && latest_record.clock_out.nil?
      latest_record.update(clock_out: Time.current, duration: ((Time.current - latest_record.clock_in) / 60.0).round(2))
      render json: { message: "Clock-out successful", sleep_record: latest_record }, status: :ok
    else
      render json: { error: "User has not clocked in yet or has already clocked out." }, status: :bad_request and return
    end
  end

  # POST /self/follow
  def follow
    # Validate that a user cannot follow/unfollow themselves
    if @current_user.id == @following.id
      render json: { error: "A user cannot follow/unfollow themselves" }, status: :bad_request and return
    end

    #Validate that the follow operation is idempotent
    if UserFollowing.exists?(user_id: @current_user.id, following_user_id: @following.id)
      render json: { error: "User is already following the specified user"}, status: :bad_request and return
    end

    # Perform follow operation here
    UserFollowing.create!(user_id: @current_user.id, following_user_id: @following.id)
    render json: { message: "Follow successful", user: @current_user.name, following: @following.name }
  end

  # POST /self/unfollow
  def unfollow
    # Validate that a user cannot follow/unfollow themselves
    if @current_user.id == @following.id
      render json: { error: "A user cannot follow/unfollow themselves" }, status: :bad_request and return
    end

    user_following = UserFollowing.find_by(user_id: @current_user.id, following_user_id: @following.id)
    #Validate that the follow/unfollow operation is idempotent
    if user_following.nil?
      render json: { error: "User is not following the specified user", operation: @operation }, status: :bad_request and return
    end

    # Perform follow/unfollow operation here
    user_following&.destroy
    render json: { message: "Unfollow successful", user: @current_user.name, unfollowed: @following.name }
  end

  # GET /self/sleep_records
  def sleep_records
    limit = params[:limit] || -1
    page = params[:page] || 1
    offset = (page.to_i - 1) * limit.to_i

    if limit.to_i <= 0
      sleep_records = @current_user.sleep_records.order(created_at: :desc)
    else
      sleep_records = @current_user.sleep_records.order(created_at: :desc).limit(limit).offset(offset)
    end

    # Pagination metadata
    total_records = @current_user.sleep_records.count
    if limit.to_i <= 0
      limit = total_records
    end
    render json: { sleep_records: sleep_records, meta: { total: total_records, page: page, per_page: limit } }, status: :ok
  end

  #GET /self/followings/sleep_records
  def following_sleep_records
    limit = params[:limit] || -1
    page = params[:page] || 1
    offset = (page.to_i - 1) * limit.to_i 
    max_date =  Time.current - 7.days

    if limit.to_i <= 0
      sleep_records = SleepRecord.select('sleep_records.*, users.*').joins(
        "INNER JOIN user_followings ON sleep_records.user_id = user_followings.following_user_id
         INNER JOIN users ON users.id = sleep_records.user_id       
        "
      ).where(user_followings: { user_id: @current_user.id }).where("sleep_records.created_at >= ?", max_date).order(duration: :desc)
    else
      sleep_records = SleepRecord.select('sleep_records.*, users.*').joins(
        "INNER JOIN user_followings ON sleep_records.user_id = user_followings.following_user_id
         INNER JOIN users ON users.id = sleep_records.user_id       
        "
      ).where(user_followings: { user_id: @current_user.id }).where("sleep_records.created_at >= ?", max_date).order(duration: :desc).limit(limit).offset(offset) 
    end

    # Pagination metadata
    total_records = SleepRecord.joins(
        "INNER JOIN user_followings ON sleep_records.user_id = user_followings.following_user_id
         INNER JOIN users ON users.id = sleep_records.user_id       
        "
      ).where(user_followings: { user_id: @current_user.id }).where("sleep_records.created_at >= ?", max_date).count
    if limit.to_i <= 0
      limit = total_records
    end
    render json: { sleep_records: sleep_records, meta: { total: total_records, page: page, per_page: limit } }, status: :ok
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
  end
