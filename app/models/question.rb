class Question < CouchRest::Model::Base
  property :answers, []
  property :gold_answers, []
  property :args, []
  property :doc_name, String
  
  design do
    view :by_doc_name
  end
  
end
