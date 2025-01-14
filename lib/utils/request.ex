defmodule StarkBank.Utils.Request do
  @moduledoc false

  alias StarkBank.Utils.JSON
  alias StarkBank.Utils.Check
  alias StarkBank.Utils.URL
  alias StarkBank.Error

  def fetch(method, path, options \\ []) do
    %{payload: payload, query: query, version: version, user: user_parameter} =
      Enum.into(options, %{payload: nil, query: nil, version: 'v2', user: nil})

    user = user_parameter |> Check.user()

    request(
      user,
      method,
      URL.get_url(user.environment, version, path, query),
      payload
    )
    |> process_response
  end

  defp request(user, method, url, payload) do
    Application.ensure_all_started(:inets)
    Application.ensure_all_started(:ssl)

    {:ok, {{'HTTP/1.1', status_code, _status_message}, _headers, response_body}} =
      :httpc.request(
        method,
        get_request_params(user, url, JSON.encode!(payload)),
        [
          ssl: [
            verify: :verify_peer,
            cacertfile: CAStore.file_path()
          ]
        ],
        []
      )

    {status_code, response_body}
  end

  defp get_request_params(user, url, body) when is_nil(body) do
    {
      url,
      get_headers(user, "")
    }
  end

  defp get_request_params(user, url, body) do
    {
      url,
      get_headers(user, body),
      'text/plain',
      body
    }
  end

  defp get_headers(user, body) do
    access_time = DateTime.utc_now() |> DateTime.to_unix(:second)

    signature =
      "#{user.access_id}:#{access_time}:#{body}"
      |> EllipticCurve.Ecdsa.sign(user.private_key)
      |> EllipticCurve.Signature.toBase64()

    [
      {'Access-Id', to_charlist(user.access_id)},
      {'Access-Time', to_charlist(access_time)},
      {'Access-Signature', to_charlist(signature)},
      {'Content-Type', 'application/json'},
      {'User-Agent', 'Elixir-#{System.version()}-SDK-2.6.2'},
      {'Accept-Language', Check.language()}
    ]
  end

  defp process_response({status_code, body}) do
    cond do
      status_code == 500 ->
        {:error, [%Error{code: "internalServerError", message: "Houston, we have a problem."}]}

      status_code == 400 ->
        {:error,
         JSON.decode!(body)["errors"]
         |> Enum.map(fn error -> %Error{code: error["code"], message: error["message"]} end)}

      status_code != 200 ->
        {:error,
         [
           %Error{
             code: "unknownError",
             message: "Unknown exception encountered: " <> to_string(body)
           }
         ]}

      true ->
        {:ok, body}
    end
  end
end
