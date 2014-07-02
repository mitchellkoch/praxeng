class MainController < ApplicationController
  def welcome
    session["init"] = true
    user_count = User.by_name.key(session.id).count
    if user_count == 0
      @current_user = User.new(:name => session.id, :src => "Testing")
      @current_user.save
    else
      @current_user = User.by_name.key(session.id).first
    end
    
    
    @curr_user = User.by_name.key(session.id).first
    @current_instance = Question.get("ques-AIDA-YAGO2-DOC10054761.json")
    doc_name = @current_instance.doc_name
    current_document = Document.get(doc_name+".json")
    doc_text = current_document.text
    doc_sentences = doc_text.split("\n")
    arg = @current_instance.args[0]
    sent = arg["sent_idx"]
    @current_sentence = doc_sentences[sent]    
    
  end

  def task
    #use session id
    @curr_user = User.by_name.key(session.id).first
    num_inst = Question.all.count
    rand_num = rand(num_inst-0)
    @current_instance = Question.all.skip(rand_num).limit(1).first
    doc_name = @current_instance.doc_name
    current_document = Document.get(doc_name+".json")
    doc_text = current_document.text
    doc_sentences = doc_text.split("\n")
    arg = @current_instance.args[0]
    sent = arg["sent_idx"]
    @current_sentence = doc_sentences[sent]
  end
  
  def task2
    #use session id
    @curr_user = User.by_name.key(session.id).first
    @current_instance = Question.get("ques-AIDA-YAGO2-DOC10054761.json")
    doc_name = @current_instance.doc_name
    current_document = Document.get(doc_name+".json")
    doc_text = current_document.text
    doc_sentences = doc_text.split("\n")
    arg = @current_instance.args[0]
    sent = arg["sent_idx"]
    @current_sentence = doc_sentences[sent]
  end
  
  def feedback
    #will use id's from task to display stats
  end

  def about
  end

  def privacy
  end

  def create
    @user = User.get(params[:user_id])
    @instance = Question.get(params[:instance_id])
    doc_name = @instance.doc_name
    current_document = Document.get(doc_name+".json")
    doc_text = current_document.text
    doc_sentences = doc_text.split("\n")
    arg = @instance.args[0]
    sent = arg["sent_idx"]
    @current_sentence = doc_sentences[sent]
    
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
    @expression = "Awesome!"
    @expr_sent = "You did good."
    if @annotation.response.length <= 1
      @alert_type = "danger"
      @expression = "Oops!"
      @expr_sent = "Looks like you need more practice with us." 
    end
    
    ann = Annotation.by_question_id.key(@instance.id)
    
    @ann_count = ann.count
    @crowd1 = {}
    
    @instance.answers.each do |opt|
      @crowd1[opt["relation_display_name"]] = 0
    end
    puts @crowd1
    ann.each do |doc|
      doc.response.each do |resp|
        puts "********"
        puts resp
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
     
  end
  
  def create2
    @user = User.get(params[:user_id])
    @instance = Question.get(params[:instance_id])
    doc_name = @instance.doc_name
    current_document = Document.get(doc_name+".json")
    doc_text = current_document.text
    doc_sentences = doc_text.split("\n")
    arg = @instance.args[0]
    sent = arg["sent_idx"]
    @current_sentence = doc_sentences[sent]
    
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
    @expression = "Awesome!"
    @expr_sent = "You did good."
    if @annotation.response.length <= 1
      @alert_type = "danger"
      @expression = "Oops!"
      @expr_sent = "Looks like you need more practice with us." 
    end
    
    ann = Annotation.by_question_id.key(@instance.id)
    
    @ann_count = ann.count
    @crowd1 = {}
    
    @instance.answers.each do |opt|
      @crowd1[opt["relation_display_name"]] = 0
    end
    puts @crowd1
    ann.each do |doc|
      doc.response.each do |resp|
        puts "********"
        puts resp
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
     
  end
  
end
