class MemorytestController < ApplicationController
  
  def welcome
    session["init"] = true
    user_count = User.by_name.key(session.id).count
    if user_count == 0
      @current_user = User.new(:name => session.id, :src => "Testing")
      @current_user.save
    else
      @current_user = User.by_name.key(session.id).first
    end
  end
  
  def question
  end
  
  def options
  end
  
  def score 
  end

end
