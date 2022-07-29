json.array! @users, partial: "users/user_mention", as: :user 
# go through each one of the users, render the partial and set local var as user