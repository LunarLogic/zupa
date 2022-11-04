Trestle.resource(:admin_users, model: AdminUser, scope: Auth) do
  menu do
    item :admin_users, icon: "fas fa-users", group: :configuration, priority: 110
  end

  table do
    column :avatar, header: false do |admin_user|
      avatar_for(admin_user)
    end
    column :email, link: true
    column :first_name
    column :last_name
    actions do |a|
      a.delete unless a.instance == current_user
    end
  end

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
end
