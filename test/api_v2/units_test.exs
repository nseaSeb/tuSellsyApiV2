# test/api_v2/units_test.exs
defmodule Api.UnitsTest do
  use ExUnit.Case

  #todo add post and delete unit mais pas encore dispo en V2

  setup_all do
    # UN SEUL APPEL pour tous les tests de ce module
    start_supervised!(OauthClient)
    {:ok, response} = Api_V2.get("units", %{})
    body = Jason.decode!(response.body)

    %{response: response, body: body}
  end

  describe "Endpoint /units" do
    test "retourne status 200", %{response: response} do
      assert response.status == 200
    end

    test "contient une clé data avec des unités", %{body: body} do
      assert %{"data" => units} = body
      assert is_list(units)
      assert length(units) > 0
    end

    test "chaque unité a les champs obligatoires", %{body: body} do
      %{"data" => units} = body

      for unit <- units do
        assert is_integer(unit["id"])
        assert is_binary(unit["label"])
        assert Map.has_key?(unit, "parameters")
      end
    end

    test "la pagination est présente", %{body: body} do
      assert %{"pagination" => pag} = body
      assert is_integer(pag["limit"])
      assert is_integer(pag["count"])
      assert is_integer(pag["total"])
    end

    test "les IDs sont uniques", %{body: body} do
      %{"data" => units} = body
      ids = Enum.map(units, & &1["id"])
      assert length(ids) == length(Enum.uniq(ids))
    end

  end
end
