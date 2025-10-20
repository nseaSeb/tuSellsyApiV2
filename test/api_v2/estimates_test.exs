defmodule Api.EstimatesTest do
  use ExUnit.Case

  setup_all do
    start_supervised!(OauthClient)
    {:ok, response} = Api_V2.get("estimates", %{})
    body = Jason.decode!(response.body)

    %{response: response, body: body}
  end

  describe "Endpoint /estimates" do
    test "retourne status 200", %{response: response} do
      assert response.status == 200
    end

    test "contient une clé data avec des estimates", %{body: body} do
      assert %{"data" => estimates} = body
      assert is_list(estimates)
      assert length(estimates) > 0
    end

    test "chaque estimate a les champs obligatoires", %{body: body} do
      %{"data" => estimates} = body
      for estimate <- estimates do
        assert is_integer(estimate["id"])
        assert is_binary(estimate["number"])
        assert is_binary(estimate["status"])
      end
    end

    test "la pagination est présente", %{body: body} do
      assert %{"pagination" => pag} = body
      assert is_integer(pag["limit"])
      assert is_integer(pag["count"])
      assert is_integer(pag["total"])
    end

    test "les IDs sont uniques", %{body: body} do
      %{"data" => estimates} = body
      ids = Enum.map(estimates, & &1["id"])
      assert length(ids) == length(Enum.uniq(ids))
    end




  defp cleanup_estimate(response_body) do
    {:ok, parsed} = Jason.decode(response_body)
    estimate_id = parsed["id"]
    Api_V2.delete("estimates/#{estimate_id}")
  end
end
end
