defprotocol Bosun.Policy do
  @fallback_to_any true

  @doc """
  Evaluates permissions
  """
  def permitted?(resource, action, subject, context, options)
end
