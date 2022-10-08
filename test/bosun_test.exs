defmodule User do
  defstruct role: :guest, username: "", blocked: false
end

defmodule Post do
  defstruct title: "", body: ""
end

defimpl Bosun.Policy, for: Post do
  alias Bosun.Context

  def permitted?(_resource, _action, %User{role: :admin}, context, _options) do
    Context.permit(context, "Admins are allowed to do anything")
  end

  def permitted?(%Post{title: "A Guest Post"}, _action, %User{role: :guest}, context, _options) do
    Context.permit(context, "Guests are allowed to do stuff to guest posts")
  end

  def permitted?(_resource, :read, %User{role: :guest}, context, _options) do
    Context.permit(context, "Guests are allowed to read posts")
  end

  def permitted?(_resource, :comment, %User{role: :guest} = user, context, options) do
    if options[:super_fan] do
      Context.permit(context, "Super fans are permitted")
    else
      Context.deny(context, "Guests that are not super fans are not permitted")
    end
    |> blocked_commenter?(user)
  end

  def blocked_commenter?(%Context{permitted: true} = context, %User{blocked: true}) do
    Context.deny(context, "User blocked from commenting")
  end

  def blocked_commenter?(context, _user) do
    context
  end

  def permitted?(_resource, :update, %User{role: :guest}, context, _options) do
    Context.deny(context, "User is a guest")
  end

  def permitted?(_resource, _action, _user, context, _options) do
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
