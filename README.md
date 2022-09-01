# Bosun

**TODO: Add description**

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
```

After defining your policy as seen above anywhere in your codebase you can call the `Bosun.permit?/3` or `Bosun.permit?/4` functions.

```elixir
Bosun.permit?(%User{role: :guest}, :update, %Post{}) => false

Bosun.permit?(%User{role: :guest}, :comment, %Post{title: "Another Guest Post"}, super_fan: true) => true
```

You can define an `Any` implementation as a fallback policy

```
defimpl Bosun.Policy, for: Any do

  def authorized?(_resource, _action, _subject, _options) do
    false
  end
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/bosun>.
