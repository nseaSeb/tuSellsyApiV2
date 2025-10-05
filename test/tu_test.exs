defmodule TuTest do
  use ExUnit.Case
  doctest Tu

  setup do
    # Démarre le GenServer pour ce test
    start_supervised!(OauthClient)
    :ok
  end

  test "Bienvenue dans le script de tests API" do
    assert Tu.hello() == :world
  end

  test "récupère un token valide" do
    assert {:ok, token} = OauthClient.get_token()
    assert is_binary(token)
  end
end
