class ActivityChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
    # an o user einai subscribed sto channel, den kanw kati giati mporei na einai px se kapoio home page 
    stream_from 'activity_channel'
    
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    stop_stream_from 'activity_channel'
    # an o user eiani unsubscribed apo to channel, thetw to status se offline giati mporei na exei kleisei to parathyro tou chat h na exei kanei logout
    offline # helper pou orizw parakatw
  end

  def online
    status = User.statuses[:online] # otan kaleitai thetw to status se online
    update_status(status) # kanw broadcast to neo status tou user
  end

  def away
    status = User.statuses[:away] # otan kaleitai thetw to status se away
    update_status(status)  # kanw broadcast to neo status tou user
  end 

  def offline
    status = User.statuses[:offline]  # otan kaleitai thetw to status se offline
    update_status(status)  # kanw broadcast to neo status tou user
  end

  def receive(data)
    ActionCable.server.broadcast('activity_channel', data) # dhmiourgw ena Actioncable broadcast sto activity_channel pou mou epitrepei na anaparagw to broadcast apo user se user
  end

  private

  def update_status(status) #otan kaleitai kanw update to enum status tou current user
    current_user.update!(status: status) # kanei update ton user, o opoios kalei tin after_update_commit 
    # h opoia me th seira ths kanei broadcast replace to icon tou activity status me to updated
  end
end
