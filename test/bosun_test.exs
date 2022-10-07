defmodule User do
  defstruct role: :guest, username: ""
end

defmodule Post do
  defstruct title: "", body: ""
end

defimpl Bosun.Policy, for: Post do
  alias Bosun.Context

  def authorized?(_resource, _action, %User{role: :admin}, context, _options) do
    Context.permit(context)
  end

  def authorized?(%Post{title: "A Guest Post"}, _action, %User{role: :guest}, context, _options) do
    Context.permit(context)
  end

  def authorized?(_resource, :read, %User{role: :guest}, context, _options) do
    Context.permit(context)
  end

  def authorized?(_resource, :comment, %User{role: :guest}, context, options) do
    %Context{context | permitted: options[:super_fan]}
  end

  def authorized?(_resource, :update, %User{role: :guest}, context, _options) do
    Context.reject(context, "User is a guest")
  end

  def authorized?(_resource, _action, _user, context, _options) do
    context
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

  describe "permit/4" do
    test "returns ok tuple if a subject is allowed to perform an action on a resource" do
      case Bosun.permit(%User{role: :admin}, :update, %Post{}) do
        {:ok, context} -> assert context.permitted == true
        {:error, _} -> flunk()
      end
    end

    test "returns error tuple if a subject is not allowed to perform an action on a resource" do
      case Bosun.permit(%User{role: :guest}, :update, %Post{}) do
        {:ok, _} -> flunk()
        {:error, context} -> assert context.permitted == false
      end
    end

    test "returns ok tuple if is a specific resource and type of subject" do
      case Bosun.permit(%User{role: :guest}, :update, %Post{title: "A Guest Post"}) do
        {:ok, context} -> assert context.permitted == true
        {:error, _} -> flunk()
      end
    end

    test "returns ok tuple if specific action" do
      case Bosun.permit(%User{role: :guest}, :read, %Post{title: "Another Guest Post"}) do
        {:ok, context} -> assert context.permitted == true
        {:error, _} -> flunk()
      end
    end

    test "returns ok tuple if option super_fan is true" do
      case Bosun.permit(%User{role: :guest}, :comment, %Post{title: "Another Guest Post"},
             super_fan: true
           ) do
        {:ok, context} -> assert context.permitted == true
        {:error, _} -> flunk()
      end
    end

    test "returns error tuple if option super_fan is false" do
      case Bosun.permit(%User{role: :guest}, :comment, %Post{title: "Another Guest Post"},
             super_fan: false
           ) do
        {:ok, _} -> flunk()
        {:error, context} -> assert context.permitted == false
      end
    end
  end

  describe "permit!/4" do
    test "do not raise error if a subject is allowed to perform an action on a resource" do
      context = Bosun.permit!(%User{role: :admin}, :update, %Post{})
      assert context.permitted == true
    end

    test "raises error if a subject is not allowed to perform an action on a resource" do
      assert_raise Bosun.Impermissible, fn ->
        Bosun.permit!(%User{role: :guest}, :update, %Post{})
      end
    end
  end
end
