class User < CouchRest::Model::Base
  property :src, String #to enable A/B testing
  property :name, String #session id for now
  property :email, String
  property :password, String 
  
  timestamps!
  
  design do
    view :by_name
    view :by_src
  end 
end
