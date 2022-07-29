module ApplicationCable
  class Connection < ActionCable::Connection::Base
    # Connection Setup apo ton edge guide gia to actioncable
    # gia na mporw na xrhsimopoihsw ton current_user sto channel mou

    identified_by :current_user # to actioncable den exei access ston devise user by default

    def connect
      self.current_user = find_verified_user
    end
  

    private

    def find_verified_user
      if verified_user = env['warden'].user # warden helper pou vriskei ton user
        verified_user
      else 
        reject_unauthorized_connection
      end
    end
  end
end
