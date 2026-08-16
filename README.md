# Ba'alat 'Ob

<p align="center">
  <img src="assets/baalat-ob-banner.png" alt="Ba'alat 'Ob logo" width="1000">
</p>

## About

**Ba'alat 'Ob** is an experimental bot written in Haskell.

The project explores the idea of finding notable people whose death anniversary
falls on the current date and briefly bringing their past online presence back
into view.

Ba'alat 'Ob queries Wikidata for people who died on the current calendar date
within a defined eligibility window. Where available, Wikidata is also used to
identify known X/Twitter usernames associated with those people.

The original concept was to retrieve a small selection of a person's final
posts from X and repost them throughout the anniversary of their death,
starting with the oldest selected post and ending with their last published
post.

Development of the live X client has since been discontinued because access to
the required X API functionality incurs usage costs. The project therefore
currently concentrates on the Wikidata integration, domain modelling,
memorial-planning logic, and an offline dry-run using simulated X posts.

The project is being developed incrementally, both as an experimental
application and as an exercise in building a real-world program in Haskell.

## Name

The name **Ba'alat 'Ob** (בַּעֲלַת אוֹב) refers to the biblical figure commonly
known as the *Witch of Endor* or *Medium of Endor* in the First Book of Samuel.

In the narrative, King Saul asks the woman to call forth the dead prophet
Samuel.

The name reflects the central idea of the project: briefly bringing voices
from the past back into the present.

## How it works

The currently implemented pipeline is:

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
X/Twitter usernames
    │
    ▼
decode JSON into
typed Haskell values
    │
    ▼
Person
    │
    ▼
simulated X posts
    │
    ▼
select memorial posts
    │
    ▼
order oldest → newest
    │
    ▼
create MemorialPlan
    │
    ▼
human-readable dry run
```

No posts are published or reposted by the current application.

## Current status

Ba'alat 'Ob is currently under development.

The Wikidata side of the application works with live data. Memorial planning
and post selection can be exercised offline using simulated X post data.

Implemented so far:

* [x] Cabal project structure
* [x] Domain model for people and posts
* [x] Death-anniversary calculation
* [x] Twenty-year eligibility window
* [x] Selection and chronological ordering of memorial posts
* [x] HTTP client
* [x] Wikidata SPARQL queries
* [x] Wikidata JSON decoding with Aeson
* [x] Conversion from Wikidata results into domain types
* [x] Lookup of Wikidata entries with known X/Twitter usernames
* [x] X user and post domain types
* [x] X API response types
* [x] X user JSON decoding
* [x] X post JSON decoding
* [x] Conversion from X API representations into domain types
* [x] Experimental X user lookup client
* [x] Memorial plan domain model
* [x] Human-readable dry-run output
* [x] Offline memorial planning with simulated X posts
* [ ] Persistent state
* [ ] Production scheduling
* [ ] Production deployment

### X API development

Development of the live X integration has been **discontinued**.

An initial X client, API response types, JSON decoding, and user lookup were
implemented while exploring the integration. Live API access was then found
to require paid API usage for the functionality needed by the project.

Because Ba'alat 'Ob is an experimental and educational project, further
development of the X client is currently not considered worth the additional
API cost.

The existing X-related domain and API types remain useful for modelling and
testing the intended architecture. Simulated X posts are therefore used for
the offline memorial-planning pipeline.

Live timeline retrieval, reposting, and X-based scheduling are no longer part
of the current development roadmap.

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

No X API access is required for the normal dry run.

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

Ba'alat 'Ob deliberately separates representations received from external APIs
from its internal domain model.

For example, raw Wikidata JSON is decoded into dedicated Wikidata types before
being converted into a `Person`:

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

The experimental X integration follows the same approach:

```text
X JSON
  ↓
XUserResponse / XPostsResponse
  ↓
XUserData / XPostData
  ↓
XUser / XPost
```

This allows the rest of the application to operate on its own domain types
without depending directly on the representation chosen by an external API.

The core memorial-planning logic is also kept separate from network access:

```text
Person + [XPost]
       │
       ▼
createMemorialPlan
       │
       ▼
MemorialPlan
```

`createMemorialPlan` is pure: it performs no HTTP requests and has no external
side effects.

This separation allows the central idea of the bot to be developed and tested
even though live X integration is no longer being pursued.

## Dry-run development

The current application combines live Wikidata data with simulated X posts.

```text
live Wikidata
      │
      ▼
memorial candidates
      │
      ▼
Person
      │
      ├──────────────┐
      │              │
      ▼              ▼
X username     simulated X posts
                     │
                     ▼
            selectMemorialPosts
                     │
                     ▼
               MemorialPlan
                     │
                     ▼
            human-readable output
```

The simulated posts are deliberately simple. Their purpose is not to reproduce
the behaviour of X, but to exercise the application's domain and orchestration
logic without requiring external API access.

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

The repository is also intended as a practical exploration of Haskell,
including:

* algebraic data types and records
* pure and impure code
* `IO`
* HTTP communication
* JSON decoding with Aeson
* modelling external APIs
* transformation into domain types
* testing
* application architecture
* scheduling and persistence

## Future direction

With live X integration removed from the current roadmap, future development
can concentrate on the parts of Ba'alat 'Ob that do not depend on paid social
media APIs.

Possible areas include:

* improving Wikidata candidate selection
* handling duplicate or ambiguous social-media identities
* improving memorial-plan generation
* extracting simulated services from `Main`
* persistent state
* scheduling
* richer dry-run and reporting output
* support for alternative public data sources

The original X-based concept remains the architectural inspiration for the
project, even though live reposting is no longer an immediate goal.

## Disclaimer

Ba'alat 'Ob is an experimental project.

It is not affiliated with Wikimedia, Wikidata, X, or the estates of any people
referenced by the application.

The presence of an X/Twitter username in Wikidata does not imply that the
account has been independently verified by Ba'alat 'Ob.

No automated posting or reposting is currently performed.

## License

BSD-3-Clause
