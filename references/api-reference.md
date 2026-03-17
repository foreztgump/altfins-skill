# altFINS Public API Reference (v2)

## Base URL

```
https://altfins.com
```

## Authentication

All endpoints require an API key passed via the `X-API-KEY` header.

```
X-API-KEY: <your-api-key>
```

Obtain your key from the altFINS portal profile page. Some endpoints require a paid plan. Use the permits endpoints to check your remaining rate-limit credits.

---

## Pagination (common query parameters)

Most list endpoints accept these query parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `page` | integer (>= 0) | No | Zero-based page index |
| `size` | integer (>= 1) | No | Items per page |
| `sort` | string[] | No | Sort fields (e.g., `["timestamp,desc"]`) |

Paginated responses share this envelope:

```json
{
  "size": 20,
  "number": 0,
  "totalElements": 1542,
  "totalPages": 78,
  "numberOfElements": 20,
  "first": true,
  "last": false,
  "sort": [],
  "content": [ ... ]
}
```

---

## Error Response Schema

All error responses follow this structure:

```json
{
  "timestamp": "2026-01-15T10:30:00Z",
  "status": 400,
  "error": "Bad Request",
  "message": "Validation failed",
  "request": "/api/v2/public/screener-data/search-requests",
  "exceptionUID": "abc-123",
  "details": {},
  "validations": []
}
```

HTTP status codes: `400` (Bad Request), `401` (Unauthorized), `403` (Forbidden), `500` (Internal Server Error), `503` (Service Unavailable).

---

# 1. Screener Data

## 1.1 Get Screener Market Data

Filter and discover crypto assets using custom criteria (price performance, volume, market cap, indicators, patterns).

```
POST /api/v2/public/screener-data/search-requests?page=0&size=20&sort=[]
```

### Request Body (`ScreenerSearchRequest`)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `symbols` | string[] | No | Filter to specific symbols. Empty = all. Example: `["BTC","ETH"]` |
| `timeInterval` | string | No | Time interval. Default: `DAILY`. See [timeInterval enum](#timeinterval) |
| `displayType` | string[] | No | Data columns to return. Default: `["SYMBOL","NAME","LAST_PRICE"]`. See [displayType enum](#displaytype-screener-columns) |
| `numericFilters` | NumericFilter[] | No | Numeric range filters (AND logic). See [NumericFilter](#numericfilter) |
| `signalFilters` | SignalFilter[] | No | Trend signal filters (AND logic). See [SignalFilter](#signalfilter) |
| `crossAnalyticFilters` | CrossAnalyticFilter[] | No | Crossover filters (AND logic). See [CrossAnalyticFilter](#crossanalyticfilter) |
| `candlestickPatternFilters` | CandlestickPatternFilter[] | No | Candlestick pattern filters (AND logic). See [CandlestickPatternFilter](#candlestickpatternfilter) |
| `analyticsComparisonsFilters` | AnalyticsComparisonsFilter[] | No | Compare two analytics (AND logic). See [AnalyticsComparisonsFilter](#analyticscomparisonsfilter) |
| `coinTypeFilter` | string | No | Coin type. See [coinTypeFilter enum](#cointypefilter) |
| `coinCategoryFilter` | string[] | No | Market segments. See [coinCategoryFilter enum](#coincategoryfilter) |
| `tradingTypeFilter` | string[] | No | Trading type. See [tradingTypeFilter enum](#tradingtypefilter) |
| `exchangeFilter` | string[] | No | Exchange filter. See [exchangeFilter enum](#exchangefilter) |
| `athDateBeforeFilter` | string (ISO-8601) | No | ATH date on or before this timestamp |
| `athDateAfterFilter` | string (ISO-8601) | No | ATH date on or after this timestamp |
| `percentDownFromAthFilter` | string | No | Distance from ATH. See [percentDownFromAthFilter enum](#percentdownfromathfilter) |
| `supportResistanceFilter` | string | No | S/R level filter. See [supportResistanceFilter enum](#supportresistancefilter) |
| `supportResistanceLookBackIntervals` | string | No | Lookback periods for S/R: `"1"` - `"5"`. Default `"5"` |
| `weekAnalytics52Filter` | string | No | 52-week analytics. See [weekAnalytics52Filter enum](#weekanalytics52filter) |
| `rsiDivergenceFilter` | string | No | RSI divergence type. See [rsiDivergenceFilter enum](#rsidivergencefilter) |
| `newLowInLastPeriodFilter` | string | No | New low in last N periods. See [newLowInLastPeriodFilter enum](#newlowinlastperiodfilter) |
| `newHighInLastPeriodFilter` | string | No | New high in last N periods. See [newHighInLastPeriodFilter enum](#newhighinlastperiodfilter) |
| `macdFilter` | string | No | MACD vs Signal Line: `"BUY"` or `"SELL"` |
| `macdHistogramFilter` | string | No | MACD histogram direction. See [macdHistogramFilter enum](#macdhistogramfilter) |
| `minimumMarketCapValue` | number | No | Minimum market cap value |

### Response: `PageableResponse<ScreenerSearchResult>`

Each item in `content`:

| Field | Type | Description |
|-------|------|-------------|
| `symbol` | string | Symbol ticker (e.g., `"BTC"`) |
| `name` | string | Friendly name (e.g., `"Bitcoin"`) |
| `lastPrice` | string | Current price as string |
| `additionalData` | object | Map of requested displayType keys to their values |

### Example Request

```bash
curl -X POST "https://altfins.com/api/v2/public/screener-data/search-requests?page=0&size=5" \
  -H "X-API-KEY: your-key" \
  -H "Content-Type: application/json" \
  -d '{
    "symbols": [],
    "timeInterval": "DAILY",
    "displayType": ["MARKET_CAP", "RSI14", "SHORT_TERM_TREND"],
    "numericFilters": [
      {"numericFilterType": "RSI14", "lteFilter": 30}
    ],
    "signalFilters": [
      {"signalFilterType": "SHORT_TERM_TREND", "signalFilterValue": "UP"}
    ],
    "coinTypeFilter": "REGULAR",
    "minimumMarketCapValue": 10000000
  }'
```

### Example Response

```json
{
  "size": 5,
  "number": 0,
  "totalElements": 42,
  "totalPages": 9,
  "numberOfElements": 5,
  "first": true,
  "last": false,
  "sort": [],
  "content": [
    {
      "symbol": "ETH",
      "name": "Ethereum",
      "lastPrice": "3245.67",
      "additionalData": {
        "MARKET_CAP": "389000000000",
        "RSI14": "28.5",
        "SHORT_TERM_TREND": "UP"
      }
    }
  ]
}
```

---

## 1.2 Get Screener Market Data Types

Returns all available data types for use in `displayType`.

```
GET /api/v2/public/screener-data/value-types
```

### Response: `ValueTypeDto[]`

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Type identifier (e.g., `"PERFORMANCE"`) |
| `friendlyName` | string | Human-readable name (e.g., `"Price change"`) |

### Example Request

```bash
curl "https://altfins.com/api/v2/public/screener-data/value-types" \
  -H "X-API-KEY: your-key"
```

### Example Response

```json
[
  {"id": "PERFORMANCE", "friendlyName": "Price change"},
  {"id": "MARKET_CAP", "friendlyName": "Market Cap"},
  {"id": "RSI14", "friendlyName": "RSI 14"}
]
```

---

# 2. OHLC Data

## 2.1 Get OHLC Snapshot

Retrieves current OHLC data for specified symbols. If `symbols` is empty, returns data for all available symbols.

```
POST /api/v2/public/ohlcv/snapshot-requests
```

### Request Body (`OHLCVSnapshotRequest`)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `symbols` | string[] | Yes | Symbol names. Empty array = all symbols. Example: `["BTC"]` |
| `timeInterval` | string | No | Time interval. Default: `"DAILY"`. See [timeInterval enum](#timeinterval) |

### Response: `PublicOHLCVData[]`

| Field | Type | Description |
|-------|------|-------------|
| `symbol` | string | Symbol ticker |
| `time` | string (date-time) | ISO timestamp |
| `open` | string | Open price |
| `high` | string | High price |
| `low` | string | Low price |
| `close` | string | Close price |
| `volume` | string | Volume |

### Example Request

```bash
curl -X POST "https://altfins.com/api/v2/public/ohlcv/snapshot-requests" \
  -H "X-API-KEY: your-key" \
  -H "Content-Type: application/json" \
  -d '{
    "symbols": ["BTC", "ETH"],
    "timeInterval": "DAILY"
  }'
```

### Example Response

```json
[
  {
    "symbol": "BTC",
    "time": "2026-03-15T00:00:00Z",
    "open": "84521.30",
    "high": "85200.00",
    "low": "83900.50",
    "close": "84950.75",
    "volume": "15234567890.50"
  },
  {
    "symbol": "ETH",
    "time": "2026-03-15T00:00:00Z",
    "open": "3210.45",
    "high": "3275.80",
    "low": "3190.20",
    "close": "3250.60",
    "volume": "8234567890.25"
  }
]
```

---

## 2.2 Get Historical OHLC Data

Retrieve historical OHLC time-series for a specific asset within a date range.

```
POST /api/v2/public/ohlcv/history-requests?page=0&size=20&sort=[]
```

### Request Body (`OHLCVHistoryRequest`)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `symbol` | string | Yes | Symbol name (e.g., `"BTC"`) |
| `timeInterval` | string | Yes | Time interval. Default: `"DAILY"` |
| `from` | string (ISO-8601 date-time) | No | Lower bound (inclusive): `"2026-01-01T00:00:00.000Z"` |
| `to` | string (ISO-8601 date-time) | No | Upper bound (inclusive): `"2026-01-08T00:00:00.000Z"` |

### Response: `PageableResponse<PublicOHLCVData>`

Same `PublicOHLCVData` fields as snapshot above, wrapped in pagination envelope.

### Example Request

```bash
curl -X POST "https://altfins.com/api/v2/public/ohlcv/history-requests?page=0&size=10" \
  -H "X-API-KEY: your-key" \
  -H "Content-Type: application/json" \
  -d '{
    "symbol": "BTC",
    "timeInterval": "DAILY",
    "from": "2026-03-01T00:00:00.000Z",
    "to": "2026-03-15T00:00:00.000Z"
  }'
```

### Example Response

```json
{
  "size": 10,
  "number": 0,
  "totalElements": 15,
  "totalPages": 2,
  "numberOfElements": 10,
  "first": true,
  "last": false,
  "sort": [],
  "content": [
    {
      "symbol": "BTC",
      "time": "2026-03-01T00:00:00Z",
      "open": "82100.50",
      "high": "83500.00",
      "low": "81800.25",
      "close": "83200.75",
      "volume": "14500000000.00"
    }
  ]
}
```

---

# 3. Analytics

## 3.1 Get Historical Analytics Data

Retrieves historical analytics data for a specific cryptocurrency symbol and metric.

```
POST /api/v2/public/analytics/search-requests?page=0&size=20&sort=[]
```

### Request Body (`AltfinsAnalyticsHistorySearchRequest`)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `symbol` | string | Yes | Symbol name (e.g., `"BTC"`) |
| `analyticsType` | string | Yes | Analytics metric. See [analyticsType enum](#analyticstype) |
| `timeInterval` | string | No | Default: `"DAILY"`. Values: `MINUTES15`, `HOURLY`, `HOURS4`, `HOURS12`, `DAILY` |
| `from` | string (ISO-8601) | No | Lower bound (inclusive) |
| `to` | string (ISO-8601) | No | Upper bound (inclusive) |

### Response: `PageableResponse<AnalyticsHistoryData>`

Each item in `content`:

| Field | Type | Description |
|-------|------|-------------|
| `symbol` | string | Symbol name |
| `time` | string (date-time) | Timestamp |
| `value` | string | Numeric analytics value |
| `nonNumericalValue` | string | Non-numeric value for categorical metrics (e.g., `"OVERSOLD"`, `"BUY"`, `"UP"`) |

Possible `nonNumericalValue` values: `NUMERICAL`, `BUY`, `STRONG_BUY`, `SELL`, `STRONG_SELL`, `NEUTRAL`, `BEARISH`, `HIDDEN_BEARISH`, `BULLISH`, `HIDDEN_BULLISH`, `OVERBOUGHT`, `OVERSOLD`, `VERY_OVERSOLD`, `VERY_OVERBOUGHT`, `PEAK`, `TROUGH`, `UP`, `DOWN`, `STRONG`, `VERY_STRONG`, `WEAK`, `VERY_WEAK`, `TRUE`, `FALSE`, `BEARISH_AND_HIDDEN_BULLISH`, `BULLISH_AND_HIDDEN_BEARISH`, `ABOVE`, `BELOW`.

### Example Request

```bash
curl -X POST "https://altfins.com/api/v2/public/analytics/search-requests?page=0&size=5" \
  -H "X-API-KEY: your-key" \
  -H "Content-Type: application/json" \
  -d '{
    "symbol": "BTC",
    "analyticsType": "RSI14",
    "timeInterval": "DAILY",
    "from": "2026-03-01T00:00:00.000Z",
    "to": "2026-03-15T00:00:00.000Z"
  }'
```

### Example Response

```json
{
  "size": 5,
  "number": 0,
  "totalElements": 15,
  "totalPages": 3,
  "numberOfElements": 5,
  "first": true,
  "last": false,
  "sort": [],
  "content": [
    {
      "symbol": "BTC",
      "time": "2026-03-01T00:00:00Z",
      "value": "45.32",
      "nonNumericalValue": null
    },
    {
      "symbol": "BTC",
      "time": "2026-03-02T00:00:00Z",
      "value": "48.91",
      "nonNumericalValue": null
    }
  ]
}
```

---

## 3.2 Get Analytic Types

Browse 150+ available analytical metrics before requesting data.

```
GET /api/v2/public/analytics/types
```

### Response: `AnalyticsTypeDto[]`

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Type identifier (e.g., `"SMA10"`) |
| `friendlyName` | string | Human-readable name (e.g., `"SMA 10"`) |
| `isNumerical` | boolean | `true` if metric has numeric values; `false` for categorical |

### Example Request

```bash
curl "https://altfins.com/api/v2/public/analytics/types" \
  -H "X-API-KEY: your-key"
```

### Example Response

```json
[
  {"id": "PERFORMANCE", "friendlyName": "Price Change", "isNumerical": true},
  {"id": "SHORT_TERM_TREND", "friendlyName": "Short-term Trend", "isNumerical": false},
  {"id": "RSI14", "friendlyName": "RSI 14", "isNumerical": true}
]
```

---

# 4. Technical Analysis

## 4.1 Get Technical Analysis

Access curated, expert-led trade setups for 50+ major cryptocurrencies, including entry zones, exit targets, stop-loss levels, and technical reasoning.

```
GET /api/v2/public/technical-analysis/data?symbol=BTC&page=0&size=20&sort=[]
```

### Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `symbol` | string | No | Cryptocurrency symbol (e.g., `"BTC"`). Empty = all |
| `page` | integer | No | Page index (0-based) |
| `size` | integer | No | Items per page |
| `sort` | string[] | No | Sort fields |

### Response: `PageableResponse<TechnicalAnalysisSummary>`

Each item in `content`:

| Field | Type | Description |
|-------|------|-------------|
| `symbol` | string | Symbol ticker |
| `friendlyName` | string | Full name (e.g., `"Bitcoin"`) |
| `updatedDate` | string (date-time) | Last update timestamp |
| `nearTermOutlook` | string | Market outlook (e.g., `"Bullish"`, `"Bearish"`) |
| `patternType` | string | Chart pattern identified |
| `patternStage` | string | Pattern stage |
| `description` | string | Full analysis text with entry/exit/stop-loss details |
| `imgChartUrl` | string | Chart image URL (light theme) |
| `imgChartUrlDark` | string | Chart image URL (dark theme) |
| `logoUrl` | string | Coin logo URL |

### Example Request

```bash
curl "https://altfins.com/api/v2/public/technical-analysis/data?symbol=BTC&page=0&size=5" \
  -H "X-API-KEY: your-key"
```

### Example Response

```json
{
  "size": 5,
  "number": 0,
  "totalElements": 3,
  "totalPages": 1,
  "numberOfElements": 3,
  "first": true,
  "last": true,
  "sort": [],
  "content": [
    {
      "symbol": "BTC",
      "friendlyName": "Bitcoin",
      "updatedDate": "2026-03-14T12:00:00Z",
      "nearTermOutlook": "Bullish",
      "patternType": "Ascending Triangle",
      "patternStage": "Breakout",
      "description": "BTC is forming an ascending triangle pattern...",
      "imgChartUrl": "https://altfins.com/charts/btc-light.png",
      "imgChartUrlDark": "https://altfins.com/charts/btc-dark.png",
      "logoUrl": "https://altfins.com/logos/btc.png"
    }
  ]
}
```

---

# 5. Signals Feed

## 5.1 Get Signals Feed Data

Fetches trading signals generated by the altFINS platform. Helps spot new trade opportunities without manually scanning the market.

```
POST /api/v2/public/signals-feed/search-requests?page=0&size=20&sort=[]
```

### Request Body (`ApiSignalFeedFilterRequest`)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `symbols` | string[] | No | Filter to specific symbols. Empty = all. Example: `["BTC","ETH"]` |
| `signals` | string[] | No | Filter to specific signal keys. Empty = all. See [signals enum](#signal-keys) |
| `signalDirection` | string | No | `"BULLISH"` or `"BEARISH"` |
| `fromDate` | string (ISO-8601 date-time) | No | Start datetime. Example: `"2025-11-17T11:00:00Z"` |
| `toDate` | string (ISO-8601 date-time) | No | End datetime. Example: `"2025-11-17T11:00:00Z"` |

### Response: `PageableResponse<ApiSignalFeed>`

Each item in `content`:

| Field | Type | Description |
|-------|------|-------------|
| `timestamp` | string (date-time) | Signal generation time |
| `direction` | string | `"BULLISH"` or `"BEARISH"` |
| `signalKey` | string | Signal identifier |
| `signalName` | string | Human-readable signal name |
| `symbol` | string | Symbol ticker |
| `symbolName` | string | Full asset name |
| `lastPrice` | string | Price at signal time |
| `marketCap` | string | Market cap at signal time |
| `priceChange` | string | Recent price change |

### Example Request

```bash
curl -X POST "https://altfins.com/api/v2/public/signals-feed/search-requests?page=0&size=5" \
  -H "X-API-KEY: your-key" \
  -H "Content-Type: application/json" \
  -d '{
    "symbols": ["BTC", "ETH"],
    "signals": ["SIGNALS_SUMMARY_SMA_50_200", "SIGNALS_SUMMARY_RSI_14"],
    "signalDirection": "BULLISH",
    "fromDate": "2026-03-01T00:00:00Z",
    "toDate": "2026-03-15T23:59:59Z"
  }'
```

### Example Response

```json
{
  "size": 5,
  "number": 0,
  "totalElements": 12,
  "totalPages": 3,
  "numberOfElements": 5,
  "first": true,
  "last": false,
  "sort": [],
  "content": [
    {
      "timestamp": "2026-03-14T08:00:00Z",
      "direction": "BULLISH",
      "signalKey": "SIGNALS_SUMMARY_SMA_50_200",
      "signalName": "SMA 50/200 Golden Cross",
      "symbol": "BTC",
      "symbolName": "Bitcoin",
      "lastPrice": "84500.00",
      "marketCap": "1670000000000",
      "priceChange": "2.35"
    }
  ]
}
```

---

## 5.2 Get Signal Keys

Returns all valid signal identifiers for filtering the signals feed.

```
GET /api/v2/public/signals-feed/signal-keys
```

### Response: `SignalLabelDTO[]`

| Field | Type | Description |
|-------|------|-------------|
| `signalKey` | string | Signal identifier |
| `signalType` | string | Signal category |
| `nameBullish` | string | Bullish signal name |
| `nameBearish` | string | Bearish signal name |
| `trendSensitive` | boolean | Whether signal is trend-sensitive |

### Example Request

```bash
curl "https://altfins.com/api/v2/public/signals-feed/signal-keys" \
  -H "X-API-KEY: your-key"
```

### Example Response

```json
[
  {
    "signalKey": "SIGNALS_SUMMARY_SMA_50_200",
    "signalType": "MA_CROSSOVER",
    "nameBullish": "SMA 50/200 Golden Cross",
    "nameBearish": "SMA 50/200 Death Cross",
    "trendSensitive": false
  }
]
```

---

# 6. News Summary

## 6.1 Get News Summaries

Query pre-processed summaries of market news articles with NLP-extracted key information.

```
POST /api/v2/public/news-summary/search-requests?page=0&size=20&sort=[]
```

### Request Body (`ApiNewsSummaryFilterRequest`)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `fromDate` | string (ISO-8601 date-time) | No | Start datetime. Example: `"2025-11-17T11:00:00Z"` |
| `toDate` | string (ISO-8601 date-time) | No | End datetime. Example: `"2025-11-17T11:00:00Z"` |

### Response: `PageableResponse<ApiNewsSummary>`

Each item in `content`:

| Field | Type | Description |
|-------|------|-------------|
| `messageId` | integer (int64) | Unique message identifier |
| `sourceId` | integer (int32) | Source identifier |
| `title` | string | Article title |
| `content` | string | Summarized content |
| `url` | string | Original article URL |
| `sourceName` | string | News source name |
| `timestamp` | string (date-time) | Publication time |

### Example Request

```bash
curl -X POST "https://altfins.com/api/v2/public/news-summary/search-requests?page=0&size=5" \
  -H "X-API-KEY: your-key" \
  -H "Content-Type: application/json" \
  -d '{
    "fromDate": "2026-03-14T00:00:00Z",
    "toDate": "2026-03-15T23:59:59Z"
  }'
```

### Example Response

```json
{
  "size": 5,
  "number": 0,
  "totalElements": 87,
  "totalPages": 18,
  "numberOfElements": 5,
  "first": true,
  "last": false,
  "sort": [],
  "content": [
    {
      "messageId": 123456,
      "sourceId": 7,
      "title": "Bitcoin Breaks Above Key Resistance Level",
      "content": "Bitcoin has surged past the $85,000 resistance...",
      "url": "https://example.com/article/123456",
      "sourceName": "CryptoNews",
      "timestamp": "2026-03-14T14:30:00Z"
    }
  ]
}
```

---

## 6.2 Find News Summary

Fetch a single news summary by its MessageId and SourceId.

```
POST /api/v2/public/news-summary/find-summary?MessageId=123456&SourceId=7
```

### Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `MessageId` | integer (int64) | Yes | Message identifier |
| `SourceId` | integer (int32) | Yes | Source identifier |

### Response: `ApiNewsSummary`

Same schema as items in the news list (see 6.1 above).

### Example Request

```bash
curl -X POST "https://altfins.com/api/v2/public/news-summary/find-summary?MessageId=123456&SourceId=7" \
  -H "X-API-KEY: your-key"
```

### Example Response

```json
{
  "messageId": 123456,
  "sourceId": 7,
  "title": "Bitcoin Breaks Above Key Resistance Level",
  "content": "Bitcoin has surged past the $85,000 resistance...",
  "url": "https://example.com/article/123456",
  "sourceName": "CryptoNews",
  "timestamp": "2026-03-14T14:30:00Z"
}
```

---

# 7. Common Enums / Utility Endpoints

## 7.1 Get Available Symbols

Returns all possible symbols (coin identifiers) used by other endpoints.

```
GET /api/v2/public/symbols
```

### Response: `AssetInfo[]`

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Symbol ticker (e.g., `"ETH"`) |
| `friendlyName` | string | Full name (e.g., `"Ethereum"`) |

### Example Request

```bash
curl "https://altfins.com/api/v2/public/symbols" \
  -H "X-API-KEY: your-key"
```

### Example Response

```json
[
  {"name": "BTC", "friendlyName": "Bitcoin"},
  {"name": "ETH", "friendlyName": "Ethereum"},
  {"name": "SOL", "friendlyName": "Solana"}
]
```

---

## 7.2 Get Available Time Intervals

Returns all possible time intervals.

```
GET /api/v2/public/intervals
```

### Response: `string[]`

```json
["MINUTES15", "HOURLY", "HOURS4", "HOURS12", "DAILY"]
```

---

## 7.3 Get Available Permits (Rate Limit)

Return count of your currently available per-request rate-limit permits.

```
GET /api/v2/public/available-permits
```

### Response: `integer (int64)`

---

## 7.4 Get Monthly Available Permits

Return count of your currently available monthly credits.

```
GET /api/v2/public/monthly-available-permits
```

### Response: `integer (int64)`

---

## 7.5 Get All Available Permits

Return both per-request and monthly permit counts in a single request.

```
GET /api/v2/public/all-available-permits
```

### Response: `PermitsInfo`

| Field | Type | Description |
|-------|------|-------------|
| `availablePermits` | integer (int64) | Per-request rate-limit permits remaining |
| `monthlyAvailablePermits` | integer (int64) | Monthly credits remaining |

### Example Response

```json
{
  "availablePermits": 95,
  "monthlyAvailablePermits": 4820
}
```

---

# 8. Authentication (v1)

## 8.1 Authenticate (JWT)

Returns JWT access and refresh tokens. **Note:** For most use cases the API key approach (`X-API-KEY` header) is simpler.

```
POST /api/v1/authenticate
```

### Headers

| Header | Required | Description |
|--------|----------|-------------|
| `Authorization` | Yes | Basic auth credentials |
| `X-Authentication-Type` | Yes | Auth type: `EM`, `FB`, `TW`, `GG`, `KC`, `GMFA`, `SMSMFA` |
| `X-Referral-Id` | No | Referral ID (int32) |
| `X-Referral-Type` | No | `AFFILIATE`, `BOUNTY_COOKIE`, `BOUNTY` |

### Response: `JwtTokens`

| Field | Type | Description |
|-------|------|-------------|
| `accessToken` | string | Short-lived JWT for API access |
| `refreshToken` | string | Long-lived JWT for token refresh (single use) |

---

# 9. Filter Object Schemas

## NumericFilter

Filter screener results by numeric range. Multiple filters use AND logic.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `numericFilterType` | string | No | Metric to filter. See [numericFilterType enum](#numericfiltertype) |
| `gteFilter` | number | No | Greater than or equal |
| `lteFilter` | number | No | Less than or equal |

```json
{"numericFilterType": "RSI14", "lteFilter": 30}
```

---

## SignalFilter

Filter by trend signal value. Multiple filters use AND logic.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `signalFilterType` | string | No | `SHORT_TERM_TREND`, `MEDIUM_TERM_TREND`, or `LONG_TERM_TREND` |
| `signalFilterValue` | string | No | See [signalFilterValue enum](#signalfiltervalue) |

```json
{"signalFilterType": "SHORT_TERM_TREND", "signalFilterValue": "STRONG_UP"}
```

---

## CrossAnalyticFilter

Filter by MA/indicator crossovers. Multiple filters use AND logic.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `crossAnalyticFilterType` | string | No | Crossover type. See [crossAnalyticFilterType enum](#crossanalyticfiltertype) |
| `crossAnalyticFilterValue` | string | No | `"ABOVE"` or `"BELOW"` |
| `crossLookBackIntervals` | string | Yes | Lookback periods: `"1"` - `"5"`. Default `"5"` |

```json
{"crossAnalyticFilterType": "X_LAST_PRICE_CROSS_SMA50", "crossAnalyticFilterValue": "ABOVE", "crossLookBackIntervals": "3"}
```

---

## CandlestickPatternFilter

Filter by candlestick pattern. Multiple filters use AND logic.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `candlestickPatternFilterType` | string | No | Pattern type. See [candlestickPatternFilterType enum](#candlestickpatternfiltertype) |
| `candlestickLookBackIntervals` | string | Yes | Lookback periods: `"1"` - `"5"` |

```json
{"candlestickPatternFilterType": "CD_HAMMER", "candlestickLookBackIntervals": "2"}
```

---

## AnalyticsComparisonsFilter

Compare two analytics metrics. Multiple filters use AND logic.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `analyticsComparisonsFilterType` | string | No | Comparison type (456 combinations). Format: `{METRIC_A}_VS_{METRIC_B}` or `{METRIC_A}_TREND_VS_{METRIC_B}_TREND` |
| `analyticsComparisonsFilterValue` | string | No | `"ABOVE"` or `"BELOW"` |

```json
{"analyticsComparisonsFilterType": "LAST_PRICE_VS_SMA50", "analyticsComparisonsFilterValue": "ABOVE"}
```

---

# 10. Enum Reference

## timeInterval

Used by: Screener, OHLC, Analytics

| Value | Description |
|-------|-------------|
| `MINUTES15` | 15-minute intervals |
| `HOURLY` | 1-hour intervals |
| `HOURS4` | 4-hour intervals |
| `HOURS12` | 12-hour intervals |
| `DAILY` | Daily intervals (default) |

---

## signalDirection

Used by: Signals Feed filter

| Value |
|-------|
| `BULLISH` |
| `BEARISH` |

---

## coinTypeFilter

Used by: Screener

| Value | Description |
|-------|-------------|
| `REGULAR` | Standard crypto assets |
| `STABLE` | Stablecoins |
| `LEVERAGED` | Leveraged tokens |

---

## coinCategoryFilter

Used by: Screener. Items must belong to ALL selected categories (AND logic).

| Value |
|-------|
| `AI_BIG_DATA` |
| `AI_AGENTS` |
| `ANIMAL_MEMES` |
| `ARBITRUM_ECOSYSTEM` |
| `AVALANCHE_ECOSYSTEM` |
| `BASE_ECOSYSTEM` |
| `BINANCE_ALPHA` |
| `BINANCE_ALPHA_AIRDROPS` |
| `BINANCE_ECOSYSTEM` |
| `BITCOIN_ECOSYSTEM` |
| `BNB_CHAIN_ECOSYSTEM` |
| `CAT_THEMED` |
| `COLLECTIBLES_AND_NFTS` |
| `COMMUNICATIONS_AND_SOCIAL_MEDIA` |
| `DAO` |
| `DECENTRALIZED_EXCHANGE_DEX_TOKEN` |
| `DEFI` |
| `DEPIN` |
| `DOGGONE_DOGGEREL` |
| `DWF_LABS_PORTFOLIO` |
| `ETHEREUM_ECOSYSTEM` |
| `FANTOM_ECOSYSTEM` |
| `GAMING` |
| `GOVERNANCE` |
| `MARKETPLACE` |
| `MEMES` |
| `METAVERSE` |
| `NFTS_AND_COLLECTIBLES` |
| `PLAY_TO_EARN` |
| `POLITICAL_MEMES` |
| `POLYGON_ECOSYSTEM` |
| `PRIVACY` |
| `PUMP_FUN_ECOSYSTEM` |
| `REAL_WORLD_ASSETS_PROTOCOLS` |
| `REHYPOTHECATED_CRYPTO` |
| `SMART_CONTRACTS` |
| `SOLANA_ECOSYSTEM` |
| `STABLECOIN` |
| `TOKENIZED_ASSETS` |
| `TOKENIZED_STOCK` |
| `YIELD_FARMING` |

---

## tradingTypeFilter

Used by: Screener

| Value |
|-------|
| `SPOT` |
| `FUTURES` |
| `PERPETUAL` |
| `FUTURES_OR_PERPETUAL` |

---

## exchangeFilter

Used by: Screener. When used with `tradingTypeFilter`, coins must be tradable on ALL specified exchanges in ALL specified trading types. Default trading type is `SPOT`.

| Value |
|-------|
| `BKEX` |
| `BW` |
| `BIKI` |
| `BIGONE` |
| `BINANCE` |
| `BIT_Z` |
| `BITFOREX` |
| `BITMART` |
| `BITMAX` |
| `BITFINEX` |
| `BITGET` |
| `BITHUMB` |
| `BITRUE` |
| `BITSO` |
| `BYBIT` |
| `COINBASE` |
| `COINSBIT` |
| `CREX_24` |
| `DCOIN` |
| `DIGI_FINEX` |
| `EXMO` |
| `GATEIO` |
| `HUOBI` |
| `KRAKEN` |
| `KUCOIN` |
| `LBANK` |
| `MEXC` |
| `MXC` |
| `OKX` |
| `PROBIT_EXCHANGE` |
| `TOKENOMY` |
| `UPBIT` |
| `WHITEBIT` |

---

## signalFilterValue

Used by: Screener SignalFilter

| Value | Description |
|-------|-------------|
| `STRONG_DOWN` | Strong downtrend |
| `DOWN` | Downtrend |
| `NEUTRAL` | No clear trend |
| `UP` | Uptrend |
| `STRONG_UP` | Strong uptrend |
| `STRONG_DOWN_DOWNGRADE` | Downgraded to strong downtrend |
| `DOWN_DOWNGRADE` | Downgraded to downtrend |
| `DOWN_UPGRADE` | Upgraded from lower to downtrend |
| `NEUTRAL_DOWNGRADE` | Downgraded to neutral |
| `NEUTRAL_UPGRADE` | Upgraded to neutral |
| `UP_DOWNGRADE` | Downgraded from higher to uptrend |
| `UP_UPGRADE` | Upgraded to uptrend |
| `STRONG_UP_UPGRADE` | Upgraded to strong uptrend |

---

## numericFilterType

Used by: Screener NumericFilter (91 values)

**Price & Performance:**
`LAST_PRICE`, `PERFORMANCE`, `HIGH`, `LOW`, `PRICE_CHANGE_1D`, `PRICE_CHANGE_1W`, `PRICE_CHANGE_1M`, `PRICE_CHANGE_3M`, `PRICE_CHANGE_6M`, `PRICE_CHANGE_1Y`, `PRICE_CHANGE_YTD`

**Volume & Market Cap:**
`DOLLAR_VOLUME`, `MARKET_CAP`, `VOLUME`, `VOLUME_RELATIVE`, `OBV_TREND`, `VWMA20`, `ATH`, `DAYS_SINCE_ATH`

**Revenue (DeFi):**
`TOTAL_REVENUE_1W`, `TOTAL_REVENUE_1M`, `TOTAL_REVENUE_PERFORMANCE_7D`, `TOTAL_REVENUE_PERFORMANCE_30D`, `TOTAL_REVENUE_PERFORMANCE_90D`, `TOTAL_REVENUE_ANNUALIZED`, `PROTOCOL_REVENUE_1W`, `PROTOCOL_REVENUE_1M`, `PROTOCOL_REVENUE_PERFORMANCE_7D`, `PROTOCOL_REVENUE_PERFORMANCE_30D`, `PROTOCOL_REVENUE_PERFORMANCE_90D`, `PROTOCOL_REVENUE_ANNUALIZED`

**Valuation:**
`MARKET_CAP_SALES`, `MARKET_CAP_SALES_PERFORMANCE_7D`, `MARKET_CAP_SALES_PERFORMANCE_30D`, `MARKET_CAP_SALES_PERFORMANCE_90D`, `MARKET_CAP_PR`, `MARKET_CAP_PR_PERFORMANCE_7D`, `MARKET_CAP_PR_PERFORMANCE_30D`, `MARKET_CAP_PR_PERFORMANCE_90D`, `TVL`, `TVL_PERFORMANCE`, `TVL_PERFORMANCE_7D`, `TVL_PERFORMANCE_30D`, `TVL_PERFORMANCE_90D`, `MARKET_CAP_TVL`, `MARKET_CAP_TVL_PERFORMANCE_7D`, `MARKET_CAP_TVL_PERFORMANCE_30D`, `MARKET_CAP_TVL_PERFORMANCE_90D`

**Moving Averages (values):**
`SMA5`, `SMA10`, `SMA20`, `SMA30`, `SMA50`, `SMA100`, `SMA200`, `EMA9`, `EMA12`, `EMA13`, `EMA26`, `EMA50`, `EMA100`, `EMA200`

**Moving Average Trends:**
`SMA5_TREND`, `SMA10_TREND`, `SMA20_TREND`, `SMA30_TREND`, `SMA50_TREND`, `SMA100_TREND`, `SMA200_TREND`, `EMA9_TREND`, `EMA12_TREND`, `EMA13_TREND`, `EMA26_TREND`, `EMA50_TREND`, `EMA100_TREND`, `EMA200_TREND`

**Oscillators:**
`RSI9`, `RSI14`, `RSI25`, `STOCH`, `STOCH_SLOW`, `STOCH_RSI`, `CCI20`, `ADX`, `MOM`, `WILLIAMS`, `BULL_POWER`, `BEAR_POWER`, `ULTIMATE_OSCILLATOR`, `BOLLINGER_BAND_LOWER`, `BOLLINGER_BAND_UPPER`

---

## displayType (Screener Columns)

Used by: Screener `displayType` field. All values from [numericFilterType](#numericfiltertype) above, plus:

`ATH_PERCENT_DOWN`, `HIGH_52W`, `LOW_52W`, `SHORT_TERM_TREND`, `MEDIUM_TERM_TREND`, `LONG_TERM_TREND`, `TIME`, `ATH_DATE`, `IR_RSI9`, `IR_RSI14`, `IR_RSI25`, `IR_STOCH`, `IR_STOCH_SLOW`, `IR_WILLIAMS`, `IR_CCI20`, `IR_BANDED_OSC`, `SHORT_TERM_TREND_CHANGE`, `MEDIUM_TERM_TREND_CHANGE`, `LONG_TERM_TREND_CHANGE`, `AGE`, `PERCENTAGE_DOWN_FROM_52_WEEK_HIGH`, `PERCENTAGE_ABOVE_FROM_52_WEEK_LOW`, `ATR`, `TR_VS_ATR`, `CIRCULATING_SUPPLY`, `MACD_SIGNAL_LINE`, `OBV`, `IR_NEW_HIGH_CREATED`, `IR_NEW_LOW_CREATED`, `SUPPORT`, `RESISTANCE`, `RSI_DIVERGENCE`, `MACD`

---

## analyticsType

Used by: Analytics endpoint (146 values). All values from [displayType](#displaytype-screener-columns) above, plus additional metrics:

`DOLLAR_PRICE`, `CMC_RANK`, `CIRCULATING_SUPPLY`, `TOTAL_REVENUE`, `PROTOCOL_REVENUE`, `MARKET_CAP_FULLY_DILUTED`, `VOLUME_AVG`, `VOLUME_CHANGE`, `MACD_HISTOGRAM`, `STOCH_RSI_K`, `STOCH_RSI_D`

Plus extended performance periods: `TOTAL_REVENUE_PERFORMANCE`, `TOTAL_REVENUE_PERFORMANCE_180D`, `TOTAL_REVENUE_PERFORMANCE_365D`, `PROTOCOL_REVENUE_PERFORMANCE`, `PROTOCOL_REVENUE_PERFORMANCE_180D`, `PROTOCOL_REVENUE_PERFORMANCE_365D`, `MARKET_CAP_SALES_PERFORMANCE`, `MARKET_CAP_SALES_PERFORMANCE_180D`, `MARKET_CAP_SALES_PERFORMANCE_365D`, `MARKET_CAP_PR_PERFORMANCE`, `MARKET_CAP_PR_PERFORMANCE_180D`, `MARKET_CAP_PR_PERFORMANCE_365D`, `TVL_PERFORMANCE_180D`, `TVL_PERFORMANCE_365D`

Plus granular high/low tracking: `IR_NEW_HIGH_CREATED_5`, `IR_NEW_HIGH_CREATED_10`, `IR_NEW_HIGH_CREATED_15`, `IR_NEW_HIGH_CREATED_20`, `IR_NEW_HIGH_CREATED_50`, `IR_NEW_LOW_CREATED_5`, `IR_NEW_LOW_CREATED_10`, `IR_NEW_LOW_CREATED_15`, `IR_NEW_LOW_CREATED_20`, `IR_NEW_LOW_CREATED_50`

---

## crossAnalyticFilterType

Used by: Screener CrossAnalyticFilter (74 values)

**Price vs SMA:**
`X_LAST_PRICE_CROSS_SMA5`, `X_LAST_PRICE_CROSS_SMA10`, `X_LAST_PRICE_CROSS_SMA20`, `X_LAST_PRICE_CROSS_SMA30`, `X_LAST_PRICE_CROSS_SMA50`, `X_LAST_PRICE_CROSS_SMA200`

**SMA vs SMA:**
`X_SMA5_CROSS_SMA10`, `X_SMA5_CROSS_SMA20`, `X_SMA5_CROSS_SMA30`, `X_SMA5_CROSS_SMA50`, `X_SMA5_CROSS_SMA100`, `X_SMA5_CROSS_SMA200`, `X_SMA10_CROSS_SMA20`, `X_SMA10_CROSS_SMA30`, `X_SMA10_CROSS_SMA50`, `X_SMA10_CROSS_SMA100`, `X_SMA10_CROSS_SMA200`, `X_SMA20_CROSS_SMA30`, `X_SMA20_CROSS_SMA50`, `X_SMA20_CROSS_SMA100`, `X_SMA20_CROSS_SMA200`, `X_SMA30_CROSS_SMA50`, `X_SMA30_CROSS_SMA100`, `X_SMA30_CROSS_SMA200`, `X_SMA50_CROSS_SMA100`, `X_SMA50_CROSS_SMA200`, `X_SMA100_CROSS_SMA200`

**Price vs EMA:**
`X_LAST_PRICE_CROSS_EMA9`, `X_LAST_PRICE_CROSS_EMA12`, `X_LAST_PRICE_CROSS_EMA26`, `X_LAST_PRICE_CROSS_EMA50`, `X_LAST_PRICE_CROSS_EMA100`, `X_LAST_PRICE_CROSS_EMA200`

**EMA vs EMA:**
`X_EMA9_CROSS_EMA12`, `X_EMA9_CROSS_EMA26`, `X_EMA9_CROSS_EMA50`, `X_EMA9_CROSS_EMA100`, `X_EMA9_CROSS_EMA200`, `X_EMA12_CROSS_EMA26`, `X_EMA12_CROSS_EMA50`, `X_EMA12_CROSS_EMA100`, `X_EMA12_CROSS_EMA200`, `X_EMA26_CROSS_EMA50`, `X_EMA26_CROSS_EMA100`, `X_EMA26_CROSS_EMA200`, `X_EMA50_CROSS_EMA100`, `X_EMA50_CROSS_EMA200`, `X_EMA100_CROSS_EMA200`

**Bollinger Bands:**
`X_LAST_PRICE_CROSS_BOLLINGER_BAND_UPPER`, `X_LAST_PRICE_CROSS_BOLLINGER_BAND_LOWER`

**RSI Crosses:**
`X_RSI9_CROSS_30`, `X_RSI9_CROSS_50`, `X_RSI9_CROSS_70`, `X_RSI14_CROSS_30`, `X_RSI14_CROSS_50`, `X_RSI14_CROSS_70`, `X_RSI25_CROSS_30`, `X_RSI25_CROSS_50`, `X_RSI25_CROSS_70`

**Stochastic / StochRSI Crosses:**
`X_STOCH_CROSS_20`, `X_STOCH_CROSS_80`, `X_STOCH_RSI_CROSS_20`, `X_STOCH_RSI_CROSS_50`, `X_STOCH_RSI_CROSS_80`

**Other Oscillator Crosses:**
`X_CCI20_CROSS_MINUS100`, `X_CCI20_CROSS_100`, `X_ADX_CROSS_20`, `X_ADX_CROSS_40`, `X_WILLIAMS_CROSS_MINUS20`, `X_WILLIAMS_CROSS_MINUS80`, `X_ULTIMATE_OSCILLATOR_CROSS_30`, `X_ULTIMATE_OSCILLATOR_CROSS_70`

**MACD:**
`X_MACD_CROSS_MACD_SIGNAL_LINE`

**VWMA:**
`X_LAST_PRICE_CROSS_VWMA20`

---

## candlestickPatternFilterType

Used by: Screener CandlestickPatternFilter (35 patterns)

**Single Bullish Candles:**
`CD_HAMMER`, `CD_INVERTED_HAMMER`, `CD_DRAGONFLY_DOJI`, `CD_PERFECT_DRAGONFLY_DOJI`, `CD_BULLISH_SPINNING_TOP`

**Single Bearish Candles:**
`CD_HANGING_MAN`, `CD_SHOOTING_STAR`, `CD_GRAVESTONE_DOJI`, `CD_PERFECT_GRAVESTONE_DOJI`, `CD_BEARISH_SPINNING_TOP`

**Two-Candle Bullish:**
`CD_BULLISH_KICKER`, `CD_BULLISH_ENGULFING`, `CD_BULLISH_HARAMI`, `CD_PIERCING_LINE`, `CD_TWEEZER_BOTTOM`

**Two-Candle Bearish:**
`CD_BEARISH_KICKER`, `CD_BEARISH_ENGULFING`, `CD_BEARISH_HARAMI`, `CD_DARK_CLOUD_COVER`, `CD_TWEEZER_TOP`

**Three-Candle Bullish:**
`CD_MORNING_STAR`, `CD_MORNING_DOJI_STAR`, `CD_BULLISH_ABANDONED_BABY`, `CD_THREE_WHITE_SOLDIERS`, `CD_THREE_LINE_STRIKE_BULLISH`, `CD_THREE_INSIDE_UP`, `CD_THREE_OUTSIDE_UP`

**Three-Candle Bearish:**
`CD_EVENING_STAR`, `CD_EVENING_DOJI_STAR`, `CD_BEARISH_ABANDONED_BABY`, `CD_THREE_BLACK_CROWS`, `CD_THREE_LINE_STRIKE_BEARISH`, `CD_THREE_INSIDE_DOWN`, `CD_THREE_OUTSIDE_DOWN`

**Neutral:**
`CD_DOJI`

---

## percentDownFromAthFilter

Used by: Screener

**Within range (price >= ATH - X%):**
`PRICE_AT_LEAST_1_PERCENT_BELOW_ATH`, `PRICE_AT_LEAST_5_PERCENT_BELOW_ATH`, `PRICE_AT_LEAST_10_PERCENT_BELOW_ATH`, `PRICE_AT_LEAST_15_PERCENT_BELOW_ATH`, `PRICE_AT_LEAST_20_PERCENT_BELOW_ATH`, `PRICE_AT_LEAST_30_PERCENT_BELOW_ATH`

**Farther than (price <= ATH - X%):**
`PRICE_AT_LEAST_1_PERCENT_MORE_ATH`, `PRICE_AT_LEAST_5_PERCENT_MORE_ATH`, `PRICE_AT_LEAST_10_PERCENT_MORE_ATH`, `PRICE_AT_LEAST_15_PERCENT_MORE_ATH`, `PRICE_AT_LEAST_20_PERCENT_MORE_ATH`, `PRICE_AT_LEAST_30_PERCENT_MORE_ATH`

---

## supportResistanceFilter

Used by: Screener

| Value | Description |
|-------|-------------|
| `APPROACHING_SUPPORT` | Price nearing support from above |
| `BROKEN_BELOW_SUPPORT` | Price closed below support |
| `APPROACHING_RESISTANCE` | Price nearing resistance from below |
| `BROKEN_ABOVE_RESISTANCE` | Price closed above resistance |

---

## weekAnalytics52Filter

Used by: Screener

| Value | Description |
|-------|-------------|
| `HIGH_52W_IN_THE_LAST_2DAYS` | 52-week high hit in last 2 days |
| `LOW_52W_IN_THE_LAST_2DAYS` | 52-week low hit in last 2 days |
| `LAST_PRICE_WITHIN_5PERCENT_OF_HIGH_52W` | Within 5% of 52W high |
| `LAST_PRICE_WITHIN_10PERCENT_OF_HIGH_52W` | Within 10% of 52W high |
| `LAST_PRICE_WITHIN_20PERCENT_OF_HIGH_52W` | Within 20% of 52W high |
| `LAST_PRICE_WITHIN_5PERCENT_OF_LOW_52W` | Within 5% of 52W low |
| `LAST_PRICE_WITHIN_10PERCENT_OF_LOW_52W` | Within 10% of 52W low |
| `LAST_PRICE_WITHIN_20PERCENT_OF_LOW_52W` | Within 20% of 52W low |

---

## rsiDivergenceFilter

Used by: Screener

| Value | Description |
|-------|-------------|
| `BULLISH` | Bullish RSI divergence (price makes lower lows, RSI makes higher lows) |
| `BEARISH` | Bearish RSI divergence (price makes higher highs, RSI makes lower highs) |
| `HIDDEN_BULLISH` | Hidden bullish divergence (continuation signal in uptrend) |
| `HIDDEN_BEARISH` | Hidden bearish divergence (continuation signal in downtrend) |

---

## macdHistogramFilter

Used by: Screener

| Value | Histogram | Direction | Interpretation |
|-------|-----------|-----------|----------------|
| `H1_UP` | Positive (>0) | Rising | Strong bullish momentum accelerating |
| `H1_DOWN` | Positive (>0) | Falling | Weakening bullish, momentum fading |
| `H2_DOWN` | Negative (<0) | Falling | Strong bearish momentum accelerating |
| `H2_UP` | Negative (<0) | Rising | Weakening bearish, selling pressure fading |

---

## newHighInLastPeriodFilter / newLowInLastPeriodFilter

Used by: Screener

| Value | Description |
|-------|-------------|
| `PERIODS_5` | New high/low in last 5 periods |
| `PERIODS_10` | New high/low in last 10 periods |
| `PERIODS_15` | New high/low in last 15 periods |
| `PERIODS_20` | New high/low in last 20 periods |
| `PERIODS_30` | New high/low in last 30 periods |
| `PERIODS_50` | New high/low in last 50 periods |

---

## Signal Keys

Used by: Signals Feed `signals` filter (135 keys). Retrieve the full list dynamically via `GET /api/v2/public/signals-feed/signal-keys`.

**MA Crossovers:**
`SIGNALS_SUMMARY_SMA_5_10`, `SIGNALS_SUMMARY_SMA_10_20`, `SIGNALS_SUMMARY_SMA_20_30`, `SIGNALS_SUMMARY_SMA_30_50`, `SIGNALS_SUMMARY_SMA_50_200`, `SIGNALS_SUMMARY_SMA_100_200`, `SIGNALS_SUMMARY_EMA_9_12`, `SIGNALS_SUMMARY_EMA_12_26`, `SIGNALS_SUMMARY_EMA_26_50`, `SIGNALS_SUMMARY_EMA_50_100`, `SIGNALS_SUMMARY_EMA_50_200`, `SIGNALS_SUMMARY_EMA_100_200`, `EMA_12_50_CROSSOVERS`, `SIGNALS_SUMMARY_MA_RIBBON`

**Price vs MA:**
`SIGNALS_SUMMARY_PRICE_SMA_5_10`, `SIGNALS_SUMMARY_PRICE_SMA_10_20`, `SIGNALS_SUMMARY_PRICE_SMA_30_50`, `SIGNALS_SUMMARY_PRICE_SMA_100_200`, `SIGNALS_SUMMARY_PRICE_EMA_9_12`, `SIGNALS_SUMMARY_PRICE_EMA_12_26`, `SIGNALS_SUMMARY_PRICE_EMA_50_100`, `SIGNALS_SUMMARY_PRICE_EMA_100_200`

**Oscillators:**
`SIGNALS_SUMMARY_RSI_9`, `SIGNALS_SUMMARY_RSI_14`, `SIGNALS_SUMMARY_RSI_25`, `SIGNALS_SUMMARY_STOCH`, `SIGNALS_SUMMARY_STOCH_RSI`, `SIGNALS_SUMMARY_WILLIAMS`, `SIGNALS_SUMMARY_RSI_DIVERGENCE`

**Bollinger / OBV:**
`SIGNALS_SUMMARY_BOLLBAND_PRICE_UPPER_LOWER`, `SIGNALS_SUMMARY_OBV_TREND`

**Trend & Momentum:**
`UP_DOWN_TREND`, `SIGNALS_SUMMARY_STRONG_UP_DOWN_TREND`, `SIGNALS_SUMMARY_SHORT_TERM_TREND_UPGRADE_DOWNGRADE`, `MOMENTUM_UP_DOWN_TREND`, `MOMENTUM_RSI_CONFIRMATION`, `FRESH_MOMENTUM_MACD_SIGNAL_LINE_CROSSOVER`, `EARLY_MOMENTUM_MACD_HISTOGRAM_INFLECTION`, `UP_DOWN_TREND_AND_FRESH_MOMENTUM_INFLECTION`, `PULLBACK_UP_DOWN_TREND`, `PULLBACK_UP_DOWN_TREND_1W`, `SIGNALS_SUMMARY_OVERSOLD_OVERBOUGHT_MOMENTUM`, `SIGNALS_SUMMARY_OVERSOLD_OVERBOUGHT_UP_DOWN`, `SIGNALS_SUMMARY_VERY_OVERSOLD_OVERBOUGHT`

**Chart Patterns:**
`SIGNALS_SUMMARY_CHANNEL_UP`, `SIGNALS_SUMMARY_CHANNEL_DOWN`, `SIGNALS_SUMMARY_TRIANGLE`, `SIGNALS_SUMMARY_ASCENDING_TRIANGLE`, `SIGNALS_SUMMARY_DESCENDING_TRIANGLE`, `SIGNALS_SUMMARY_RISING_WEDGE`, `SIGNALS_SUMMARY_FALLING_WEDGE`, `SIGNALS_SUMMARY_FLAG`, `SIGNALS_SUMMARY_PENNANT`, `SIGNALS_SUMMARY_RECTANGLE`, `SIGNALS_SUMMARY_DOUBLE_TOP`, `SIGNALS_SUMMARY_DOUBLE_BOTTOM`, `SIGNALS_SUMMARY_TRIPLE_TOP`, `SIGNALS_SUMMARY_TRIPLE_BOTTOM`, `SIGNALS_SUMMARY_HEAD_AND_SHOULDERS`, `SIGNALS_SUMMARY_INVERSE_HEAD_AND_SHOULDERS`, `SIGNALS_SUMMARY_EMERGING_PATTERNS`, `SIGNALS_SUMMARY_PATTERN_BREAKOUTS`, `SIGNALS_SUMMARY_PATTERN_BREAKOUTS_UPTREND_DOWNTREND`, `SIGNALS_SUMMARY_TRADING_RANGE`, `SIGNALS_SUMMARY_TRADING_RANGE_V2`

**Harmonic Patterns:**
`SIGNALS_SUMMARY_ABCD`, `SIGNALS_SUMMARY_GARTLEY`, `SIGNALS_SUMMARY_BUTTERFLY`, `SIGNALS_SUMMARY_DRIVE`

**Fibonacci:**
`SIGNALS_SUMMARY_POINT_RETRACEMENT`, `SIGNALS_SUMMARY_POINT_EXTENSION`

**Candlestick Patterns:**
`SIGNALS_SUMMARY_HAMMER`, `SIGNALS_SUMMARY_INVERTED_HAMMER`, `SIGNALS_SUMMARY_HANGING_MAN`, `SIGNALS_SUMMARY_SHOOTING_STAR`, `SIGNALS_SUMMARY_DOJI`, `SIGNALS_SUMMARY_DRAGONFLY_DOJI`, `SIGNALS_SUMMARY_DRAGONFLY_DOJI_V2`, `SIGNALS_SUMMARY_GRAVESTONE_DOJI`, `SIGNALS_SUMMARY_GRAVESTONE_DOJI_V2`, `SIGNALS_SUMMARY_SPINNING_TOP`, `SIGNALS_SUMMARY_ENGULFING`, `SIGNALS_SUMMARY_HARAMI`, `SIGNALS_SUMMARY_KICKER`, `SIGNALS_SUMMARY_PIERCING_LINE`, `SIGNALS_SUMMARY_DARK_CLOUD_COVER`, `SIGNALS_SUMMARY_TWEEZER_TOP`, `SIGNALS_SUMMARY_TWEEZER_BOTTOM`, `SIGNALS_SUMMARY_MORNING_STAR`, `SIGNALS_SUMMARY_MORNING_DOJI_STAR`, `SIGNALS_SUMMARY_EVENING_STAR`, `SIGNALS_SUMMARY_EVENING_DOJI_STAR`, `SIGNALS_SUMMARY_ABANDONED_BABY`, `SIGNALS_SUMMARY_THREE_WHITE_SOLDIERS`, `SIGNALS_SUMMARY_THREE_BLACK_CROWS`, `SIGNALS_SUMMARY_THREE_INSIDE_UP`, `SIGNALS_SUMMARY_THREE_INSIDE_DOWN`, `SIGNALS_SUMMARY_THREE_OUTSIDE_UP`, `SIGNALS_SUMMARY_THREE_OUTSIDE_DOWN`, `SIGNALS_SUMMARY_THREE_LINE_STRIKE`, `SIGNALS_SUMMARY_CONSECUTIVE_CANDLES`

**Price Action:**
`SIGNALS_SUMMARY_TOP_GAINERS`, `SIGNALS_SUMMARY_TOP_LOSERS`, `SIGNALS_SUMMARY_BIG_MOVEMENT`, `SIGNALS_SUMMARY_UNUSUAL_VOLUME_GAINERS_DECLINERS`, `SIGNALS_SUMMARY_RVOL_SPIKE_IN_UPTREND_DOWNTREND`, `SIGNALS_SUMMARY_TR_ATR_1x`, `SIGNALS_SUMMARY_TR_ATR_2x`, `SIGNALS_SUMMARY_TR_ATR_3x`, `SIGNALS_SUMMARY_TR_ATR_4x`, `SIGNALS_SUMMARY_TR_ATR_5x`

**New Highs / Lows:**
`SIGNALS_SUMMARY_NEW_LOCAL_HIGH_LOW_5_PERIODS`, `SIGNALS_SUMMARY_NEW_LOCAL_HIGH_LOW_10_PERIODS`, `SIGNALS_SUMMARY_NEW_LOCAL_HIGH_LOW_15_PERIODS`, `SIGNALS_SUMMARY_NEW_LOCAL_HIGH_LOW_20_PERIODS`, `SIGNALS_SUMMARY_NEW_LOCAL_HIGH_LOW_30_PERIODS`, `SIGNALS_SUMMARY_NEW_LOCAL_HIGH_LOW_50_PERIODS`

**ATH Proximity:**
`SIGNALS_SUMMARY_RECENT_ATH`, `SIGNALS_SUMMARY_RECENT_ATH_NOT_OVERBOUGHT`, `SIGNALS_SUMMARY_RECENT_ATH_PULLBACK_MACD_INFLECT`, `SIGNALS_SUMMARY_WITHIN_5_PERCENT_ATH`, `SIGNALS_SUMMARY_WITHIN_5_PERCENT_ATH_NOT_OVERBOUGHT`, `SIGNALS_SUMMARY_WITHIN_5_PERCENT_ATH_BULLISH_MACD_HISTO`, `SIGNALS_SUMMARY_WITHIN_5_PERCENT_ATH_BULLISH_MACD_CROSS`

**Support / Resistance:**
`SIGNALS_SUMMARY_HORIZONTAL_SUPPORT`, `SIGNALS_SUMMARY_HORIZONTAL_RESISTANCE`, `SUPPORT_RESISTANCE_BREAKOUT`, `SUPPORT_RESISTANCE_APPROACHING`, `SUPPORT_RESISTANCE_APPROACHING_OVERSOLD`

**Fundamentals:**
`SIGNALS_SUMMARY_FUNDAMENTALS_MCAP_TR`, `SIGNALS_SUMMARY_FUNDAMENTALS_MCAP_TVL`, `SIGNALS_SUMMARY_FUNDAMENTALS_TR_GROWTH`, `SIGNALS_SUMMARY_FUNDAMENTALS_TVL_GROWTH`, `SIGNALS_SUMMARY_FUNDAMENTALS_TVL_ABOVE`, `SIGNALS_SUMMARY_FUNDAMENTALS_ANNUALIZED_TR_ABOVE`

---

## analyticsComparisonsFilterType

Used by: Screener AnalyticsComparisonsFilter (456 combinations)

Pattern: `{METRIC_A}_VS_{METRIC_B}` for price/value comparisons, `{METRIC_A}_TREND_VS_{METRIC_B}_TREND` for trend comparisons.

**Value comparison metrics:** `LAST_PRICE`, `HIGH`, `LOW`, `HIGH_52W`, `LOW_52W`, `VWMA20`, `SMA5`..`SMA200`, `EMA9`..`EMA200`

**Value:** `"ABOVE"` or `"BELOW"`

Examples: `LAST_PRICE_VS_SMA50`, `EMA50_VS_SMA200`, `SMA200_TREND_VS_EMA100_TREND`, `VOLUME_VS_VOLUME_AVG`
