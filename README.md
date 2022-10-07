# Bosun

A simple authorization package that uses protocols.

## Installation

If [available in Hex](https://hex.pm/packages/bosun), the package can be installed
by adding `bosun` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:bosun, "~> 1.0.1"}
  ]
end
```

## Basic Usage

To use Bosun all you need to do is define your policy by implementing the `Bosun.Policy` protocol for a struct. Example below:

```elixir
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
```

After defining your policy as seen above anywhere in your codebase you can call the `Bosun.permit?/3` or `Bosun.permit?/4` functions.

```elixir
if Bosun.permit?(%User{role: :guest}, :comment, %Post{title: "Another Guest Post"}, super_fan: true) do
  do_something()
else
  Logger.error("Boom!!!?!")
end

case Bosun.permit(%User{role: :guest}, :comment, %Post{title: "Another Guest Post"}, super_fan: true) do
  {:ok, _} -> do_something()
  {:error, context} -> Logger.error(context.reason)
end

try do
  Bosun.permit!(%User{role: :guest}, :comment, %Post{title: "Another Guest Post"}, super_fan: true)
  do_something()
rescue
   e in Impermissible -> Logger.error(e.message)
 end
```

You can define an `Any` implementation as a fallback policy

```elixir
defimpl Bosun.Policy, for: Any do
  alias Bosun.Context

  def authorized?(_resource, _action, _subject, context, _options) do
    Context.reject(context, "Impermissible")
  end
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/bosun>.
