---
name: altfins-skill
description: >
  Query crypto market data, technical indicators, trading signals, OHLCV prices,
  news summaries, and expert technical analysis from the altFINS Crypto Analytics API.
  Use when the user asks about crypto prices, market trends, technical analysis,
  trading signals, indicator data (RSI, MACD, SMA, EMA), OHLC candles, crypto news,
  or wants to screen/filter cryptocurrencies by technical criteria. Covers 2200+ assets,
  150+ indicators, 130+ signals. Requires ALTFINS_API_KEY env var.
allowed-tools: Bash(${CLAUDE_SKILL_DIR}/scripts/*)
---

# altFINS Crypto Analytics Skill

Query crypto market data, technical indicators, trading signals, and news from the altFINS API.

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

All scripts are in `${CLAUDE_SKILL_DIR}/scripts/`. Run them with full path:

| Script | Purpose |
|--------|---------|
| `altfins_screener.sh` | Screen/filter 2200+ cryptos by indicators, price, volume, trends |
| `altfins_ohlc.sh` | OHLCV price data — `snapshot` (multi-coin) or `history` (single coin) |
| `altfins_analytics.sh` | Historical data for 150+ indicators (SMA, RSI, MACD, etc.) |
| `altfins_signals.sh` | Trading signals feed — 130+ signal types, bullish/bearish |
| `altfins_technical_analysis.sh` | Expert trade setups for top 50+ coins |
| `altfins_news.sh` | AI-generated crypto news summaries |
| `altfins_enums.sh` | Reference data: symbols, intervals, API usage permits |
| `altfins_format_results.sh` | Format JSON results into summary, full detail, or CSV |

## Quick Examples

### Screen for oversold large caps
```bash
${CLAUDE_SKILL_DIR}/scripts/altfins_screener.sh --min-mcap 1000000000 --max-rsi14 30 --coin-type REGULAR \
  | ${CLAUDE_SKILL_DIR}/scripts/altfins_format_results.sh --type screener --top 10
```

### Get BTC price history (last 90 days)
```bash
${CLAUDE_SKILL_DIR}/scripts/altfins_ohlc.sh history --symbol BTC --days 90 \
  | ${CLAUDE_SKILL_DIR}/scripts/altfins_format_results.sh --type ohlc --format csv
```

### Check RSI(14) for ETH over last 30 days
```bash
${CLAUDE_SKILL_DIR}/scripts/altfins_analytics.sh --symbol ETH --type RSI14 --days 30 \
  | ${CLAUDE_SKILL_DIR}/scripts/altfins_format_results.sh --type analytics
```

### Get today's bullish signals
```bash
${CLAUDE_SKILL_DIR}/scripts/altfins_signals.sh --direction BULLISH --days 1 \
  | ${CLAUDE_SKILL_DIR}/scripts/altfins_format_results.sh --type signals --top 20
```

### Get technical analysis for BTC
```bash
${CLAUDE_SKILL_DIR}/scripts/altfins_technical_analysis.sh --symbol BTC \
  | ${CLAUDE_SKILL_DIR}/scripts/altfins_format_results.sh --type ta --format full
```

### Get recent crypto news
```bash
${CLAUDE_SKILL_DIR}/scripts/altfins_news.sh search --days 3 \
  | ${CLAUDE_SKILL_DIR}/scripts/altfins_format_results.sh --type news --top 10
```

## Behavior Rules (MANDATORY)

1. **NEVER return raw JSON to the user.** Always pipe results through `altfins_format_results.sh`.
2. **Always check API credits** before running large queries. Run `altfins_enums.sh permits` first if unsure.
3. **Default time interval is DAILY** unless the user specifies otherwise. Valid: MINUTES15, HOURLY, HOURS4, HOURS12, DAILY.
4. **For screener queries**, start with reasonable defaults (REGULAR coin type, DAILY interval) and add filters based on what the user asks for.
5. **Signal direction** must be BULLISH or BEARISH — do not pass other values.
6. **When results are empty**, suggest broadening filters (longer date range, fewer constraints).
7. **For historical data**, default to 30 days unless the user specifies. Use `--days` shorthand.
8. **Rate limits apply.** If you get HTTP 429, tell the user and wait before retrying.
9. **One credit = 100 returned items.** Be mindful of page sizes on large queries.
10. **Always show result count** and offer to show more or filter differently.

## Common Analytics Types

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

## Additional Resources

- For complete API endpoint documentation, response schemas, and all enum values, see [references/api-reference.md](references/api-reference.md)

## Security

- Single endpoint: `https://altfins.com/api/v2/public`
- Single credential: `ALTFINS_API_KEY` (via `X-API-KEY` header, never logged)
- Writes only to `~/.config/altfins-skill/cache/` (5-minute TTL)
- All JSON payloads built with `jq` — no string interpolation
