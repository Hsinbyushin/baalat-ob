<p align="center">
  <img src="assets/baalat-ob.png" alt="Ba'alat 'Ob logo" width="320">
</p>

<h1 align="center">Ba'alat 'Ob</h1>

<p align="center">
  <em>A Haskell bot for remembering the digital voices of the dead.</em>
</p>

---

## About

**Ba'alat 'Ob** is an experimental bot written in Haskell.

Once or twice a day, the bot is intended to search Wikidata for notable people
whose death anniversary falls on the current date and whose death occurred
within the last twenty years.

For people with a known X/Twitter account, the bot will retrieve a small
selection of their final posts and repost them throughout the day, starting
with the oldest selected post and ending with their last published post.

The project is being developed incrementally, both as a working bot and as an
exercise in building a real-world application in Haskell.

## Name

The name **Ba'alat 'Ob** (בַּעֲלַת־אוֹב) refers to the biblical figure commonly
known as the *Witch of Endor* or *Medium of Endor* in the First Book of Samuel.

In the narrative, King Saul asks the woman to call forth the dead prophet
Samuel.

The name reflects the central idea of the project: briefly bringing voices
from the past back into the present.

## How it works

The intended pipeline is:

```text
current date
    │
    ▼
calculate death anniversaries
for the previous 20 years
    │
    ▼
Wikidata SPARQL query
    │
    ▼
find people with known
X/Twitter accounts
    │
    ▼
decode JSON into
typed Haskell values
    │
    ▼
retrieve recent posts
from the account
    │
    ▼
select the final 5–10 posts
    │
    ▼
order oldest → newest
    │
    ▼
repost throughout the day
```

## Current status

Ba'alat 'Ob is currently under development.

Implemented so far:

- [x] Cabal project structure
- [x] Domain model for people and posts
- [x] Death-anniversary calculation
- [x] Twenty-year eligibility window
- [x] Selection and chronological ordering of memorial posts
- [x] HTTP client
- [x] Wikidata SPARQL queries
- [x] JSON decoding with Aeson
- [x] Conversion from Wikidata results into domain types
- [x] Lookup of Wikidata entries with known X/Twitter usernames
- [ ] Human-readable dry-run output
- [ ] X API client
- [ ] Account verification
- [ ] Timeline retrieval
- [ ] Repost scheduling
- [ ] Persistent state
- [ ] Production deployment

## Building

Ba'alat 'Ob uses GHC and Cabal.

Build the project:

```bash
cabal build
```

Run the test suite:

```bash
cabal test --test-show-details=direct
```

Run the application:

```bash
cabal run baalat-ob
```

At the current stage, running the application performs a live Wikidata query
and prints the resulting memorial candidates.

## Project structure

```text
baalat-ob/
├── app/
│   └── Main.hs
├── assets/
│   └── baalat-ob.png
├── src/
│   └── BaalatOb/
│       ├── Http.hs
│       ├── Person.hs
│       ├── Post.hs
│       ├── Wikidata.hs
│       └── Wikidata/
│           └── Types.hs
├── test/
│   └── Main.hs
├── baalat-ob.cabal
├── LICENSE
└── README.md
```

## Design

Ba'alat 'Ob deliberately separates external API representations from its
internal domain model.

For example, raw Wikidata JSON is first decoded into dedicated Wikidata types:

```text
JSON
  ↓
WikidataResponse
  ↓
WikidataResults
  ↓
WikidataBinding
  ↓
Person
```

The rest of the application can therefore work with its own types without
having to know how Wikidata represents its data.

The same approach is intended for the X API.

## Development

The project follows a deliberately incremental development process:

```text
small feature
    ↓
tests
    ↓
working implementation
    ↓
commit
    ↓
next feature
```

This repository is also intended as a practical exploration of Haskell,
including its type system, pure and impure code, HTTP communication, JSON
decoding, API integration and eventually scheduling and persistence.

## Disclaimer

Ba'alat 'Ob is an experimental project.

It is not affiliated with Wikimedia, Wikidata, X, or the estates of any people
referenced by the bot.

Automated posting and reposting will only be enabled in accordance with the
applicable APIs, platform policies and access restrictions.

## License

BSD-3-Clause
