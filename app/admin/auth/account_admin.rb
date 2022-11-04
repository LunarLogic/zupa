Trestle.resource(:account, model: AdminUser, scope: Auth, singular: true) do
  instance do
    current_user
  end

  remove_action :new, :edit, :destroy

  form do |admin_user|
    text_field :email

    row do
      col(sm: 6) { text_field :first_name }
      col(sm: 6) { text_field :last_name }
    end

    row do
      col(sm: 6) { password_field :password }
      col(sm: 6) { password_field :password_confirmation }
    end
  end

  # Limit the parameters that are permitted to be updated by the user
  params do |params|
    params.require(:account).permit(:email, :first_name, :last_name, :password, :password_confirmation)
  end
end
