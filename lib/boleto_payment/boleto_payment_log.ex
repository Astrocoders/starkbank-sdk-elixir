defmodule StarkBank.BoletoPayment.Log do
  alias __MODULE__, as: Log
  alias StarkBank.Utils.Rest
  alias StarkBank.Utils.Check
  alias StarkBank.Utils.API
  alias StarkBank.BoletoPayment
  alias StarkBank.User.Project
  alias StarkBank.Error

  @moduledoc """
  Groups BoletoPayment.Log related functions
  """

  @doc """
  Every time a BoletoPayment entity is modified, a corresponding BoletoPayment.Log
  is generated for the entity. This log is never generated by the
  user, but it can be retrieved to check additional information
  on the BoletoPayment.

  ## Attributes:
    - `:id` [string]: unique id returned when the log is created. ex: "5656565656565656"
    - `:payment` [BoletoPayment]: BoletoPayment entity to which the log refers to.
    - `:errors` [list of strings]: list of errors linked to this BoletoPayment event.
    - `:type` [string]: type of the BoletoPayment event which triggered the log creation. ex: "processing" or "success"
    - `:created` [DateTime]: creation datetime for the log. ex: ~U[2020-03-26 19:32:35.418698Z]
  """
  @enforce_keys [:id, :payment, :errors, :type, :created]
  defstruct [:id, :payment, :errors, :type, :created]

  @type t() :: %__MODULE__{}

  @doc """
  Receive a single Log struct previously created by the Stark Bank API by passing its id

  ## Parameters (required):
    - `id` [string]: struct unique id. ex: "5656565656565656"

  ## Options:
    - `:user` [Organization/Project]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project has not been set in configs.

  ## Return:
    - Log struct with updated attributes
  """
  @spec get(binary, user: Project.t() | Organization.t() | nil) :: {:ok, Log.t()} | {:error, [%Error{}]}
  def get(id, options \\ []) do
    Rest.get_id(resource(), id, options)
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(binary, user: Project.t() | Organization.t() | nil) :: Log.t()
  def get!(id, options \\ []) do
    Rest.get_id!(resource(), id, options)
  end

  @doc """
  Receive a stream of Log structs previously created in the Stark Bank API

  ## Options:
    - `:limit` [integer, default nil]: maximum number of entities to be retrieved. Unlimited if nil. ex: 35
    - `:after` [Date or string, default nil]: date filter for entities created only after specified date. ex: ~D[2020-03-25]
    - `:before` [Date or string, default nil]: date filter for entities created only before specified date. ex: ~D[2020-03-25]
    - `:types` [list of strings, default nil]: filter retrieved entities by event types. ex: "processing" or "success"
    - `:payment_ids` [list of strings, default nil]: list of BoletoPayment ids to filter retrieved entities. ex: ["5656565656565656", "4545454545454545"]
    - `:user` [Organization/Project]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project has not been set in configs.

  ## Return:
    - stream of Log structs with updated attributes
  """
  @spec query(
          limit: integer,
          after: Date.t() | binary,
          before: Date.t() | binary,
          types: [binary],
          payment_ids: [binary],
          user: Project.t()
        ) ::
          ({:cont, {:ok, [Log.t()]}}
           | {:error, [Error.t()]}
           | {:halt, any}
           | {:suspend, any},
           any ->
             any)
  def query(options \\ []) do
    Rest.get_list(resource(), options)
  end

  @doc """
  Same as query(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec query!(
          limit: integer,
          after: Date.t() | binary,
          before: Date.t() | binary,
          types: [binary],
          payment_ids: [binary],
          user: Project.t()
        ) ::
          ({:cont, [Log.t()]} | {:halt, any} | {:suspend, any}, any -> any)
  def query!(options \\ []) do
    Rest.get_list!(resource(), options)
  end

  @doc false
  def resource() do
    {
      "BoletoPaymentLog",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %Log{
      id: json[:id],
      payment: json[:payment] |> API.from_api_json(&BoletoPayment.resource_maker/1),
      created: json[:created] |> Check.datetime(),
      type: json[:type],
      errors: json[:errors]
    }
  end
end
