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
    @message = "Great! Now solve this example and all future questions using similar reasoning."
  end
    
  def login
    @message = "Enter your mechanical turk worker id to continue. We will use your id to track the work you did. Please ensure it is correct, otherwise we wont be able to pay you."
    @question_num = 1
  end
  
  def question
    @message = nil
    @question_num = 1
    @worker_id = params[:worker_id]
    if params[:fromtut2]
      if params[:response]
        response = []
        params[:response].each do |key,value|
          response.push(value)
        end
        correct = checkAnswer(response, ["plays for team", "has nationality"])
        if correct == -1
          @message = "Oops you are wrong. Try again."
          render "tutorialPage2"
        end
      else
        @message = "Oops you are wrong. Try again. Hint: The question has two answers."
        render "tutorialPage2"
      end
    else
      @question_num = params[:question_num].to_i + 1
    end
    
    if @question_num == 11
      @complete_code = Question.get("random_strings").random_strings[rand(100)]
      render "complete"
    end
    
    @message = "Qualified! Welcome to the main task. You will be paid for all (legitimate) answers to questions from here onwards."
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
