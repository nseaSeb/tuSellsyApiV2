# lib/oauth_client.ex
defmodule OauthClient do
  use GenServer

  # API publique
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def get_token do
    GenServer.call(__MODULE__, :get_token)
  end

  # Callbacks GenServer
  def init(_state) do
    {:ok, %{token: nil, expires_at: nil}}
  end

  def handle_call(:get_token, _from, %{token: token, expires_at: expires_at} = state) do
    cond do
      token && not expired?(expires_at) ->
        {:reply, {:ok, token}, state}

      true ->
        case fetch_new_token() do
          {:ok, new_token, expires_in} ->
            new_state = %{
              token: new_token,
              expires_at: DateTime.utc_now() |> DateTime.add(expires_in, :second)
            }

            IO.inspect(label: "Oauth V2 ok")
            {:reply, {:ok, new_token}, new_state}

          error ->
            IO.inspect(error, label: "Oauth V2 error")
            {:reply, error, state}
        end
    end
  end

  defp fetch_new_token do
    config = Application.get_env(:tu, :sellsy)

    Tesla.post(
      "https://login.sellsy.com/oauth2/access-tokens",
      Jason.encode!(%{
        grant_type: "client_credentials",
        client_id: config[:client_id],
        client_secret: config[:client_secret]
      })
    )
    |> case do
      {:ok, %{status: 200, body: body}} ->
        %{"access_token" => token, "expires_in" => expires_in} = Jason.decode!(body)
        {:ok, token, expires_in}

      {:ok, response} ->
        {:error, "HTTP #{response.status}: #{response.body}"}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp expired?(expires_at) when is_nil(expires_at), do: true
  defp expired?(expires_at), do: DateTime.compare(expires_at, DateTime.utc_now()) == :lt
end
