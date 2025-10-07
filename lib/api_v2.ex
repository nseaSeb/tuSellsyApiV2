defmodule Api_V2 do
  @base_url_v2 "https://api.sellsy.com/v2"

  def get(endpoint, query_params \\ %{}) do
    Process.sleep(200)
    with {:ok, token} <- OauthClient.get_token() do
      Tesla.get("#{@base_url_v2}/#{endpoint}",
        headers: [{"authorization", "Bearer #{token}"}],
        query: query_params
      )
    end
  end

  def post(endpoint, body \\ %{}) do
    Process.sleep(200)
    with {:ok, token} <- OauthClient.get_token() do
      Tesla.post(
        "#{@base_url_v2}/#{endpoint}",
        Jason.encode!(body),
        headers: [
          {"authorization", "Bearer #{token}"},
          {"content-type", "application/json"}
        ]
      )
    end
  end
  def delete(endpoint) do
    Process.sleep(200)
    with {:ok, token} <- OauthClient.get_token() do
      Tesla.delete(
        "#{@base_url_v2}/#{endpoint}",
        headers: [
          {"authorization", "Bearer #{token}"},
          {"content-type", "application/json"}
        ]
      )
    end
  end
end
