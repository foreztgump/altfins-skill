# altfins-skill

Bash scripts for querying the [altFINS Crypto Data & Analytics API](https://altfins.com/crypto-market-and-analytical-data-api/). Designed as an AI agent skill — gives LLMs structured access to 150+ technical indicators, 130+ trading signals, OHLCV data, news summaries, and expert technical analysis across 2,200+ crypto assets.

## Features

- **Screener** — filter 2,200+ cryptos by price, volume, market cap, RSI, MACD, trends
- **OHLCV** — snapshot (multi-coin) or historical candle data across 5 time intervals
- **Analytics** — historical data for 150+ indicators (SMA, EMA, RSI, MACD, Bollinger, etc.)
- **Signals** — 130+ trading signals with bullish/bearish direction filtering
- **Technical Analysis** — curated expert trade setups for top 50+ coins
- **News** — AI-generated crypto news summaries
- **Reference data** — symbols, intervals, API credit balance

## Prerequisites

- **Linux** (macOS: `stat -c` in caching is not portable — contributions welcome)
- `curl`
- `jq`
- An [altFINS API key](https://altfins.com/crypto-market-and-analytical-data-api/)

## Installation

### As a Claude Code skill (recommended)

```bash
# Clone into your Claude Code skills directory
git clone https://github.com/foreztgump/altfins-skill.git ~/.claude/skills/altfins-skill

# Set your API key in your shell profile
echo 'export ALTFINS_API_KEY="your_key_here"' >> ~/.zshrc
source ~/.zshrc
```

Claude will automatically detect the skill and use it when you ask about crypto data. You can also invoke it directly with `/altfins-skill`.

### As a project skill

```bash
# Clone into your project's .claude/skills/ directory
git clone https://github.com/foreztgump/altfins-skill.git .claude/skills/altfins-skill

# Set your API key (if not already in your shell profile)
export ALTFINS_API_KEY='your_key_here'
```

### Standalone (without Claude Code)

```bash
git clone https://github.com/foreztgump/altfins-skill.git
cd altfins-skill
export ALTFINS_API_KEY='your_key_here'

# Option A: install script (symlinks to ~/.local/bin)
./install.sh

# Option B: run directly from repo
scripts/altfins_enums.sh symbols | jq length
```

## Quick Start

```bash
# Screen for oversold large caps
scripts/altfins_screener.sh --min-mcap 1000000000 --max-rsi14 30 \
  | scripts/altfins_format_results.sh --type screener --top 10

# Get BTC price history (last 90 days)
scripts/altfins_ohlc.sh history --symbol BTC --days 90 \
  | scripts/altfins_format_results.sh --type ohlc

# Check RSI(14) for ETH
scripts/altfins_analytics.sh --symbol ETH --type RSI14 --days 30 \
  | scripts/altfins_format_results.sh --type analytics

# Today's bullish signals
scripts/altfins_signals.sh --direction BULLISH --days 1 \
  | scripts/altfins_format_results.sh --type signals --top 20

# Expert technical analysis for BTC
scripts/altfins_technical_analysis.sh --symbol BTC \
  | scripts/altfins_format_results.sh --type ta --format full

# Recent crypto news
scripts/altfins_news.sh search --days 3 \
  | scripts/altfins_format_results.sh --type news --top 10

# Check API credit balance
scripts/altfins_enums.sh permits
```

## Scripts

| Script | Purpose |
|--------|---------|
| `altfins_screener.sh` | Screen/filter cryptos by indicators, price, volume, trends |
| `altfins_ohlc.sh` | OHLCV price data — `snapshot` or `history` mode |
| `altfins_analytics.sh` | Historical data for 150+ technical indicators |
| `altfins_signals.sh` | Trading signals feed — 130+ signal types |
| `altfins_technical_analysis.sh` | Expert trade setups for top 50+ coins |
| `altfins_news.sh` | AI-generated crypto news summaries |
| `altfins_enums.sh` | Reference data: symbols, intervals, API permits |
| `altfins_format_results.sh` | Format JSON output into summary, full, or CSV |

Every script supports `--help` for full usage details.

## Configuration

| Variable | Required | Description |
|----------|----------|-------------|
| `ALTFINS_API_KEY` | Yes | Your altFINS API key |

Cache is stored at `~/.config/altfins-skill/cache/` with a 5-minute TTL.

## API Coverage

Full API reference: [references/api-reference.md](references/api-reference.md)

Covers all 16 endpoints of the [altFINS Public API v2](https://altfins.com/crypto-market-and-analytical-data-api/documentation/).

## Development

```bash
make lint    # shellcheck
make test    # bats tests
make check   # both
```

## License

MIT
