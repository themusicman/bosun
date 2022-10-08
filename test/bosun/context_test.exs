defmodule Bosun.ContextTest do
  use ExUnit.Case
  doctest Bosun.Context

  alias Bosun.Context

  setup do
    {:ok, context: %Context{}}
  end

  describe "update/3" do
    test "keeps a log of reasons", %{context: context} do
      %Context{log: log} =
        context
        |> Context.update(true, "Admins can do anything")
        |> Context.update(false, "But this admin can't")

      assert [{:deny, "But this admin can't"}, {:permit, "Admins can do anything"}] == log
    end

    test "keeps the last reason", %{context: context} do
      %Context{reason: reason} =
        context
        |> Context.update(true, "Admins can do anything")
        |> Context.update(false, "But this admin can't")

      assert "But this admin can't" == reason
    end
  end

  describe "permit/2" do
    test "updates the context and set permitted to true", %{context: context} do
      context = Context.permit(context, "Admins can do anything")

      assert %Bosun.Context{
               log: [permit: "Admins can do anything"],
               permitted: true,
               reason: "Admins can do anything"
             } == context
    end
  end

  describe "deny/2" do
    test "updates the context and set permitted to false", %{context: context} do
      context = Context.deny(context, "This admin can't")

      assert %Bosun.Context{
               log: [deny: "This admin can't"],
               permitted: false,
               reason: "This admin can't"
             } == context
    end
  end
end
