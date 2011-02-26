# Decor provides a simple way to define multiple representations of an object.
#
# This is useful for when you want to retain multiple versions of your objects
# while providing a consistent interface between versions.
#
# For example:
#
#     class Company < ActiveRecord::Base
#       include Decor
#
#       # the first version, customers are dependent on certain artifacts
#       # like industry_id and industry
#       version "v1" do
#         INDUSTRIES = {1 => "Farm",
#                       2 => "Software"}
#
#         def industry
#           INDUSTRIES[industry_id]
#         end
#
#         def as_json(*_)
#           super(:only     => [:id, :name, :industry_id],
#                 :methods  => [:industry])
#         end
#       end
#
#       # switch to using industry standard codes, cleans up the name
#       version "v2" do
#         SIC_CODES = {...}
#
#         # use the cleaned name for the name instead
#         def name
#           name_cleaned
#         end
#
#         def industry
#           SIC_CODES[sic_code]
#         end
#
#         def as_json(*_)
#           super(:only     => [:id, :name, :sic_code],
#                 :methods  => [:industry])
#         end
#       end
#
#     end
#
# In our API, for instance, we can then define a single endpoint for both
# versions:
#
#     get "/api/:version/companies/:id.json" do
#       Company.find(params[:id]).for(version).to_json
#     end
#
# This helps us keep our models fat and our "controllers" skinny. This also
# helps unit testing the versions of your API.
#
# Further details can be found on [Github](https://github.com/mtodd/decor/).
#
module Decor

  # Decor is a mixin. Include it into your class and then use the `version`
  # class methods in the class body to define your versions, then use the
  # `for` instance method on your objects to use a specific version.
  #
  # For example:
  #
  #     class Model
  #       include Decor
  #
  #       version "v1" do
  #         # implement specifics for this version here
  #       end
  #     end
  #
  #     model = Model.new.for("v1")
  #
  def self.included(target)
    target.send(:extend, ClassMethods)
    class << target; attr_accessor :versions; end
    target.versions = {}
  end

  module ClassMethods
    # Defines versions of the model's representation.
    #
    # The `version` supplied is a string representation of the version.
    # For example, `"v1"` represents version 1 of this model's representation.
    #
    # The `version` is just a key, however, and any value works. Strings are
    # convenient, especially in the form of `v1` or `v2010-12-09`.
    #
    # If a block is provided, the block is treated as the body of the version's
    # definition.
    #
    # If a hash of `version => version_module` is passed in, we use your module
    # instead of creating our own.
    #
    # For example:
    #
    #     class Model
    #       include Decor
    #
    #       version "v1" do
    #         # ...
    #       end
    #
    #       module V20101209
    #         # ...
    #       end
    #       version "v2010-12-09" => V20101209
    #
    #       # or use classes (for example) as version keys and alias to other
    #       # versions
    #       version AnotherModel  => "v1"
    #       version OtherModel    => V20101209
    #
    #     end
    #
    def version(version, &block)
      case
      # Look up version module if no version block or module specified.
      #     version "v1" #=> #<Module>
      when self.versions.key?(version)
        return self.versions[version]

      # Define a new version from the block.
      #     version "v1" { ... }
      when block_given?
        constant = Module.new(&block)
        self.versions[version] = constant
        self

      # Set versions from a module, supports as many versions as passed in.
      #     version "v1"        => Version1,
      #             "v2"        => Version2,
      #             "v20101209" => "v2" # supports aliases
      else
        version.each do |(new_version, module_or_version)|
          self.versions[new_version] =
          if module_or_version.is_a?(Module)
            module_or_version
          else
            self.versions[module_or_version]
          end
        end

      end
      self
    end
  end

  # An object will be told to behave like the version specified.
  #
  # Options provide additional values in the context of the verions.
  #
  #     class Model
  #       include Decor
  #
  #       version "v1" do
  #         def versioned?
  #           true
  #         end
  #       end
  #
  #       def versioned?
  #         false
  #       end
  #     end
  #
  #     model = Model.new
  #     model.          versioned?  #=> false
  #     model.for("v1").versioned?  #=> true
  #
  # An optional context can be supplied which will make external resources
  # available for specific functions in your versions. For example:
  #
  #     class User
  #       include Decor
  #
  #       version "v1" do
  #         def display_name
  #           "%s (%s)" % [name, band.display_name]
  #         end
  #       end
  #     end
  #
  #     user = User.find(id).for("v1", :band => external_band)
  #     user.display_name #=> "Dan Auerbach (The Black Keys)"
  #
  # Lastly, it's possible to pass in a `:module` option which will override the
  # module already defined for the version specified (making the `version`
  # passed in almost meaningless).
  #
  #     module Specialized
  #       # special considerations here
  #     end
  #
  #     Model.new.for("v1", :module => Specialized)
  #
  def for(version, options = {})
    version_module = self.version_module_for(version, options)

    # Extend the current instance with the version module
    self.extend(version_module)

    # Options can override specific methods
    options = { :version => version }.merge(options)

    singleton_class = class << self; self; end;
    options.each do |option, value_or_proc|
      if value_or_proc.is_a?(Proc) or value_or_proc.is_a?(Method)
        singleton_class.send(:define_method, option, value_or_proc)
      else
        singleton_class.send(:define_method, option) { value_or_proc }
      end
    end

    self
  end

  # Handles finding the module defined for the `version` specified, or
  # overriding with the `:module` option.
  #
  # See `for` for details.
  #
  def version_module_for(version, options = {})
    return options.delete(:module)      if options.key?(:module)
    return self.class.versions[version] if self.class.versions.key?(version)
    self.class.const_get(version.upcase)
  end
end
