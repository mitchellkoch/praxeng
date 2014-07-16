class MainController < ApplicationController
  
  def welcome
    
    @question_num = 1
    @num_correct = 0
    #fetch a random question
    
    num_inst = Question.all.count
    rand_num = rand(num_inst-0)
    @current_question = Question.all.skip(rand_num).limit(1).first
    @question_id = @current_question.id
    #fetch doc for question
    doc_name = @current_question.doc_name
    current_document = Document.by_doc_name.key(doc_name).first
    doc_text = current_document.text
    doc_sentences = doc_text.split("\n")
    arg = @current_question.args[0]
    sent_num = arg["sent_idx"]
    @current_sentence = doc_sentences[sent_num]       
    
    session["init"] = true
    user_count = User.by_name.key(session.id).count
    @referer = request.env['HTTP_REFERER']
    @session_id = session.id
    if user_count != 0
      render "oldvisitor"
    end  
  end

  def question
    #save user info
    session["init"] = true
    session_id = params[:sessionId]
    user_count = User.by_name.key(session_id).count
    src = params[:referer]
    if src != nil
            uri = URI.parse src
            src = uri.host
    else
            src = "Direct"
    end
    @curr_user = nil
    @current_user = nil
    if user_count == 0
       @current_user = User.new(:name => session_id, :src => src, :ip_address=> request.remote_ip)
       @current_user.save
       @curr_user = @current_user
     else
       @current_user = User.by_name.key(session_id).first
       @curr_user = @current_user
     end  
    
    @user = @curr_user
    
     
    @instance = Question.get(params[:instance_id])
    doc_name = @instance.doc_name
    current_document = Document.by_doc_name.key(doc_name).first
    doc_text = current_document.text
    doc_sentences = doc_text.split("\n")
    arg = @instance.args[0]
    sent = arg["sent_idx"]
    @sentence = doc_sentences[sent]
    @response = Array.new
    @annotation = nil
    if params[:none] || !params[:response]
      @annotation = Annotation.new(:question => @instance, :user => @user, :response => [])
    else 
      params[:response].each do |key, value|

        obj = JSON.parse(value.gsub("=>", ":"))
        @response.push(obj)
      end
      @annotation = Annotation.new(:question => @instance, :user => @user, :response => @response)
    end
    @annotation.save



    @user_resp = {}
    @annotation.response.each do |resp|
      @user_resp[resp] = "You"
    end
    if @annotation.response.length == 0
      @user_resp["none"] = "You" 
    end

    ann = Annotation.by_question_id.key(@instance.id)
    
    @ann_count = ann.count
    
    @crowd1 = {}
    @instance.answers.each do |opt|
      @crowd1[opt] = 0
    end
    @crowd1["none"] = 0
    ann.each do |doc|
      if doc.response.length == 0
        @crowd1["none"] = @crowd1["none"] + 1
      else
        doc.response.each do |resp|
          @crowd1[resp] = @crowd1[resp] + 1
        end
      end
    end

    @question_num = params[:question_num].to_i + 1
    #figure if correct
    @num_correct = params[:num_correct].to_i
    correct = 1
   
    @instance.gold_answers.each do |opt|
      if @response.include? opt
        correct = correct * 1
      else
        correct = correct * 0
      end
    end
    @alert_type = "alert-danger"
    @msg = "Wrong :("
    if @instance.gold_answers.size() == @response.size() 
      @num_correct += correct
      if correct == 1
        @msg = "Correct! :D"
        @alert_type = "alert-success"        
      end
    end
    
    
    if @instance.gold_answers.size() > @response.size()
      subset = 1
      response.each do |opt|
        if !@instance.gold_answers.include? opt
          subset = 0
        end
      end
      if subset == 1
        @alert_type = "alert-warning"
        @msg = "You missed something..."
      end
    end



    #fetch a random question
    @curr_user = @user
    prev_question_id = params[:question_id]
    @question_id = (prev_question_id.split("-")[1].to_i + 1)%10
    if @question_id == 0
      @question_id = 10
    end
    @question_id = "Question-"+@question_id.to_s
    @current_question = Question.get(@question_id)
    # num_inst = Question.all.count
#     rand_num = rand(num_inst-0)
#     @current_question = Question.all.skip(rand_num).limit(1).first
    #fetch doc for question
    doc_name = @current_question.doc_name
    current_document = Document.by_doc_name.key(doc_name).first
    doc_text = current_document.text
    doc_sentences = doc_text.split("\n")
    arg = @current_question.args[0]
    sent_num = arg["sent_idx"]
    @current_sentence = doc_sentences[sent_num]  

  end

  def create2
    @user = User.get(params[:user_id])
    @instance = Question.get(params[:instance_id])
    doc_name = @instance.doc_name
    current_document = Document.by_doc_name.key(doc_name).first
    doc_text = current_document.text
    doc_sentences = doc_text.split("\n")
    arg = @instance.args[0]
    sent = arg["sent_idx"]
    @sentence = doc_sentences[sent]
    
    @annotation = nil
    if params[:none] || !params[:response]
      @annotation = Annotation.new(:question => @instance, :user => @user, :response => [])
    else 
      @response = Array.new
      params[:response].each do |key, value|
        @response.push(value)
      end
      @annotation = Annotation.new(:question => @instance, :user => @user, :response => @response)
    end
    
    @annotation.save
    
    @user_resp = {}
    @annotation.response.each do |resp|
      @user_resp[resp] = "You"
    end
    if @annotation.response.length == 0
      @user_resp["none"] = "You" 
    end
    @alert_type = "success"
    messages = ["Awesome! You did well.", "Great! That was a tough question.", "You did well! Keep practicing.", "You are doing well!"]
    @message = messages[Random.rand(messages.size)]

    ann = Annotation.by_question_id.key(@instance.id)
    
    @ann_count = ann.count
    @crowd1 = {}
    
    @instance.answers.each do |opt|
      @crowd1[opt["relation_display_name"]] = 0
    end
    puts @crowd1
    ann.each do |doc|
      doc.response.each do |resp|
        @crowd1[resp] = @crowd1[resp] + 1
      end
    end
    
    @crowd1["none"] = 0
    ann.each do |doc|
      if doc.response.length == 0
        @crowd1["none"] = @crowd1["none"] + 1
      end
    end
    @crowd = {}
    @crowd1.each_key do |key|
      @crowd[key] = ((@crowd1[key].to_i * 100)/ann.count.to_i) 
    end
    
    
    @curr_user = @user
    @num_questions = Annotation.by_user_id.key(@curr_user.id).count
    if @num_questions == 3
      @displayFbModal = true
    end
    num_inst = Question.all.count
    rand_num = rand(num_inst-0)
    @current_instance = Question.all.skip(rand_num).limit(1).first
    doc_name = @current_instance.doc_name
    current_document = Document.by_doc_name.key(doc_name).first
    doc_text = current_document.text
    doc_sentences = doc_text.split("\n")
    arg = @current_instance.args[0]
    sent = arg["sent_idx"]
    @current_sentence = doc_sentences[sent]
    
    @total_questions = 8
  end

  def task
    
    
    #use session id
    @curr_user = User.by_name.key(session.id).first
    @num_questions = Annotation.by_user_id.key(@curr_user.id).count
    num_inst = Question.all.count
    rand_num = rand(num_inst-0)
    @current_instance = Question.all.skip(rand_num).limit(1).first
    doc_name = @current_instance.doc_name
    current_document = Document.by_doc_name.key(doc_name).first
    doc_text = current_document.text
    doc_sentences = doc_text.split("\n")
    arg = @current_instance.args[0]
    sent = arg["sent_idx"]
    @current_sentence = doc_sentences[sent]   
    
    @total_questions = 8
  end

  def create
    @user = User.get(params[:user_id])
    @instance = Question.get(params[:instance_id])
    doc_name = @instance.doc_name
    current_document = Document.by_doc_name.key(doc_name).first
    doc_text = current_document.text
    doc_sentences = doc_text.split("\n")
    arg = @instance.args[0]
    sent = arg["sent_idx"]
    @sentence = doc_sentences[sent]

    @annotation = nil
    if params[:none] || !params[:response]
      @annotation = Annotation.new(:question => @instance, :user => @user, :response => [])
    else 
      @response = Array.new
      params[:response].each do |key, value|

        obj = JSON.parse(value.gsub("=>", ":"))
        @response.push(obj)
      end
      @annotation = Annotation.new(:question => @instance, :user => @user, :response => @response)
    end
    @annotation.save



    @user_resp = {}
    @annotation.response.each do |resp|
      @user_resp[resp] = "You"
    end
    if @annotation.response.length == 0
      @user_resp["none"] = "You" 
    end

    ann = Annotation.by_question_id.key(@instance.id)
    
    @ann_count = ann.count
    
    @crowd1 = {}
    @instance.answers.each do |opt|
      @crowd1[opt] = 0
    end
    @crowd1["none"] = 0
    ann.each do |doc|
      if doc.response.length == 0
        @crowd1["none"] = @crowd1["none"] + 1
      else
        doc.response.each do |resp|
          @crowd1[resp] = @crowd1[resp] + 1
        end
      end
    end

    @question_num = params[:question_num].to_i + 1
    #figure if correct
    @num_correct = params[:num_correct].to_i
    correct = 1
    @instance.gold_answers.each do |opt|
      if @response.include? opt
        correct = correct * 1
      else
        correct = correct * 0
      end
    end
    @alert_type = "alert-danger"
    @msg = "Wrong :("
    if @instance.gold_answers.size() == @response.size() 
      @num_correct += correct
      if correct == 1
        @msg = "Correct! :D"
        @alert_type = "alert-success"        
      end
    end

   if @instance.gold_answers.size() > @response.size()
      subset = 1
      response.each do |opt|
        if !@instance.gold_answers.include? opt
          subset = 0
        end
      end
      if subset == 1
        @alert_type = "alert-warning"
        @msg = "You missed something..."
      end
    end

    #fetch a random question
    @curr_user = @user
    prev_question_id = params[:question_id]
    @question_id = (prev_question_id.split("-")[1].to_i + 1)%10
    if @question_id == 0
      @question_id = 10
    end
    @question_id = "Question-"+@question_id.to_s
    @current_question = Question.get(@question_id)
    # num_inst = Question.all.count
#     rand_num = rand(num_inst-0)
#     @current_question = Question.all.skip(rand_num).limit(1).first
    #fetch doc for question
    doc_name = @current_question.doc_name
    current_document = Document.by_doc_name.key(doc_name).first
    doc_text = current_document.text
    doc_sentences = doc_text.split("\n")
    arg = @current_question.args[0]
    sent_num = arg["sent_idx"]
    @current_sentence = doc_sentences[sent_num]  
     
    if @question_num == 11
      render "thankyou"
    end

  end
  
end
