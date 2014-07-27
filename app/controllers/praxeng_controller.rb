class PraxengController < ApplicationController
  layout 'praxeng'
  skip_before_filter  :verify_authenticity_token
  def firstPage
    
    session["init"] = true
    @referer = request.env['HTTP_REFERER']
    @ip_address = request.remote_ip

    
    @question_num = 1
    @num_correct = 0
    @message = "How good are your English comprehension skills? Take the test and find out now. It's free!"
    @session_id = session.id
    @current_question = getFirstQuestion(session.id)
    @question_id = @current_question.id
    @current_sentence = getSentence(@current_question)
    
    if returningUser(session.id) == true
      render "secondPage"
    end
    
  end
  
  def secondPage
    user = nil
    @question_num = nil
    @num_correct = params[:num_correct]
    session["init"] = true
    if returningUser(session.id) == true
      user = getUser(session.id)
    else
      user = newUser(session.id, params[:referer], params[:ip_address])
    end
    annotation = newAnnotation(user, params[:question_id], params[:none], params[:response])
    @question = Question.get(params[:question_id])
    correct = checkAnnotation(@question, annotation) 
    @message = nil
    if correct == 0
      @message = computeCustomMessage(@question, annotation)
    elsif correct == 1
      @num_correct = params[:num_correct].to_i + 1
      @message = "Correct answer! You are doing great!" 
    elsif correct == 2
      @num_correct = params[:num_correct].to_i + 1
      @message = "You are the first person to answer this question. Thanks!"    
    elsif correct == -1
      @message = "Learn something new today! Check out the correct answer."
    end
    
    @user_resp = userResponse(annotation)
    
    
    allAnnotations = Annotation.by_question_id.key(@question.id)
    @annotation_count = allAnnotations.count
    @crowd_votes = countVotes(@question, allAnnotations)
    
    
    @question_num  = params[:question_num].to_i + 1
  
    @session_id = session.id
    @current_question = getFirstQuestion(session.id)
    @current_sentence = getSentence(@current_question)
    @question_id = @current_question.id
  end
  
  def thirdPage
    user = nil
    @question_num = nil
    @num_correct = params[:num_correct]
    session["init"] = true
    if returningUser(session.id) == true
      user = getUser(session.id)
    else
      user = newUser(session.id, params[:referer], params[:ip_address])
    end
    annotation = newAnnotation(user, params[:question_id], params[:none], params[:response])
    @question = Question.get(params[:question_id])
    correct = checkAnnotation(@question, annotation) 
    @message = nil
    if correct == 0
       @num_correct = params[:num_correct].to_i + 1
      @message = computeCustomMessage(@question, annotation)
    elsif correct == 1
      @num_correct = params[:num_correct].to_i + 1
      @message = "Correct answer! You are doing great!" 
    elsif correct == 2
      @num_correct = params[:num_correct].to_i + 1
      @message = "You are the first person to answer this question. Thanks!"    
    elsif correct == -1
      @message = "Learn something new today! Check out the correct answer."
    end
    
    @user_resp = userResponse(annotation)
    
    
    allAnnotations = Annotation.by_question_id.key(@question.id)
    @annotation_count = allAnnotations.count
    @crowd_votes = countVotes(@question, allAnnotations)
    
    
    @question_num  = params[:question_num].to_i + 1
  
    @session_id = session.id
    @current_question = getFirstQuestion(session.id)
    @current_sentence = getSentence(@current_question)
    @question_id = @current_question.id
    if @question_num >= 11
      render "thankyou"
    end
  end
  
  def about
    @other_page = true
    
  end
  
  def privacy
    @other_page = true
  end

end

