defmodule Api.ContactsTest do
  use ExUnit.Case

  setup_all do
    start_supervised!(OauthClient)
    {:ok, response} = Api_V2.get("contacts", %{})
    body = Jason.decode!(response.body)

    %{response: response, body: body}
  end
    describe "Endpoint /contacts" do
    test "retourne status 200", %{response: response} do
      assert response.status == 200
    end

    test "contient une clé data avec des contacts", %{body: body} do
      assert %{"data" => contacts} = body
      assert is_list(contacts)
      assert length(contacts) > 0
    end
       test "chaque taxe a les champs obligatoires", %{body: body} do
      %{"data" => contacts} = body
      for contact <- contacts do
        assert is_integer(contact["id"])
        assert is_binary(contact["last_name"])
      end
    end

    test "la pagination est présente", %{body: body} do
      assert %{"pagination" => page} = body
      assert is_integer(page["limit"])
      assert is_integer(page["count"])
      assert is_integer(page["total"])
    end

    test "les IDs sont uniques", %{body: body} do
      %{"data" => contacts} = body
      ids = Enum.map(contacts, & &1["id"])
      assert length(ids) == length(Enum.uniq(ids))
    end
  end
end
