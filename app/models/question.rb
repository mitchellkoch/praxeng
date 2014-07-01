class Question < CouchRest::Model::Base
  property :answers, []
  property :args, []
  property :doc_name, String
  
  design do
    view :by_id
  end
  
end
