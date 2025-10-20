defmodule Api.ChangelogTest do
  use ExUnit.Case

  setup_all do
    start_supervised!(OauthClient)
    {:ok, response} = Api_V2.get("taxes", %{})
    body = Jason.decode!(response.body)

    %{response: response, body: body}
  end



end
