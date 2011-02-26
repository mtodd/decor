class Resource < Struct.new(:name, :value, :multi)
  include Decor
  
  # Module method
  module V1
    def computed
      value * multi
    end
  end
  version "v1" => V1
  
  # Module method, non-standard
  module Version2
    MUTLI = 10
    def name
      super.upcase
    end
    def computed
      value * multi * MUTLI
    end
  end
  # mutliple aliases
  version "v2"          => Version2,
          "v2010-12-08" => Version2
  
  # Block method
  version "v3" do
    # utilizes options hash
    def name
      "%s (%s)" % [super, foo]
    end
    def computed
      nil
    end
    def foo
      "foo in v3"
    end
  end
  
end
