class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception    
  protect_from_forgery with: :null_session
  
  def returningUser(session_id)
    count = User.by_name.key(session_id).count
    if count > 0
      return true
    else 
      return false
    end
    return false
  end
  
  def computeCustomMessage(question, annotation)
    notAnswered = []

    question.gold_answers.each do |ans|
      if !annotation.response.include?(ans)
        notAnswered.push(ans["relation_display_name"])
      end
    end
    
    message = "Thank you! but we think "
    if notAnswered.length == 1
      message += "\"" + notAnswered[0]+"\""+" was also an answer."
      return message
    elsif notAnswered.length == 2
      message += "\"" + notAnswered[0]+ "\" and "+ "\"" + notAnswered[1]+"\""+ " were also answers."
    else
      (notAnswered.length -2).times do |i|
        message += "\""+notAnswered[i]+"\", "
      end
      message += "\"" + notAnswered[0]+"\" and "+ "\"" + notAnswered[1]+"\""+ " were also answers."
      return message
    end
  end
  
  def checkAnnotation(question, annotation)
    correct = -1
    subset = true
    
    if !question.gold_answers
      correct = 2
      return correct
    end
    
    if question.gold_answers.length > 0 && annotation.response.length == 0
      return -1
    end
    
    annotation.response.each do |option|
      subset = subset && question.gold_answers.include?(option)
    end
    
    if subset == true
      properSubset = true
      if annotation.response.length == question.gold_answers.length
        properSubset = false
      end
      if properSubset == true
        correct = 0
      else 
        correct = 1
      end
      return correct
    end
    
    return correct    
  end
  
  def userResponse(annotation)
    user_resp = {}
    annotation.response.each do |resp|
      user_resp[resp] = "You"
    end
    if annotation.response.length == 0
      user_resp["none"] = "You" 
    end
    return user_resp
  end
  
  def countVotes(question, allAnnotations)
    crowd_votes = {}
    question.answers.each do |opt|
      crowd_votes[opt] = 0
    end
    crowd_votes["none"] = 0
    allAnnotations.each do |ann|
      if ann.response.length == 0
        crowd_votes["none"] = crowd_votes["none"] + 1
      else
        ann.response.each do |resp|
          crowd_votes[resp] = crowd_votes[resp] + 1
        end
      end
    end
    return crowd_votes
  end
    
  def newAnnotation(user, questionId, none, userResponse)
    question = Question.get(questionId)
    response = Array.new
    annotation = nil
    if none || !userResponse
      annotation = Annotation.new(:question => question, :user => user, :response => [])
    else 
     userResponse.each do |key, value|
        obj = JSON.parse(value.gsub("=>", ":"))
        response.push(obj)
      end
      annotation = Annotation.new(:question => question, :user => user, :response => response)
    end
    annotation.save   
    return annotation  
  end
  
  def getUser(sessionId)
    return User.by_name.key(sessionId).first
  end
  
  def newUser(sessionId, referer, ip)
    newUser = nil
    if referer == nil
      newUser = User.new(:name => sessionId, :src => "Direct", :ip_address=> request.remote_ip)
    else
      newUser = User.new(:name => sessionId, :src => referer, :ip_address=> request.remote_ip)
    end
    newUser.save
    return newUser
  end
  
  def getFirstQuestion(session_id)
    num_inst = Question.all.count
    rand_num = rand(num_inst-0)
    user = User.by_name.key(session_id).first
    if !user
      current_question = Question.all.skip(rand_num).limit(1).first
      return current_question
    else
       current_question = Question.all.skip(rand_num).limit(1).first
       # annotations = Annotation.by_question_id.key(current_question.id)
       count = Annotation.by_user_id_and_question_id.key([user.id, current_question.id]).count
       if count == 0
         return current_question
       else
         return getFirstQuestion(session_id)
       end
      
    end
  end
  
  
  def getSentence(question)
    doc_name = question.doc_name
    current_document = Document.by_doc_name.key(doc_name).first
    doc_text = current_document.text
    doc_sentences = doc_text.split("\n")
    arg = question.args[0]
    sent_num = arg["sent_idx"]
    current_sentence = doc_sentences[sent_num]
    
    return current_sentence
  end
  
  def getDocument(question)
    doc_name = question.doc_name
    current_document = Document.by_doc_name.key(doc_name).first
    return current_document
  end
end
