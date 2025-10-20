defmodule Api.TaxesTest do
  use ExUnit.Case

  setup_all do
    start_supervised!(OauthClient)
    {:ok, response} = Api_V2.get("taxes", %{})
    body = Jason.decode!(response.body)

    %{response: response, body: body}
  end

  describe "Endpoint /taxes" do
    test "retourne status 200", %{response: response} do
      assert response.status == 200
    end

    test "contient une clé data avec des taxes", %{body: body} do
      assert %{"data" => taxes} = body
      assert is_list(taxes)
      assert length(taxes) > 0
    end

    test "chaque taxe a les champs obligatoires", %{body: body} do
      %{"data" => taxes} = body
      for taxe <- taxes do
        assert is_integer(taxe["id"])
        assert is_number(taxe["rate"])
        assert is_binary(taxe["label"])
        assert is_boolean(taxe["is_active"])
        assert is_boolean(taxe["is_ecotax"])
      end
    end

    test "la pagination est présente", %{body: body} do
      assert %{"pagination" => pag} = body
      assert is_integer(pag["limit"])
      assert is_integer(pag["count"])
      assert is_integer(pag["total"])
    end

    test "les IDs sont uniques", %{body: body} do
      %{"data" => taxes} = body
      ids = Enum.map(taxes, & &1["id"])
      assert length(ids) == length(Enum.uniq(ids))
    end

    test "creation, verification et suppression d'une taxe" do
      # 1. Création
      body = %{rate: 7.5, label: "test TU 7.5"}
      {:ok, create_result} = Api_V2.post("taxes", body)
      assert create_result.status == 201

      {:ok, create_body} = Jason.decode(create_result.body)
      tax_id = create_body["id"]
      assert is_integer(tax_id)

      # 2. Vérification que la taxe existe bien via GET
      {:ok, get_result} = Api_V2.get("taxes/#{tax_id}", %{})
      assert get_result.status == 200

      {:ok, get_body} = Jason.decode(get_result.body)
      assert get_body["id"] == tax_id
      assert get_body["rate"] == 7.5
      assert get_body["label"] == "test TU 7.5"
      assert is_boolean(get_body["is_active"])
      assert is_boolean(get_body["is_ecotax"])

      # 4. Suppression
      {:ok, delete_result} = Api_V2.delete("taxes/#{tax_id}")
      assert delete_result.status in [200, 204]

      # 5. Vérification que la taxe n'existe plus
      {:ok, verify_result} = Api_V2.get("taxes/#{tax_id}", %{})
      assert verify_result.status == 404

      # Nettoyage de secours au cas où
      on_exit(fn ->
        Api_V2.delete("taxes/#{tax_id}")
      end)
    end

  end
    describe "Création de taxe avec données invalides" do
    test "échoue sans le champ rate requis" do
      body = %{label: "Test sans rate"}  # Manque rate (requis)
      {:ok, result} = Api_V2.post("taxes", body)
      assert result.status in [400, 422]
    # Si par erreur c'était un succès, on nettoie
    if result.status in [200, 201] do
      cleanup_taxe(result.body)
    end

    end

    test "échoue sans le champ label requis" do
      body = %{rate: 10.0}  # Manque label (requis)
      {:ok, result} = Api_V2.post("taxes", body)
      assert result.status in [400, 422]

    end

    test "échoue avec rate négatif" do
      body = %{rate: -5.0, label: "Test rate négatif"}
      {:ok, result} = Api_V2.post("taxes", body)
      assert result.status in [400, 422]
      # Si par erreur c'était un succès, on nettoie
      if result.status in [200, 201] do
        cleanup_taxe(result.body)
      end
    end

    test "échoue avec rate trop élevé - KNOWN API BUG" do
      body = %{rate: 1000.0, label: "Test rate trop élevé"}
      {:ok, result} = Api_V2.post("taxes", body)
      assert result.status in [400, 422]
            # Si par erreur c'était un succès, on nettoie
      if result.status in [200, 201] do
        cleanup_taxe(result.body)
      end
    end

    test "échoue avec label vide - KNOWN API BUG" do
      body = %{rate: 10.0, label: ""}
      {:ok, result} = Api_V2.post("taxes", body)
      assert result.status in [400, 422]
            # Si par erreur c'était un succès, on nettoie
      if result.status in [200, 201] do
        cleanup_taxe(result.body)
      end
    end

    test "échoue avec label trop long" do
      long_label = String.duplicate("a", 256)  # Supposons une limite de 255 chars
      body = %{rate: 10.0, label: long_label}
      {:ok, result} = Api_V2.post("taxes", body)
      assert result.status in [400, 422]
            # Si par erreur c'était un succès, on nettoie
      if result.status in [200, 201] do
        cleanup_taxe(result.body)
      end
    end
  end

  describe "Format des réponses d'erreur" do
  test "erreur 404 sur taxe inexistante" do
    {:ok, result} = Api_V2.get("taxes/999999999")
    assert result.status == 404

  end

  test "erreur 404 sur suppression taxe inexistante" do
    {:ok, result} = Api_V2.delete("taxes/999999999")
    assert result.status == 404
  end

  test "structure cohérente des erreurs" do
    body = %{label: "Test sans rate"}  # Rate manquant
    {:ok, result} = Api_V2.post("taxes", body)

    {:ok, error_body} = Jason.decode(result.body)

    # Vérifie que l'erreur a une structure cohérente
    assert is_map(error_body)
    # Soit un message, soit un code d'erreur, soit les deux
    assert Map.has_key?(error_body, "message") || Map.has_key?(error_body, "error") || Map.has_key?(error_body, "code")
  end

  defp cleanup_taxe(response_body) do
    {:ok, parsed} = Jason.decode(response_body)
    taxe_id = parsed["id"]
    Api_V2.delete("taxes/#{taxe_id}")
  end
end
end
