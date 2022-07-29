module UsersHelper
  # xrhsimopoiw ton helper gia na to kanw include kai sto rooms controller sto opoio orizw to @users.
  def user_search
    if params.dig(:username_search).present?  # an exw to username_seach parameter present
      User.all_users_except(current_user) #psaxnw gia users ektos tou current_user
                   .where('username ILIKE ?', "%#{params[:username_search]}%") # kanw match auto pou psaxnw me ta username
                   .order(username: :asc) # h seira pou emfanizw ta results
    else
      []  # otan den psaxnw gia users, emfanizw ena keno pinaka, wste na mhn ginetai search sto database
    end
  end
end
