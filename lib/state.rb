module State
  def new_state
    session[:state] = SecureRandom.hex(16)
  end

  def stored_state
    session.delete(:state)
  end
end
