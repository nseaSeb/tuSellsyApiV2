defmodule Api.ChangelogTest do
  use ExUnit.Case

  setup_all do
    start_supervised!(OauthClient)
    {:ok, response} = Api_V2.get("taxes", %{})
    body = Jason.decode!(response.body)

    %{response: response, body: body}
  end


  test "La note est bien présente dans la conversion de modèle" do
       body = %{doctype: "order", related: [%{type: "individual", id: 46340687}], refresh_rows_content: true }
      {:ok, response} = Api_V2.post("documents/models/47464287/convert", body)
      assert response.status == 200
      body = Jason.decode!(response.body)
      assert body["note"]
  end
end
