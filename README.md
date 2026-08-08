# Ba'alat 'Ob

<p align="center">
  <img src="assets/baalat-ob-banner.png" alt="Ba'alat 'Ob logo" width="1000">
</p>

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
create memorial plan
    │
    ▼
repost throughout the day
```

## Current status

Ba'alat 'Ob is currently under development.

The Wikidata side of the application is live. The X side is currently
developed and tested primarily with simulated API data, allowing the memorial
planning pipeline to be exercised without performing real reposts or requiring
paid API access.

Implemented so far:

- [x] Cabal project structure
- [x] Domain model for people and X posts
- [x] Death-anniversary calculation
- [x] Twenty-year eligibility window
- [x] Selection and chronological ordering of memorial posts
- [x] HTTP client
- [x] Wikidata SPARQL queries
- [x] Wikidata JSON decoding with Aeson
- [x] Conversion from Wikidata results into domain types
- [x] Lookup of Wikidata entries with known X/Twitter usernames
- [x] X API response types
- [x] X user JSON decoding
- [x] X post JSON decoding
- [x] Conversion from X API types into domain types
- [x] X user lookup client
- [x] Memorial plan domain model
- [x] Human-readable dry-run output
- [x] Offline memorial planning with simulated X posts
- [ ] Live X timeline retrieval
- [ ] Account verification
- [ ] Repost execution
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

At the current stage, running the application performs a live Wikidata query,
finds memorial candidates for the current date, sorts them by year of death,
and creates human-readable memorial plans using simulated X posts.

No posts are published or reposted during the dry run.

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
│       ├── Memorial.hs
│       ├── Person.hs
│       ├── Post.hs
│       ├── Wikidata.hs
│       ├── Wikidata/
│       │   └── Types.hs
│       ├── X.hs
│       └── X/
│           ├── ApiTypes.hs
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

The same separation is used for X API data:

```text
X JSON
  ↓
XUserResponse / XPostsResponse
  ↓
XUserData / XPostData
  ↓
XUser / XPost
```

The rest of the application can therefore work with its own domain types
without having to know how an external API represents its data.

Memorial planning is kept separate from network access:

```text
Person + [XPost]
       ↓
createMemorialPlan
       ↓
MemorialPlan
```

This makes the core planning logic pure and allows it to be tested without
making HTTP requests or performing real reposts.

## Dry-run development

The X integration is currently exercised using simulated post data.

This allows the application to test the complete planning flow:

```text
live Wikidata data
        ↓
memorial candidates
        ↓
simulated X posts
        ↓
selectMemorialPosts
        ↓
MemorialPlan
        ↓
human-readable dry run
```

The simulated X data will eventually be replaced by live timeline retrieval
without changing the core memorial-planning logic.

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
