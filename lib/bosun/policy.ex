defprotocol Bosun.Policy do
  @fallback_to_any true

  @doc """
  Evaluates permissions
  """
  def permitted?(resource, action, subject, context, options)

  @doc """
  Returns a resource id
  """
  def resource_id(resource, action, subject, context, options)

  @doc """
  Returns a subject id
  """
  def subject_id(resource, action, subject, context, options)
end
