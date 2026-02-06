class ProfilesController < ApplicationController
  # Development: Skip authentication for demo purposes
  # before_action :authenticate_user!
  before_action :ensure_demo_user
  before_action :set_profile

  def show
  end

  def edit
  end

  def update
    if @profile.update(profile_params)
      # Trigger avatar generation if avatar image was uploaded
      if @profile.avatar_3d_file.attached? && @profile.saved_change_to_attribute?(:avatar_3d_file)
        GenerateAvatarJob.perform_later(@profile.id)
        redirect_to profile_path, notice: "프로필이 업데이트되었습니다. 3D 아바타를 생성 중입니다..."
      else
        redirect_to profile_path, notice: "프로필이 업데이트되었습니다."
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def ensure_demo_user
    unless user_signed_in?
      demo_user = User.find_or_create_by!(email: 'demo@fitme.com') do |user|
        user.password = 'password123'
        user.password_confirmation = 'password123'
      end
      sign_in(demo_user)
    end
  end

  def set_profile
    @profile = current_user.profile || current_user.create_profile

    # Add mock data for demo if profile is empty
    if @profile.height_cm.nil? && @profile.weight_kg.nil?
      @profile.update(
        height_cm: 175,
        weight_kg: 70,
        gender: 'male',
        birth_date: Date.new(1990, 5, 15)
      )
    end
  end

  def profile_params
    params.require(:profile).permit(:height_cm, :weight_kg, :gender, :birth_date, :avatar_3d_file)
  end
end
