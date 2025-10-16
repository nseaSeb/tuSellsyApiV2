# Sellsy API v2 Real Unit Testing Framework

## 📊 Testing Status

![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/nseaSeb/tuSellsyApiV2/.github/workflows/ci.yml)
![Tests](https://img.shields.io/badge/tests-real_API_calls-blue)

🧪 **No mocks, real API testing** for Sellsy API v2 using Elixir. Built to validate endpoints with actual HTTP calls and dedicated test account isolation.


## 🎯 Why Real API Testing?

Traditional mock-based testing has limitations:
- **Mocks hide integration bugs**
- **API contract changes break production, not tests**
- **No validation of actual HTTP responses**

This framework uses a **dedicated Sellsy test account** with:
- **Delete-what-you-create** cleanup strategy
- **Post-deletion 404 verification**
- **Rate limiting awareness** for CI
- **Full CRUD lifecycle validation**

## 🚀 Quick Start

### 1. Setup Configuration
Copy and configure your Sellsy test credentials:

```bash
cp config/config-sample.exs config/dev.exs
# Edit config/dev.exs with your test account credentials
```

Required config:
```elixir
config :tu_sellsy_api_v2, Api_V2,
  consumer_key: System.get_env("SELLSY_CONSUMER_KEY"),
  consumer_secret: System.get_env("SELLSY_CONSUMER_SECRET"),
  # ... OAuth credentials
```

### 2. Install Dependencies
```bash
mix deps.get
```

### 3. Run Tests
```bash
# Single test suite
mix test

# Verbose output
mix test --trace

# Specific test file
mix test test/api/taxes_test.exs

# With supervision (recommended)
mix tu --sup
```

## 🧪 Testing Philosophy

### Real API, Real Confidence
```elixir
# Complete CRUD lifecycle in a single test
test "full tax CRUD lifecycle" do
  # 1. CREATE → 2. VERIFY → 3. LIST → 4. DELETE → 5. VERIFY GONE
  {:ok, create_result} = Api_V2.post("taxes", %{rate: 7.5, label: "test"})
  tax_id = create_body["id"]

  # Verify creation
  {:ok, get_result} = Api_V2.get("taxes/#{tax_id}")
  assert get_result.status == 200

  # Verify in list
  {:ok, list_result} = Api_V2.get("taxes")
  assert Enum.find(list_result["data"], &(&1["id"] == tax_id))

  # Cleanup with verification
  {:ok, delete_result} = Api_V2.delete("taxes/#{tax_id}")
  {:ok, verify_result} = Api_V2.get("taxes/#{tax_id}")
  assert verify_result.status == 404  # 🎯 Key validation
end
```

### Key Features
- ✅ **No mocks** - Tests actual Sellsy API v2
- ✅ **Atomic cleanup** - Delete-what-you-create
- ✅ **Rate limiting** - Strategic delays for quotas
- ✅ **Elixir supervision** - Robust OAuth token management

## 🛠 Tech Stack

- **Elixir** + **ExUnit** - Clean testing with pattern matching
- **Tesla** - HTTP client with middleware support
- **Jason** - JSON encoding/decoding
- **OauthClient** - Token management with supervision

## 📋 Test Coverage Examples

### Taxes Endpoint (`test/api/taxes_test.exs`)
- **GET /taxes** - Pagination, data structure validation
- **POST /taxes** - Creation with validation
- **GET /taxes/:id** - Single resource retrieval
- **DELETE /taxes/:id** - Cleanup verification
- **Edge cases** - Invalid data, missing fields

### Testing Pattern
1. **Baseline** - GET initial state
2. **Create** - POST with test data
3. **Verify** - GET single + list membership
4. **Cleanup** - DELETE + 404 assertion
5. **Safety** - `on_exit` fallback

## ⚙️ Rate Limiting & CI

- **200ms delays** between API calls (configurable)
- **OAuth token caching** via supervised GenServer


## 📚 Sellsy API Documentation
- [Official Sellsy API v2](https://help.sellsy.com/fr/collections/3289358-api)



## 👨‍💻 Author
**Sébastien** - [GitHub](https://github.com/nseaSeb)

---

*Built with ❤️ for real API testing enthusiasts*