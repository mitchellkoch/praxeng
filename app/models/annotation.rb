class Annotation < CouchRest::Model::Base
  belongs_to :question
  belongs_to :user
  
  property :response, []
  
  timestamps!
  
  design do
    view :by_question_id
    view :by_user_id
    view :by_user_id_and_question_id
  end 
    
end
