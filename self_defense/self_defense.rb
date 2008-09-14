module SelfDefense
  def self.included(mod)
    mod.extend(ClassMethods)
  end

  module ClassMethods
    def dont_rape(*args)
      args.each do |method|
        alias_method :"orig_#{method}", method

        @method = method
        module_eval do
          def self.method_added(sym)
            if sym == @method.to_sym 
              unless @__skip_redefine
                self.module_eval <<-"end;"
                  @__skip_redefine = true # Prevent recursion
                  def #{@method.to_s}(*args, &block)
                    orig_#{@method.to_s}(*args, &block)
                  end
                end;
              else
                @__skip_redefine = false
              end
            end
          end
        end
      end
    end
  end
end
