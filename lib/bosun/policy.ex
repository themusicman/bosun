defprotocol Bosun.Policy do
  @fallback_to_any true

  @doc "Evaluates permissions"
  def authorized?(resource, action, subject, options)
end

defimpl Bosun.Policy, for: Any do
  require Logger

  def authorized?(_resource, _action, _subject, _options) do
    Logger.debug("Bosun.Policy.authorized? called for any fallback")
    false
  end
end
