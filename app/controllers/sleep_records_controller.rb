class SleepRecordsController < ApplicationController
  before_action :set_sleep_record, only: %i[ show edit update destroy ]

  # GET /sleep_records or /sleep_records.json
  def index
    @sleep_records = SleepRecord.all
  end

  # GET /sleep_records/1 or /sleep_records/1.json
  def show
  end

  # GET /sleep_records/new
  def new
    @sleep_record = SleepRecord.new
  end

  # GET /sleep_records/1/edit
  def edit
  end

  # POST /sleep_records or /sleep_records.json
  def create
    @sleep_record = SleepRecord.new(sleep_record_params)

    respond_to do |format|
      if @sleep_record.save
        format.html { redirect_to @sleep_record, notice: "Sleep record was successfully created." }
        format.json { render :show, status: :created, location: @sleep_record }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @sleep_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sleep_records/1 or /sleep_records/1.json
  def update
    respond_to do |format|
      if @sleep_record.update(sleep_record_params)
        format.html { redirect_to @sleep_record, notice: "Sleep record was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @sleep_record }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @sleep_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sleep_records/1 or /sleep_records/1.json
  def destroy
    @sleep_record.destroy!

    respond_to do |format|
      format.html { redirect_to sleep_records_path, notice: "Sleep record was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sleep_record
      @sleep_record = SleepRecord.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def sleep_record_params
      params.expect(sleep_record: [ :clock_in, :clock_out, :duration ])
    end
end
