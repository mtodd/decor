require 'active_model'

class Company
  include ActiveModel::Serializers::JSON
  include Decor

  attr_accessor :v1_field, :v2_field

  version "v1" do
    def as_json(*_)
      super(:only => [:v1_field])
    end
  end

  version "v2" do
    def as_json(*_)
      super(:only => [:v2_field])
    end
  end

  def attributes
    { 'v1_field'=> v1_field, 'v2_field' => v2_field }
  end
end
