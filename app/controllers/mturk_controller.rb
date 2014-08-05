class MturkController < ApplicationController
  skip_before_filter  :verify_authenticity_token
  def tutorialPage1
    @worker_id = params[:worker_id]
    @message = "You need to solve two example questions to qualify for the task. This is the first example."
    @question_num = 1   
  end
  
  def tutorialPage2
    @worker_id = params[:worker_id]
    @question_num = 1
    if params[:response]
      response = []
      params[:response].each do |key,value|
        response.push(value)
      end
      puts response
      correct = checkAnswer(response, ["lived in", "has nationality"])
      if correct == -1 
         @message = "Attention! You did not choose the correct options. If you fail again we will have to blacklist you."
         render "tutorialPage1"
      end
    else
      @message = "Attention! The answer is provided in Step 2. You still did not choose the correct options. If you fail again we will have to blacklist you."
      render "tutorialPage1"
    end
    @message = "Great! Now, solve this example and all future questions using similar reasoning."
  end
    
  def login
    @message = "Enter your Amazon Mechanical Turk Worker ID to continue. We will use your ID to track the work you did. Please ensure it is correct, otherwise we won't be able to pay you."
    @question_num = 1
  end
  
  def question
    @message = nil
    @question_num = 1
    @worker_id = params[:worker_id]
    @complete_code = params[:complete_code]
    if params[:fromtut2]
      if params[:response]
        response = []
        params[:response].each do |key,value|
          response.push(value)
        end
        correct = checkAnswer(response, ["plays for team", "has nationality"])
        if correct == -1
          @message = "Oops, you are wrong. Try again. Hint: You need to select two options."
          render "tutorialPage2"
        else
          user = User.get(@worker_id)
          @complete_code = (0...50).map { ('a'..'z').to_a[rand(26)] }.join
          if !user          
            user = User.new(:id => @worker_id,:name => @worker_id, :src => "amt", :confirm_codes => [@complete_code])
            user.save
          else 
            codes = user.confirm_codes
            codes.push(@complete_code)
            user.update_attributes(:confirm_codes => codes)
          end
          @message = "Qualified! Welcome to the main task. You need to solve 10 questions to get paid. We won't be able to pay for non-legitimate answers, so please reason out your responses (as in \"Example 1\") for all questions."
        end
      else
        @message = "Oops, you are wrong. Try again. Hint: You need to select two options."
        render "tutorialPage2"
      end
    else
      user = User.get(@worker_id)
      annotation = newAnnotation(user, params[:question_id], params[:none], params[:response])
      @message = "Reason about your responses in a similar manner to \"Example 1\" for all questions."
      @question_num = params[:question_num].to_i + 1
    end
    
    if @question_num >= 11
      @message = "Thank you! Copy the confirmation code and the number of questions completed to the form on the Mechanical Turk page you came from."
      render "complete"
    end
    
   
    @current_question = getFirstQuestion(@worker_id)
    @question_id = @current_question.id
    @current_sentence = getSentence(@current_question)
    
     
  end
  
  def complete
  end
  
  def checkAnswer(response, answer)
    if response.length != answer.length
      return -1
    end
    
    response.each do |resp|
      if !answer.include? (resp)
        return -1
      end
    end
    return 1
  end
end
