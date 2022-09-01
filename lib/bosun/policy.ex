defprotocol Bosun.Policy do
  @fallback_to_any true

  @doc "Evaluates permissions"
  def authorized?(resource, action, subject, options)
end
