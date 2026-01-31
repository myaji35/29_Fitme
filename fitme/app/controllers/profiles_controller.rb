class ProfilesController < ApplicationController
  before_action :authenticate_user!
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

  def set_profile
    @profile = current_user.profile || current_user.create_profile
  end

  def profile_params
    params.require(:profile).permit(:height_cm, :weight_kg, :avatar_3d_file)
  end
end
