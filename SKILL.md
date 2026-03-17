---
name: altfins-skill
description: >
  Query crypto market data, technical indicators, trading signals, OHLCV prices,
  news summaries, and expert technical analysis from the altFINS Crypto Analytics API.
  Use when the user asks about crypto prices, market trends, technical analysis,
  trading signals, indicator data (RSI, MACD, SMA, EMA), OHLC candles, crypto news,
  or wants to screen/filter cryptocurrencies by technical criteria. Covers 2200+ assets,
  150+ indicators, 130+ signals. Requires ALTFINS_API_KEY env var.
version: 1.0.0
license: MIT
allowed-tools: Bash
metadata: {"openclaw":{"requires":{"env":["ALTFINS_API_KEY"],"bins":["curl","jq"]},"primaryEnv":"ALTFINS_API_KEY","configPaths":["~/.config/altfins-skill/"]}}
---

# altFINS Crypto Analytics Skill

Query crypto market data, technical indicators, trading signals, and news from the altFINS API. Designed for AI agents that need crypto market intelligence.

## Prerequisites

- `ALTFINS_API_KEY` environment variable must be set
- `curl` and `jq` must be available

## Workflow Decision Tree

```text
User wants crypto data?
├── Screen/filter coins by criteria?
│   └── altfins_screener.sh [filters: price, volume, RSI, MACD, trends, patterns]
├── Price data (OHLCV)?
│   ├── Latest prices for multiple coins → altfins_ohlc.sh snapshot
│   └── Historical candles for one coin → altfins_ohlc.sh history
├── Technical indicator history?
│   └── altfins_analytics.sh --symbol BTC --type RSI14 [150+ types available]
├── Trading signals?
│   ├── Recent signals (all) → altfins_signals.sh --days 1
│   ├── Bullish only → altfins_signals.sh --direction BULLISH
│   └── Specific signal type → altfins_signals.sh --signals '["EMA_12_50_CROSSOVERS"]'
├── Expert technical analysis?
│   └── altfins_technical_analysis.sh [--symbol BTC] (trade setups for 50+ coins)
├── Crypto news?
│   ├── Recent summaries → altfins_news.sh search --days 7
│   └── Specific summary → altfins_news.sh find --days 1
└── Reference data?
    ├── Available symbols → altfins_enums.sh symbols
    ├── API credit balance → altfins_enums.sh permits
    └── Time intervals → altfins_enums.sh intervals
```

## Scripts Reference

| Script | Purpose | Method |
|--------|---------|--------|
| `altfins_screener.sh` | Screen/filter 2200+ cryptos by indicators, price, volume, trends | POST |
| `altfins_ohlc.sh` | OHLCV price data — snapshot (multi-coin) or historical (single coin) | POST |
| `altfins_analytics.sh` | Historical data for any of 150+ indicators (SMA, RSI, MACD, etc.) | POST |
| `altfins_signals.sh` | Trading signals feed — 130+ signal types, bullish/bearish | POST |
| `altfins_technical_analysis.sh` | Expert trade setups with entry/exit/stop-loss for top 50+ coins | GET |
| `altfins_news.sh` | AI-generated crypto news summaries | POST |
| `altfins_enums.sh` | Reference data: symbols, intervals, API usage permits | GET |
| `altfins_format_results.sh` | Format JSON results into summary, full detail, or CSV | Local |

## Quick Examples

### Screen for oversold large caps
```bash
scripts/altfins_screener.sh --min-mcap 1000000000 --max-rsi14 30 --coin-type REGULAR \
  | scripts/altfins_format_results.sh --type screener --top 10
```

### Get BTC price history (last 90 days)
```bash
scripts/altfins_ohlc.sh history --symbol BTC --days 90 \
  | scripts/altfins_format_results.sh --type ohlc --format csv
```

### Check RSI(14) for ETH over last 30 days
```bash
scripts/altfins_analytics.sh --symbol ETH --type RSI14 --days 30 \
  | scripts/altfins_format_results.sh --type analytics
```

### Get today's bullish signals
```bash
scripts/altfins_signals.sh --direction BULLISH --days 1 \
  | scripts/altfins_format_results.sh --type signals --top 20
```

### Get technical analysis for BTC
```bash
scripts/altfins_technical_analysis.sh --symbol BTC \
  | scripts/altfins_format_results.sh --type ta --format full
```

### Get recent crypto news
```bash
scripts/altfins_news.sh search --days 3 \
  | scripts/altfins_format_results.sh --type news --top 10
```

## Behavior Rules (MANDATORY)

1. **NEVER return raw JSON to the user.** Always pipe results through `altfins_format_results.sh`.
2. **Always check API credits** before running large queries. Run `altfins_enums.sh permits` first if unsure.
3. **Default time interval is DAILY** unless the user specifies otherwise. Valid intervals: MINUTES15, HOURLY, HOURS4, HOURS12, DAILY.
4. **For screener queries**, start with reasonable defaults (REGULAR coin type, DAILY interval) and add filters based on what the user asks for.
5. **Signal direction** must be BULLISH or BEARISH — do not pass other values.
6. **When results are empty**, suggest broadening filters (longer date range, fewer constraints) before assuming the API is broken.
7. **For historical data**, default to 30 days unless the user specifies. Use `--days` shorthand.
8. **Rate limits apply.** If you get HTTP 429, wait and retry. Tell the user about the rate limit.
9. **One credit = 100 returned items.** Be mindful of page sizes on large queries.
10. **Always show result count** and offer to show more or filter differently.

## Available Analytics Types (Common)

| Category | Types |
|----------|-------|
| Price | DOLLAR_PRICE, HIGH, LOW, ATH, HIGH_52W, LOW_52W |
| Performance | PRICE_CHANGE_1D, PRICE_CHANGE_1W, PRICE_CHANGE_1M, PRICE_CHANGE_3M, PRICE_CHANGE_6M, PRICE_CHANGE_1Y |
| SMA | SMA5, SMA10, SMA20, SMA30, SMA50, SMA100, SMA200 |
| EMA | EMA9, EMA12, EMA26, EMA50, EMA100, EMA200 |
| RSI | RSI9, RSI14, RSI25 |
| MACD | MACD, MACD_SIGNAL_LINE, MACD_HISTOGRAM |
| Stochastic | STOCH, STOCH_SLOW, STOCH_RSI, STOCH_RSI_K, STOCH_RSI_D |
| Momentum | MOM, ADX, CCI20, WILLIAMS, ULTIMATE_OSCILLATOR |
| Volatility | ATR, BOLLINGER_BAND_LOWER, BOLLINGER_BAND_UPPER |
| Trends | SHORT_TERM_TREND, MEDIUM_TERM_TREND, LONG_TERM_TREND |
| Volume | VOLUME, VOLUME_AVG, VOLUME_RELATIVE, OBV, OBV_TREND |
| Fundamental | TVL, TOTAL_REVENUE, MARKET_CAP, MARKET_CAP_SALES, MARKET_CAP_TVL |

Use `altfins_analytics.sh --list-types` for the complete list.

## Exit Codes

| Code | Meaning | Agent should... |
|------|---------|-----------------|
| 0 | Success — results on stdout | Format and present results |
| 1 | Error — something failed | Report the error to user |

## Data Storage

Cached data stored in `~/.config/altfins-skill/cache/`. Cache TTL: 5 minutes. Reference data (symbols, intervals) cached longer. No other files written.

## Security

All scripts source `scripts/_lib.sh`. The library:
- Makes requests to a **single base URL**: `https://altfins.com/api/v2/public`
- Uses **one credential**: `ALTFINS_API_KEY` (sent via `X-API-KEY` header)
- Writes **only** to `~/.config/altfins-skill/` (cache files)
- Does not read other environment variables, contact other hosts, or modify files outside its config directory

## For full API details

See `references/api-reference.md` for complete endpoint documentation, response schemas, and all enum values.
