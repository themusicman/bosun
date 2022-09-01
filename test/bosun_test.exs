defmodule User do
  defstruct role: :guest, username: ""
end

defmodule Post do
  defstruct title: "", body: ""
end

defimpl Bosun.Policy, for: Post do
  def authorized?(_resource, _action, %User{role: :admin}, _options) do
    true
  end

  def authorized?(%Post{title: "A Guest Post"}, _action, %User{role: :guest}, _options) do
    true
  end

  def authorized?(_resource, :read, %User{role: :guest}, _options) do
    true
  end

  def authorized?(_resource, :comment, %User{role: :guest}, options) do
    options[:super_fan]
  end

  def authorized?(_resource, :update, %User{role: :guest}, _options) do
    false
  end

  def authorized?(_resource, _action, _user, _options) do
    false
  end
end

defmodule BosunTest do
  use ExUnit.Case
  doctest Bosun

  describe "permit?/4" do
    test "returns true if a subject is allowed to perform an action on a resource" do
      assert Bosun.permit?(%User{role: :admin}, :update, %Post{}) == true
    end

    test "returns false if a subject is not allowed to perform an action on a resource" do
      assert Bosun.permit?(%User{role: :guest}, :update, %Post{}) == false
    end

    test "returns true if is a specific resource and type of subject" do
      assert Bosun.permit?(%User{role: :guest}, :update, %Post{title: "A Guest Post"}) == true
    end

    test "returns true if specific action" do
      assert Bosun.permit?(%User{role: :guest}, :read, %Post{title: "Another Guest Post"}) == true
    end

    test "returns true if option super_fan is true" do
      assert Bosun.permit?(%User{role: :guest}, :comment, %Post{title: "Another Guest Post"},
               super_fan: true
             ) == true
    end

    test "returns false if option super_fan is false" do
      assert Bosun.permit?(%User{role: :guest}, :comment, %Post{title: "Another Guest Post"},
               super_fan: false
             ) == false
    end
  end
end
