-module(erruby_class).
-export([new_class/0, new_named_class/1, new_class/1, install_class_class_methods/0, init_class_class/0, class_name/1]).

%TODO return self when calling method_class on self
%TODO add name parameter
%TODO should call initialize method when new

new_class() ->
  new_named_class(undefined).

new_named_class(Name) ->
  Properties = #{name => Name},
  erruby_object:start_link(class_class(), Properties).

class_name(Self) ->
  Properties = erruby_object:get_properties(Self),
  #{name := Name} = Properties,
  Name.

new_class(SuperClass) ->
  Properties = #{superclass => SuperClass},
  erruby_object:start_link(class_class(), Properties).

install_class_class_methods() ->
  erruby_object:def_method(class_class(), 'new', fun method_new/1),
  ok.

%FIXME new a real class
method_new(#{self := Klass}=Env) ->
  {ok, NewObject} = erruby_object:start_link(Klass),
  erruby_rb:return(NewObject, Env).

init_class_class() ->
  erb:find_or_init_class(erruby_class_class, fun init_class_class_internal/0).

init_class_class_internal() ->
  Properties = #{superclass => erruby_object:object_class()},
  {ok, Pid} = erruby_object:new_object_with_pid_symbol(erruby_class_class, erruby_object:object_class()),
  ok = install_class_class_methods(),
  {ok, Pid}.

class_class() ->
  whereis(erruby_class_class).

