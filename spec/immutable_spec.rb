require 'rubygems'
require 'spec'
require 'ruby-debug'

require File.join(File.dirname(__FILE__), '..', 'lib', 'immutable')

##################
# Module version #
##################

module Foo
  include Immutable

  def foo
    :fast
  end

  def bar
    :fast
  end

  immutable_method :foo, :bar
end

# Other Foo modules we can screw with, so specs don't step on each other
Foo2 = Foo.clone
Foo3 = Foo.clone

describe "Module Foo" do
  def test_it(mod, method)
    @value = Object.instance_eval do
      include mod
      send(method)
    end

    @value.should == :fast
  end
 
  describe "after redefining" do
    it "should not let foo() be redefined" do
      redefine(Foo, :foo)
      test_it(Foo, :foo)
    end
  
    it "should not let foo() be redefined even if we try twice" do
      redefine(Foo, :foo)
      redefine(Foo, :foo)
      test_it(Foo, :foo)
    end

    it "should not let bar() be redefined" do
      redefine(Foo, :bar)
      test_it(Foo, :bar)
    end

    it "should not let bar() be redefined even if we try twice" do
      redefine(Foo, :bar)
      redefine(Foo, :bar)
      test_it(Foo, :bar)
    end
  end

  describe "after undefining" do
    it "should not let foo() be undefined" do
      undefine(Foo2, :foo)
      test_it(Foo2, :foo)
    end

    it "should not let bar() be undefined" do
      undefine(Foo2, :bar)
      test_it(Foo2, :bar)
    end
  end

  describe "after removing" do
    it "should not let foo() be removed" do
      remove(Foo3, :foo)
      test_it(Foo3, :foo)
    end

    it "should not let bar() be removed" do
      remove(Foo3, :bar)
      test_it(Foo3, :bar)
    end
  end
end

#################
# Class version #
#################

class Bar
  include Immutable

  def foo
    :fast
  end

  def bar
    :fast
  end

  immutable_method :foo, :bar
end

# Other Bar modules we can screw with, so specs don't step on each other
Bar2 = Bar.clone
Bar3 = Bar.clone

class ChildOfBar < Bar
  def foo
    :slow
  end
end

describe "Class Bar" do
  def test_it(klass, method)
    @value = klass.new.send(method)
    @value.should == :fast
  end
 
  describe "after redefining" do
    it "should not let foo() be redefined" do
      redefine(Bar, :foo)
      test_it(Bar, :foo)
    end
  
    it "should not let foo() be redefined even if we try twice" do
      redefine(Bar, :foo)
      redefine(Bar, :foo)
      test_it(Bar, :foo)
    end

    it "should not let bar() be redefined" do
      redefine(Bar, :bar)
      test_it(Bar, :bar)
    end
  
    it "should not let bar() be redefined even if we try twice" do
      redefine(Bar, :bar)
      redefine(Bar, :bar)
      test_it(Bar, :bar)
    end
  end

  describe "after undefining" do
    it "should not let foo() be undefined" do
      undefine(Bar2, :foo)
      test_it(Bar2, :foo)
    end

    it "should not let bar() be undefined" do
      undefine(Bar2, :bar)
      test_it(Bar2, :bar)
    end
  end

  describe "after removing" do
    it "should not let foo() be removed" do
      remove(Bar3, :foo)
      test_it(Bar3, :foo)
    end

    it "should not let bar() be removed" do
      remove(Bar3, :bar)
      test_it(Bar3, :bar)
    end
  end

  describe "child classes" do
    it "should still be able to override method" do
      ChildOfBar.new.foo.should == :slow
    end
  end
end
##################
# Helper methods #
##################

def redefine(mod, method)
  mod.module_eval <<-"end;"
    def #{method.to_s}
      :slow
    end
  end;
end

def undefine(mod, method)
  mod.module_eval do
    undef_method(method)
  end
end

def remove(mod, method)
  mod.module_eval do
    remove_method(method)
  end
end
