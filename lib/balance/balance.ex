defmodule StarkBank.Balance do
  alias __MODULE__, as: Balance
  alias StarkBank.Utils.Rest
  alias StarkBank.Utils.Check
  alias StarkBank.User.Project
  alias StarkBank.Error

  @moduledoc """
  Groups Balance related functions
  """

  @doc """
  The Balance struct displays the current balance of the workspace,
  which is the result of the sum of all transactions within this
  workspace. The balance is never generated by the user, but it
  can be retrieved to see the information available.

  ## Attributes (return-only):
    - `:id` [string, default nil]: unique id returned when Balance is created. ex: "5656565656565656"
    - `:amount` [integer, default nil]: current balance amount of the workspace in cents. ex: 200 (= R$ 2.00)
    - `:currency` [string, default nil]: currency of the current workspace. Expect others to be added eventually. ex: "BRL"
    - `:updated` [DateTime, default nil]: update datetime for the balance. ex: ~U[2020-03-26 19:32:35.418698Z]
  """
  defstruct [:id, :amount, :currency, :updated]

  @type t() :: %__MODULE__{}

  @doc """
  Receive the Balance entity linked to your workspace in the Stark Bank API

  ## Options:
    - `:user` [Organization/Project]: Organization or Project struct returned from StarkBank.project(). Only necessary if default project has not been set in configs.

  ## Return:
    - Balance struct with updated attributes
  """
  @spec get(user: Project.t() | Organization.t() | nil) :: {:ok, Balance.t()} | {:error, [Error]}
  def get(options \\ []) do
    case Rest.get_list(resource(), options) |> Enum.take(1) do
      [{:ok, balance}] -> {:ok, balance}
      [{:error, error}] -> {:error, error}
    end
  end

  @doc """
  Same as get(), but it will unwrap the error tuple and raise in case of errors.
  """
  @spec get!(user: Project.t() | Organization.t() | nil) :: Balance.t()
  def get!(options \\ []) do
    Rest.get_list!(resource(), options) |> Enum.take(1) |> hd()
  end

  @doc false
  def resource() do
    {
      "Balance",
      &resource_maker/1
    }
  end

  @doc false
  def resource_maker(json) do
    %Balance{
      id: json[:id],
      amount: json[:amount],
      currency: json[:currency],
      updated: json[:updated] |> Check.datetime()
    }
  end
end
