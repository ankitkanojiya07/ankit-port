-- Seed: Learn articles (generated). Run in the Supabase SQL editor after schema.sql.
-- Re-runnable: existing slugs are updated. Categories must match src/lib/content.ts (learnCategories).

-- ===== system-design =====
insert into public.learn_articles (title, slug, category, level, summary, body, tags, published, sort, created_at)
values ($q$Scaling a Web App: From One Server to Millions of Users$q$, $q$system-design-scaling-one-server-to-millions$q$, $q$System Design$q$, $q$Beginner$q$, $q$Learn how a single-server app grows into a system that serves millions, one bottleneck at a time. Covers vertical vs horizontal scaling, statelessness, databases, caching, and queues.$q$, $q$Most systems do not start big. They start as one process on one machine and grow only when traffic forces the issue. Understanding the usual sequence of bottlenecks makes scaling feel like a series of small, defensible decisions instead of a rewrite.

## Stage 0: one box does everything

The first version runs the web server, application code, and database on a single machine. This is correct for early traffic, and premature scaling here wastes time. The limits show up as high CPU, exhausted memory, or disk I/O saturation.

## Vertical vs horizontal scaling

- **Vertical scaling** means buying a bigger machine: more CPU, RAM, faster disks. It is simple and requires no code changes, but there is a ceiling and a single point of failure.
- **Horizontal scaling** means adding more machines behind a load balancer. There is no hard ceiling, but the application must be designed for it.

Vertical scaling buys time. Horizontal scaling buys longevity.

## Split the tiers

The first real architectural move is separating concerns onto different machines:

- Application servers run your code.
- A database server owns persistent state.
- A load balancer distributes requests across app servers.

This lets each tier scale on its own schedule.

## Make app servers stateless

Horizontal scaling only works if any server can handle any request. That requires removing local state. The common offender is session data stored in server memory.

Move session state out of the process:

```
Browser --cookie--> Load Balancer --> App Server (any)
                                          |
                                     Redis (sessions)
```

With sessions in a shared store, you can add or remove app servers freely, and a crash does not log everyone out.

## The database becomes the bottleneck

Stateless app servers scale easily, but they all point at one database. Reads usually dominate, so attack reads first:

- **Add a cache** (such as Redis or Memcached) in front of expensive queries.
- **Add read replicas** so reads spread across copies while writes go to the primary.

```sql
-- writes go to primary
UPDATE accounts SET balance = balance - 10 WHERE id = 42;

-- reads can go to a replica
SELECT balance FROM accounts WHERE id = 42;
```

Replication introduces lag: a read replica may be milliseconds to seconds behind. For a balance shown after a transfer, read from the primary or the cache instead.

## Caching layers

Caching appears at several levels, and each removes load from the one below it:

- Browser and client caches avoid requests entirely.
- A CDN serves static assets and some cacheable responses close to users.
- An application cache stores query results and computed values.

A cache hit that avoids a database round trip is often the single highest-leverage optimization available.

## Offload slow work with queues

Some work does not need to finish before responding to the user: sending email, generating thumbnails, updating search indexes. Pushing these onto a message queue keeps request latency low.

```
Request --> enqueue job --> respond 202 Accepted
                 |
            Worker pool --> processes job later
```

This decouples request handling from background processing, and the worker pool scales independently of the web tier.

## Scale the database writes

Read replicas and caches handle reads, but a single primary still absorbs every write. When writes saturate it, options include:

- **Sharding**: partition data across multiple databases by a key such as user ID.
- **Specialized stores**: move high-volume data (time series, search, blobs) to systems built for it.

Sharding is powerful but costly in complexity, so it is usually a late move.

## Measure before you move

Each stage above is a response to a real, observed bottleneck. Adding replicas when the CPU is pegged on the app tier solves nothing. Invest in observability early:

- Request latency percentiles (p50, p95, p99), not just averages.
- Database query times and slow query logs.
- Cache hit rates and queue depth.

## A practical progression

1. One server. Ship the product.
2. Split the database onto its own machine.
3. Add a load balancer and a second app server; make servers stateless.
4. Add a cache for hot reads.
5. Add read replicas.
6. Introduce a queue for background work.
7. Add a CDN for static and cacheable content.
8. Shard or adopt specialized stores when writes demand it.

Millions of users is rarely one heroic design. It is this ordered list, each step justified by a metric, with complexity added only when the previous stage runs out of room.$q$, array[$q$Scalability$q$, $q$Load Balancing$q$, $q$Caching$q$, $q$Databases$q$, $q$Architecture$q$], true, 1, now() - interval '2 hours')
on conflict (slug) do update set title=excluded.title, category=excluded.category, level=excluded.level, summary=excluded.summary, body=excluded.body, tags=excluded.tags, published=true, sort=excluded.sort, updated_at=now();

insert into public.learn_articles (title, slug, category, level, summary, body, tags, published, sort, created_at)
values ($q$Caching Strategies Every Engineer Should Know$q$, $q$system-design-caching-strategies$q$, $q$System Design$q$, $q$Intermediate$q$, $q$A practical tour of cache-aside, read-through, write-through, write-back, CDN caching, and Redis patterns, with the trade-offs and failure modes of each.$q$, $q$Caching trades freshness and complexity for speed and reduced load. Used well, it is the cheapest large performance win available. Used carelessly, it is the source of the hardest bugs you will ever debug: stale data, thundering herds, and inconsistency between layers. The strategy matters more than the technology.

## Why cache at all

A cache stores the result of expensive work so the next request can skip it. Expensive can mean a slow database query, a remote API call, or a heavy computation. The two questions that define every caching design are:

- Who writes to the cache, and when?
- What happens when the cached data is wrong?

## Cache-aside (lazy loading)

The most common pattern. The application checks the cache first and loads from the database only on a miss.

```
value = cache.get(key)
if value is None:
    value = db.query(key)
    cache.set(key, value, ttl=300)
return value
```

- **Pros:** only requested data is cached; a cache outage degrades gracefully to the database.
- **Cons:** the first request after a miss is slow (cold cache), and writes must invalidate the cache separately or risk staleness.

## Read-through

Similar to cache-aside, but the cache library itself loads from the backing store on a miss. The application only talks to the cache. This centralizes the loading logic but couples you to a cache that supports it.

## Write-through

On every write, update the cache and the database together, synchronously.

```
db.write(key, value)
cache.set(key, value)
```

- **Pros:** the cache is never stale for written keys; reads are fast immediately.
- **Cons:** every write pays the cost of two systems, and you cache data that may never be read.

## Write-back (write-behind)

Writes go to the cache and are flushed to the database asynchronously in batches.

- **Pros:** very fast writes, and batching reduces database load dramatically.
- **Cons:** a cache crash before the flush loses data. Only acceptable where some loss is tolerable, such as view counts or metrics.

## Choosing a write strategy

| Need | Strategy |
| --- | --- |
| Simple, read-heavy | Cache-aside |
| Reads must be fresh after writes | Write-through |
| Write throughput is critical, some loss OK | Write-back |

## Expiration and invalidation

Two independent levers control staleness:

- **TTL (time to live):** data expires after a set time. Simple and self-healing, but data can be stale for up to the TTL.
- **Explicit invalidation:** delete or update the key when the source changes. Fresh, but easy to miss a code path and leak staleness forever.

A common robust approach combines both: invalidate on write, and keep a modest TTL as a safety net.

## The thundering herd

When a popular key expires, many concurrent requests miss at once and all hit the database together, sometimes crashing it. Mitigations:

- **Locking / single-flight:** only one request recomputes; others wait for the result.
- **Early recomputation:** refresh the value slightly before it expires.
- **Jittered TTLs:** add randomness so keys do not all expire simultaneously.

## CDN caching

A CDN caches responses at edge locations near users. It is ideal for static assets and cacheable responses. Control it with HTTP headers:

```
Cache-Control: public, max-age=3600
ETag: "a1b2c3"
```

An `ETag` lets the browser revalidate cheaply: the server returns `304 Not Modified` when nothing changed. For dynamic pages, use short TTLs or cache only fragments.

## Redis as an application cache

Redis is the common choice for a shared application cache because it is fast, networked, and offers more than key-value storage: sorted sets for leaderboards, TTLs per key, and atomic counters. Keep these in mind:

- Set a memory limit and an eviction policy (`allkeys-lru` is a sensible default for a cache).
- Treat Redis as a cache, not a database, unless you deliberately configure persistence.
- Keep keys namespaced and versioned, for example `user:v2:42`, so a schema change can invalidate a whole class of keys at once.

## Practical guidance

- Start with cache-aside plus a TTL. It covers most needs.
- Cache the results of reads that are both expensive and frequent; caching rare queries wastes memory.
- Always design for a cache that is empty or unavailable. The system should be slower, not broken.
- Measure hit rate. A cache with a low hit rate adds complexity and latency for no benefit.$q$, array[$q$Caching$q$, $q$Redis$q$, $q$CDN$q$, $q$Performance$q$, $q$Scalability$q$], true, 2, now() - interval '5 hours')
on conflict (slug) do update set title=excluded.title, category=excluded.category, level=excluded.level, summary=excluded.summary, body=excluded.body, tags=excluded.tags, published=true, sort=excluded.sort, updated_at=now();

insert into public.learn_articles (title, slug, category, level, summary, body, tags, published, sort, created_at)
values ($q$Load Balancing and Reverse Proxies Explained$q$, $q$system-design-load-balancing-reverse-proxies$q$, $q$System Design$q$, $q$Intermediate$q$, $q$Understand what load balancers and reverse proxies do, the difference between L4 and L7, common routing algorithms, health checks, and how sticky sessions work.$q$, $q$Once an application runs on more than one server, something must decide where each request goes. That something is usually a load balancer, and it is often also a reverse proxy. The two roles overlap but are not identical, and knowing the difference clarifies a lot of infrastructure design.

## Reverse proxy vs load balancer

A **reverse proxy** sits in front of one or more servers and forwards client requests to them. Clients talk only to the proxy. Even with a single backend, a reverse proxy is useful for:

- Terminating TLS in one place.
- Serving cached or static content.
- Compressing responses and rewriting headers.
- Hiding backend topology from clients.

A **load balancer** is a reverse proxy whose main job is distributing traffic across multiple backends for scale and availability. In practice tools like Nginx, HAProxy, and Envoy do both.

## Layer 4 vs Layer 7

Load balancers operate at different levels of the network stack:

- **Layer 4 (transport):** routes by IP address and TCP/UDP port without inspecting the payload. It is fast and protocol-agnostic, but cannot make decisions based on URLs or headers.
- **Layer 7 (application):** understands HTTP. It can route by path, host, header, or cookie, terminate TLS, and retry failed requests intelligently.

L4 is right for raw throughput and non-HTTP protocols. L7 is right when routing decisions depend on the content of the request.

```
# L7 routing by path
/api/*    -> api-servers
/static/* -> cdn-origin
/*        -> web-servers
```

## Routing algorithms

How does the balancer pick a backend? Common choices:

- **Round robin:** rotate through servers in order. Simple, assumes servers are equal.
- **Weighted round robin:** give more traffic to more powerful servers.
- **Least connections:** send to the server with the fewest active connections. Good when request durations vary.
- **IP hash:** hash the client IP to a server, giving the same client the same backend.

Least connections is often the best default for web traffic, because it adapts to uneven request costs that round robin ignores.

## Health checks

A load balancer must stop sending traffic to a dead backend. It does this with health checks:

- **Passive:** watch real traffic for errors and timeouts.
- **Active:** periodically probe an endpoint such as `/healthz`.

A good health endpoint checks that the server can actually serve requests, for example that it can reach its database, rather than just returning 200 unconditionally. But avoid making it so strict that one slow dependency pulls every server out of rotation at once.

```
GET /healthz -> 200 OK   (ready for traffic)
GET /healthz -> 503      (drain me)
```

## Sticky sessions

Stateless servers let any backend handle any request. When state lives on a specific server, you need **sticky sessions** (session affinity): the balancer routes a given client to the same backend repeatedly, usually via a cookie or IP hash.

Stickiness is a workaround, not a goal. It undermines even load distribution and complicates deploys, because draining a server disrupts its pinned users. The better fix is to externalize session state into a shared store so stickiness is unnecessary.

## TLS termination

Terminating TLS at the load balancer means it decrypts incoming HTTPS and forwards plain HTTP to backends on a trusted network. This centralizes certificate management and offloads crypto from app servers. When the internal network is not trusted, re-encrypt to the backend (TLS passthrough or re-encryption) instead.

## High availability of the balancer itself

A single load balancer is a single point of failure. Production setups avoid this with:

- A pair of balancers with a floating virtual IP that fails over.
- DNS-based distribution across multiple balancers.
- A managed cloud load balancer that is redundant internally.

## Putting it together

A typical request path looks like this:

```
Client
  |
  v
DNS -> Load Balancer (L7, TLS termination, health checks)
          |  least-connections
   ---------------------
   |        |          |
 app-1    app-2      app-3   (stateless)
          |
       Redis (shared sessions)
```

The balancer spreads load, removes unhealthy nodes, and gives you a seam for deploys, TLS, and caching. Keep the backends stateless, keep the health check honest, and prefer shared state over sticky sessions, and the load balancing tier stays simple as the system grows.$q$, array[$q$Load Balancing$q$, $q$Reverse Proxy$q$, $q$Nginx$q$, $q$Networking$q$, $q$High Availability$q$], true, 3, now() - interval '8 hours')
on conflict (slug) do update set title=excluded.title, category=excluded.category, level=excluded.level, summary=excluded.summary, body=excluded.body, tags=excluded.tags, published=true, sort=excluded.sort, updated_at=now();

insert into public.learn_articles (title, slug, category, level, summary, body, tags, published, sort, created_at)
values ($q$Database Replication and Sharding for Scale$q$, $q$system-design-replication-and-sharding$q$, $q$System Design$q$, $q$Advanced$q$, $q$How to scale a database beyond one machine: replication for read scaling and availability, sharding for write scaling, and the hard trade-offs of each, including replication lag and cross-shard queries.$q$, $q$A single database is the most common hard limit in a scaling system. Application servers add cheaply; the database holds authoritative state and cannot simply be cloned. Two techniques push past the single-machine ceiling, and they solve different problems: replication scales reads and improves availability, while sharding scales writes and storage.

## Replication

Replication keeps copies of the same data on multiple machines. The usual arrangement is one **primary** that accepts writes and one or more **replicas** that receive a stream of changes.

```
writes --> Primary --replication--> Replica 1 (reads)
                     \-------------> Replica 2 (reads)
```

- Reads spread across replicas, multiplying read capacity.
- If the primary fails, a replica can be promoted, improving availability.

### Synchronous vs asynchronous

- **Asynchronous** replication acknowledges a write as soon as the primary has it. Fast, but a replica may lag, and a primary crash can lose recent writes.
- **Synchronous** replication waits for a replica to confirm before acknowledging. Safer, but slower and vulnerable to stalling if a replica is slow.

Many systems use semi-synchronous: wait for at least one replica, let the rest catch up asynchronously.

### Replication lag

The defining hazard of read replicas is lag. A user who writes and then immediately reads may not see their own change if the read hits a lagging replica. This is called read-your-writes inconsistency. Mitigations:

- Route reads that follow a write to the primary for a short window.
- Pin a session to the primary after it writes.
- Track a write position and only read from replicas that have caught up to it.

## Sharding (horizontal partitioning)

Replication does not help write throughput: every replica still applies every write. When writes or dataset size exceed one machine, you **shard**, splitting data across independent databases, each holding a subset.

```
users 0-99k    -> shard A
users 100-199k -> shard B
users 200-299k -> shard C
```

Each shard is its own database (often with its own replicas), so writes and storage scale with the number of shards.

### Choosing a shard key

The shard key determines which shard owns a row, and it is the single most consequential decision:

- **Range-based:** partition by ranges of the key. Simple and good for range scans, but prone to hot spots if traffic clusters in one range.
- **Hash-based:** hash the key to choose a shard. Spreads load evenly, but destroys range queries.
- **Directory-based:** a lookup service maps keys to shards. Flexible and allows rebalancing, but the lookup is another component to keep available.

A good shard key spreads load evenly and keeps data that is queried together on the same shard. A poor key creates hot shards or forces expensive cross-shard queries.

## The costs of sharding

Sharding trades a hard scaling limit for a large increase in complexity:

- **Cross-shard queries:** a query spanning shards must fan out and merge results in the application. Joins across shards are painful or impossible.
- **Transactions:** atomic writes across shards require distributed transaction protocols, which are slow and complex. Design so that a transaction stays within one shard.
- **Rebalancing:** adding a shard means moving data. **Consistent hashing** reduces how much data moves when the shard count changes.
- **Unique IDs:** auto-increment per shard collides. Use UUIDs or a dedicated ID generation scheme.

```sql
-- easy: single-shard query (shard key present)
SELECT * FROM orders WHERE user_id = 42;

-- hard: no shard key, must hit every shard
SELECT * FROM orders WHERE status = 'refunded';
```

## Combining both

Production systems usually layer the two. Each shard is a primary with its own replicas:

```
         Router (by shard key)
        /         |          \
   Shard A     Shard B     Shard C
   P + replicas P + replicas P + replicas
```

This gives write scaling from sharding and read scaling plus availability from replication within each shard.

## Order of operations

Reach for these tools in order of increasing cost:

1. **Optimize first:** indexes, query tuning, and connection pooling often remove the pressure entirely.
2. **Add a cache** to absorb hot reads.
3. **Add read replicas** when reads dominate.
4. **Shard** only when writes or data size genuinely exceed one machine.

Sharding is powerful and nearly irreversible once live, so it should be the last resort, not the first instinct. Many systems serve very large workloads on a well-tuned primary with replicas and a cache, and never shard at all.$q$, array[$q$Databases$q$, $q$Replication$q$, $q$Sharding$q$, $q$Scalability$q$, $q$Consistency$q$, $q$PostgreSQL$q$], true, 4, now() - interval '11 hours')
on conflict (slug) do update set title=excluded.title, category=excluded.category, level=excluded.level, summary=excluded.summary, body=excluded.body, tags=excluded.tags, published=true, sort=excluded.sort, updated_at=now();

insert into public.learn_articles (title, slug, category, level, summary, body, tags, published, sort, created_at)
values ($q$Design a URL Shortener: A Worked System Design Example$q$, $q$system-design-url-shortener$q$, $q$System Design$q$, $q$Intermediate$q$, $q$A complete walkthrough of designing a URL shortener: requirements, API, key generation strategies, data model, read scaling, and the real trade-offs, in the structure a system design interview expects.$q$, $q$Designing a URL shortener is a classic exercise because it is small enough to finish yet rich enough to touch key generation, storage, caching, and read scaling. The value is in the structured reasoning, not the product itself.

## Clarify requirements

Before drawing anything, pin down scope.

Functional:

- Given a long URL, return a short one.
- Visiting the short URL redirects to the original.
- Optionally support custom aliases and expiration.

Non-functional:

- Redirects must be fast; this is the hot path.
- The system is read-heavy. A link is created once and visited many times.
- Short codes must be unique and hard to guess in bulk.

## Estimate scale

Rough numbers guide the design. Assume 100 million new URLs per month and a 100:1 read-to-write ratio.

- Writes: ~40 per second on average.
- Reads: ~4,000 per second.
- Storage over 5 years: 100M * 12 * 5 = 6 billion rows. At ~500 bytes each, roughly 3 TB.

The conclusion that matters: reads dominate by two orders of magnitude, so the design optimizes redirects above all.

## Design the API

```
POST /urls        { "long_url": "https://..." }  -> { "short": "abc123" }
GET  /{short_code}                               -> 301 redirect
```

Use **301 (permanent)** to let browsers and proxies cache the redirect and cut load, or **302 (temporary)** if you need every visit to hit your server for analytics. The choice is a real trade-off between load and tracking.

## Generate the short code

A code of length 7 over a 62-character alphabet (a-z, A-Z, 0-9) yields 62^7, about 3.5 trillion combinations, far more than enough. The hard part is generating codes that are unique without collisions.

**Option 1: hash the URL.** Hash with something like MD5 and take the first few characters. Simple, but hashes collide, and the same URL always maps to the same code (which may or may not be desired).

**Option 2: counter plus base62.** Maintain a global incrementing counter and encode it in base62.

```
id = 1,000,000
code = base62(id) = "4c92"
```

This guarantees uniqueness with no collision checks, and codes stay short. The challenge is a distributed counter. A single counter is a bottleneck and a single point of failure. Solve it by handing each application server a **range** of IDs from a central service (for example 10,000 at a time), so servers mint codes locally and only occasionally coordinate.

**Option 3: random codes with a uniqueness check.** Generate a random code and insert with a unique constraint; retry on the rare collision. Simple and unguessable, at the cost of an occasional retry.

The counter-plus-ranges approach is a strong default: no collisions, no per-write coordination.

## Data model

A key-value shape fits naturally.

```sql
CREATE TABLE urls (
  short_code  VARCHAR(10) PRIMARY KEY,
  long_url    TEXT NOT NULL,
  created_at  TIMESTAMPTZ DEFAULT now(),
  expires_at  TIMESTAMPTZ
);
```

Lookups are by primary key, so this stays fast even at billions of rows, and it shards cleanly on `short_code` if needed.

## Serve redirects fast

The read path is the whole game. A redirect is a single key lookup, and most traffic concentrates on a small set of popular links, which makes caching extremely effective.

```
GET /abc123
  -> check cache (Redis)
     hit  -> 301 to long_url
     miss -> read DB, populate cache, redirect
```

With a high cache hit rate, the database handles only a fraction of the 4,000 reads per second. Put a CDN or edge cache in front for globally popular links to cut latency further.

## Scale the storage

At billions of rows, one database may not suffice:

- **Read replicas** absorb lookups that miss the cache.
- **Sharding by short_code** (hash-based) spreads both reads and writes evenly, and since every lookup carries the short code, no query ever needs to span shards.

Because the access pattern is pure key lookup, this workload shards about as cleanly as any.

## Handle expiration and edge cases

- Store `expires_at` and treat expired links as not found; a background job reclaims old rows.
- Validate and normalize input URLs to avoid storing junk or redirect loops.
- Rate-limit creation to deter abuse and bulk scraping of the code space.

## Summary of trade-offs

- 301 caches well but hides analytics; 302 tracks every hit but adds load.
- Counter-based codes avoid collisions but need distributed ID allocation.
- Caching plus a key-value model makes the read-heavy path cheap and the system straightforward to scale.

The takeaway is the method: clarify, estimate, let the numbers point at the bottleneck, then design for it.$q$, array[$q$System Design$q$, $q$URL Shortener$q$, $q$Caching$q$, $q$Sharding$q$, $q$API Design$q$, $q$Scalability$q$], true, 5, now() - interval '14 hours')
on conflict (slug) do update set title=excluded.title, category=excluded.category, level=excluded.level, summary=excluded.summary, body=excluded.body, tags=excluded.tags, published=true, sort=excluded.sort, updated_at=now();

-- ===== frontend =====
insert into public.learn_articles (title, slug, category, level, summary, body, tags, published, sort, created_at)
values ($q$How the Browser Renders a Page: The Critical Rendering Path$q$, $q$frontend-critical-rendering-path$q$, $q$Frontend$q$, $q$Beginner$q$, $q$A step-by-step look at how a browser turns HTML, CSS, and JavaScript into pixels on screen. Understanding this pipeline is the foundation for diagnosing slow pages.$q$, $q$When a browser receives a response from a server, it does not simply paint the markup to the screen. It runs a sequence of steps known as the critical rendering path. Knowing each step helps explain why some resources block rendering, why layout can be expensive, and where to look when a page feels slow.

## The main steps

The browser transforms bytes into pixels through a predictable pipeline:

- Parse HTML into the DOM (Document Object Model) tree.
- Parse CSS into the CSSOM (CSS Object Model) tree.
- Combine the DOM and CSSOM into the render tree, which contains only visible nodes.
- Run layout (also called reflow) to compute the size and position of each node.
- Paint pixels into layers.
- Composite the layers together to produce the final frame.

Each step depends on the output of the step before it, so a delay early in the path pushes everything downstream.

## Parsing and the DOM

The HTML parser reads the document top to bottom and builds the DOM incrementally. This is why the order of tags matters. When the parser encounters a resource it must handle before continuing, it can pause.

A plain script tag is parser-blocking. The parser stops, fetches the script, executes it, and only then resumes. That is why script placement and loading attributes matter:

```html
<script src="/app.js" defer></script>
<script src="/analytics.js" async></script>
```

- `defer` downloads the script in parallel and runs it after parsing finishes, in document order.
- `async` downloads in parallel and runs as soon as it arrives, in no guaranteed order.
- Neither attribute blocks the parser while downloading, which keeps the DOM building.

## CSS is render-blocking

The browser will not paint meaningful content until it has processed the CSS it needs, because painting with incomplete styles would cause a flash of unstyled content. CSS is therefore render-blocking by default.

Two practical consequences follow:

- Keep the CSS needed for the first screen small and deliver it quickly.
- Defer or split stylesheets that are only needed for content further down the page.

Media queries let the browser treat some stylesheets as non-blocking for the initial render:

```html
<link rel="stylesheet" href="print.css" media="print" />
```

The print stylesheet is still downloaded, but it does not block the first paint for screen users.

## Layout and paint

Once the render tree exists, layout computes geometry: how wide each box is, where it sits, how lines wrap. Layout is relative, so changing one element can force recalculation of many others. Reading a layout property such as `offsetHeight` right after writing to the DOM can trigger a synchronous reflow, sometimes called layout thrashing:

```js
// Forces the browser to flush layout on every iteration
for (const el of items) {
  el.style.width = el.offsetWidth + 10 + 'px';
}
```

Batch reads and writes instead. Read all measurements first, then apply all writes, so the browser performs a single layout pass.

Paint fills in pixels: text, colors, shadows, borders. Compositing assembles painted layers, which is where the GPU often helps.

## Properties that skip layout

Not every visual change requires a full trip through layout and paint. Animating `transform` and `opacity` can be handled by the compositor alone, which is far cheaper than animating properties like `width`, `top`, or `margin`:

```css
/* Cheap: compositor can handle this */
.card { transition: transform 200ms ease; }
.card:hover { transform: translateY(-4px); }
```

Prefer transform-based animation for smooth motion, and avoid animating layout-triggering properties in a loop.

## Measuring the path

Browser developer tools expose this pipeline directly. The Performance panel records each phase so slow layout or long scripting can be seen on a timeline. Key metrics tied to the rendering path include:

- First Contentful Paint, the moment the first text or image appears.
- Largest Contentful Paint, the moment the main content is likely visible.

## Practical takeaways

- Put render-blocking CSS in the document head and keep it lean.
- Use `defer` for scripts that manipulate the DOM, and `async` for independent scripts.
- Inline a small amount of critical CSS for the first screen when startup speed matters, and load the rest afterward.
- Avoid interleaved DOM reads and writes to prevent forced reflows.
- Animate `transform` and `opacity` rather than layout properties.

The critical rendering path is not a single bottleneck but a chain. Small improvements at the blocking steps, CSS delivery and script execution, usually produce the largest gains in perceived speed.$q$, array[$q$Browsers$q$, $q$Performance$q$, $q$HTML$q$, $q$CSS$q$, $q$Rendering$q$], true, 1, now() - interval '3 hours')
on conflict (slug) do update set title=excluded.title, category=excluded.category, level=excluded.level, summary=excluded.summary, body=excluded.body, tags=excluded.tags, published=true, sort=excluded.sort, updated_at=now();

insert into public.learn_articles (title, slug, category, level, summary, body, tags, published, sort, created_at)
values ($q$Taming React Re-renders: memo, useMemo, useCallback, and Keys$q$, $q$frontend-react-re-renders$q$, $q$Frontend$q$, $q$Intermediate$q$, $q$When and why React components re-render, and how to apply memoization and stable keys without over-optimizing. Covers the common traps that make performance worse.$q$, $q$React re-renders more often than many developers expect, and most of the time that is perfectly fine. Problems appear only when a re-render is both frequent and expensive. The tools React provides, memo, useMemo, useCallback, and correct keys, are precise instruments, not blanket solutions. Using them well requires understanding why a component rendered in the first place.

## Why components re-render

A component function runs again when any of the following happens:

- Its own state changes.
- Its parent re-renders, so it is called again with new props.
- A context it consumes changes.

Note the second point: a child re-renders when its parent does, even if the child's props are unchanged by value. React re-running the function is cheap on its own. The cost comes from large subtrees or heavy work inside the render.

## Measure before optimizing

The React DevTools Profiler records which components rendered and how long each took. Before reaching for memoization, confirm there is an actual bottleneck. Premature memoization adds code and dependency arrays that must be maintained, and it can hide real bugs.

## React.memo

Wrapping a component in `React.memo` skips its re-render when its props are shallowly equal to the previous props:

```jsx
const Row = React.memo(function Row({ label, value }) {
  return <li>{label}: {value}</li>;
});
```

This helps only when:

- The component is re-rendered often by its parent.
- Its props usually stay the same between those renders.
- Rendering it is genuinely expensive.

The shallow comparison is the catch. If a parent passes a new object or function on every render, the props are never equal and memo does nothing.

## useCallback and useMemo

These hooks give you stable references across renders, which is what makes `React.memo` effective on children that receive functions or objects.

```jsx
function List({ items }) {
  const handleSelect = useCallback((id) => {
    console.log('selected', id);
  }, []);

  const sorted = useMemo(
    () => [...items].sort((a, b) => a.name.localeCompare(b.name)),
    [items]
  );

  return sorted.map((item) => (
    <Row key={item.id} item={item} onSelect={handleSelect} />
  ));
}
```

- `useCallback` memoizes a function so its identity is stable while its dependencies are unchanged.
- `useMemo` memoizes a computed value so expensive work is not repeated on every render.

Two rules keep these honest:

- The dependency array must list every value used inside. Omitting one causes stale closures.
- They are caches, not guarantees. React may discard a `useMemo` value, so never rely on it for correctness, only for performance.

## When memoization backfires

Memoization is not free. Each `useMemo` and `useCallback` stores a value and runs a comparison. For cheap computations, this overhead can exceed the cost it tries to avoid. Signs of over-optimization include wrapping trivial values, long dependency arrays that change constantly, and memo applied to components whose props always differ anyway.

A cleaner fix is often structural. Moving state down so fewer components depend on it, or lifting expensive children out as props, can eliminate re-renders without any memoization:

```jsx
// Children passed in do not re-render when Parent's state changes
function Parent({ children }) {
  const [open, setOpen] = useState(false);
  return <div>{children}</div>;
}
```

## Keys and list identity

Keys tell React which list item is which between renders. They are not a performance micro-optimization; they are about correctness. A wrong key causes React to reuse the wrong DOM node and component state.

- Use a stable, unique identifier from your data, such as a database id.
- Do not use the array index as a key when the list can reorder, filter, or have items inserted. State and focus will attach to the wrong rows.
- A key only needs to be unique among its siblings, not globally.

```jsx
// Fragile when the list reorders
{todos.map((todo, i) => <Todo key={i} todo={todo} />)}

// Stable
{todos.map((todo) => <Todo key={todo.id} todo={todo} />)}
```

## A practical checklist

- Profile first and confirm the re-render is expensive and frequent.
- Try restructuring state and composition before memoization.
- Reach for `React.memo` on heavy children, and pair it with `useCallback` and `useMemo` so their props stay stable.
- Keep dependency arrays complete and honest.
- Use stable data-driven keys for lists, never the index for dynamic lists.

The goal is not to eliminate every render but to make sure the renders that do happen are cheap.$q$, array[$q$React$q$, $q$Performance$q$, $q$Hooks$q$, $q$Memoization$q$, $q$JavaScript$q$], true, 2, now() - interval '6 hours')
on conflict (slug) do update set title=excluded.title, category=excluded.category, level=excluded.level, summary=excluded.summary, body=excluded.body, tags=excluded.tags, published=true, sort=excluded.sort, updated_at=now();

insert into public.learn_articles (title, slug, category, level, summary, body, tags, published, sort, created_at)
values ($q$Core Web Vitals: A Practical Guide to Frontend Performance$q$, $q$frontend-core-web-vitals$q$, $q$Frontend$q$, $q$Intermediate$q$, $q$What LCP, INP, and CLS actually measure, and concrete techniques to improve each one. Includes the thresholds that matter and how to measure in the field.$q$, $q$Core Web Vitals are a small set of metrics meant to capture real user experience: how fast the main content loads, how quickly the page responds to input, and how stable the layout stays. Unlike synthetic scores, they are designed to reflect what a person actually perceives. Each has a target threshold and a distinct set of causes.

## The three metrics

- Largest Contentful Paint (LCP) measures loading. It marks when the largest visible element, often a hero image or heading block, finishes rendering. Good: 2.5 seconds or less.
- Interaction to Next Paint (INP) measures responsiveness. It captures the latency of user interactions across the whole visit and reports a representative worst case. Good: 200 milliseconds or less.
- Cumulative Layout Shift (CLS) measures visual stability. It sums unexpected layout movement during the page's lifetime. Good: 0.1 or less.

INP replaced First Input Delay because it accounts for the full interaction, not just the delay before processing begins.

## Improving LCP

LCP is usually dominated by how quickly the largest element can be discovered, downloaded, and painted.

- Serve the LCP image in a modern format and an appropriately sized resolution.
- Preload the hero image so the browser fetches it early:

```html
<link rel="preload" as="image" href="/hero.avif" fetchpriority="high" />
```

- Avoid lazy-loading the LCP image. Lazy loading is for below-the-fold content.
- Reduce render-blocking CSS and slow server response times, since both delay the first paint.
- Prefer server-rendered or statically generated markup for above-the-fold content so it does not wait on client-side JavaScript.

## Improving INP

INP suffers when the main thread is busy and cannot respond to a click, tap, or keypress. Long tasks are the usual culprit.

- Break up long JavaScript tasks so the browser can respond between chunks.
- Defer non-urgent work. Yielding to the main thread lets a pending interaction run first:

```js
async function handleClick() {
  updateUrgentUI();
  // Yield so the browser can paint the response
  await new Promise((resolve) => setTimeout(resolve, 0));
  doExpensiveWork();
}
```

- Ship less JavaScript. Code splitting and removing unused dependencies shrink parse and execution time.
- In React, keep event handlers light and move heavy computation out of the interaction path, or mark non-urgent updates as transitions.

## Improving CLS

Layout shifts happen when content loads and pushes existing content around. The fixes are mostly about reserving space in advance.

- Always set width and height (or an aspect ratio) on images and video so the browser reserves the box before the asset loads:

```css
img {
  width: 100%;
  height: auto;
  aspect-ratio: 16 / 9;
}
```

- Reserve space for ads, embeds, and dynamically injected banners.
- Avoid inserting content above existing content after load, unless it is a response to user interaction.
- Use `font-display` strategies that minimize reflow when web fonts swap in, and preload critical fonts.

## Lab versus field data

There are two ways to measure these metrics, and they answer different questions.

- Lab data comes from tools like Lighthouse, run in a controlled environment. It is reproducible and good for debugging, but it is a single simulated session.
- Field data, also called real user monitoring, comes from actual visitors on real devices and networks. It is what reflects user experience over time.

A page can score well in the lab and poorly in the field because real users have slower devices, weaker networks, and unpredictable interaction patterns. Treat lab data as a diagnostic and field data as the source of truth.

## Measuring in code

The web-vitals library reports these metrics from real sessions:

```js
import { onLCP, onINP, onCLS } from 'web-vitals';

onLCP(console.log);
onINP(console.log);
onCLS(console.log);
```

Send the values to an analytics endpoint and watch the distribution, not just the average. The 75th percentile is the common reporting point, because a good experience for most users matters more than a good average skewed by fast devices.

## A working method

- Start from field data to find which metric is actually failing.
- Reproduce the problem in the lab with throttling that matches your real users.
- Apply the targeted fix for that specific metric rather than optimizing everything at once.
- Re-measure in the field after the change ships, since lab improvements do not always translate.

Performance work pays off most when it is driven by real measurements and focused on the single metric that is hurting users.$q$, array[$q$Performance$q$, $q$Core Web Vitals$q$, $q$Metrics$q$, $q$Optimization$q$, $q$User Experience$q$], true, 3, now() - interval '9 hours')
on conflict (slug) do update set title=excluded.title, category=excluded.category, level=excluded.level, summary=excluded.summary, body=excluded.body, tags=excluded.tags, published=true, sort=excluded.sort, updated_at=now();

insert into public.learn_articles (title, slug, category, level, summary, body, tags, published, sort, created_at)
values ($q$Managing State in Modern React: Local, Context, and Server State$q$, $q$frontend-react-state-management$q$, $q$Frontend$q$, $q$Advanced$q$, $q$A framework for choosing where state should live: component-local, shared via context, or synchronized from a server. Explains why server state needs different tools than client state.$q$, $q$State management questions usually get answered with a library name, but the more useful question is what kind of state is being managed. Different categories of state have different lifecycles and ownership, and matching each to the right mechanism prevents most of the complexity people blame on React. A clear mental model matters more than any single tool.

## Categories of state

It helps to separate state into a few kinds:

- Local UI state: the open or closed status of a menu, a form field value, a hover flag. Owned by one component.
- Shared client state: a theme, the current user's preferences, a selected locale. Needed by many components but originates on the client.
- Server state: data that lives in a database and is fetched over the network, such as a list of posts or a user profile. The client holds a cached copy, not the source of truth.
- URL state: filters, pagination, and the current view, which often belong in the address bar so they can be shared and restored.

Most pain comes from treating server state like client state. They behave differently and need different tools.

## Local state with useState and useReducer

Keep state as close to where it is used as possible. Co-locating state limits re-renders and keeps components easy to reason about.

```jsx
function Disclosure() {
  const [open, setOpen] = useState(false);
  return (
    <section>
      <button onClick={() => setOpen((o) => !o)}>Toggle</button>
      {open && <p>Details here</p>}
    </section>
  );
}
```

When updates follow rules or several values change together, `useReducer` keeps the logic in one predictable place:

```jsx
function reducer(state, action) {
  switch (action.type) {
    case 'increment': return { count: state.count + 1 };
    case 'reset': return { count: 0 };
    default: return state;
  }
}
```

Reach for a reducer when transitions become hard to express as isolated setState calls.

## Context for shared client state

Context passes values down the tree without threading props through every level. It solves distribution, not performance.

```jsx
const ThemeContext = createContext('light');

function App() {
  const [theme, setTheme] = useState('light');
  return (
    <ThemeContext.Provider value={{ theme, setTheme }}>
      <Page />
    </ThemeContext.Provider>
  );
}
```

Two cautions:

- Every consumer re-renders when the context value changes. A single context holding many unrelated values causes broad re-renders. Split contexts by concern, or memoize the provider value.
- Context is not a cache or a state manager. It is a transport. Putting server data directly into context tends to reinvent caching, poorly.

## Server state deserves its own tools

Server state is fundamentally different from client state:

- It is asynchronous and can fail.
- It can be stale, because the real value lives on the server and may change without the client knowing.
- It is shared across components that should not each fetch it independently.
- It needs loading, error, retry, and revalidation behavior.

Trying to model this with `useState` and manual `useEffect` fetching leads to duplicated requests, race conditions, and stale data. Dedicated data libraries such as React Query or SWR handle caching, deduplication, background refetching, and invalidation.

```jsx
function Profile({ id }) {
  const { data, isLoading, error } = useQuery({
    queryKey: ['user', id],
    queryFn: () => fetch('/api/users/' + id).then((r) => r.json()),
  });

  if (isLoading) return 'Loading';
  if (error) return 'Something went wrong';
  return data.name;
}
```

The cache key ties the request to its data, so multiple components asking for the same user share one request and one cached result.

## URL as state

For things like the active tab, search query, or page number, the URL is often the best store. It makes the view shareable, restorable on refresh, and navigable with the back button. Pushing this state into client memory loses all of those properties.

## A decision guide

- Used by one component only: local `useState` or `useReducer`.
- Shared by many components, originates on the client, changes rarely: context.
- Comes from the server and is cached on the client: a data-fetching library, not context or global state.
- Should be shareable or survive a refresh: the URL.
- Complex client state shared widely across a large app: a dedicated client store, chosen only after the simpler options prove insufficient.

## Avoiding common mistakes

- Do not lift state higher than it needs to go. Co-location reduces re-renders and coupling.
- Do not store derived values in state. Compute them during render instead, to avoid them going out of sync.
- Do not put server data in context and then rebuild caching by hand.
- Introduce a global store only when prop drilling and context genuinely stop scaling.

Choosing the right category first makes the tool choice almost obvious, and keeps most of the app on the simplest option that works.$q$, array[$q$React$q$, $q$State Management$q$, $q$Context$q$, $q$Data Fetching$q$, $q$Architecture$q$], true, 4, now() - interval '12 hours')
on conflict (slug) do update set title=excluded.title, category=excluded.category, level=excluded.level, summary=excluded.summary, body=excluded.body, tags=excluded.tags, published=true, sort=excluded.sort, updated_at=now();

insert into public.learn_articles (title, slug, category, level, summary, body, tags, published, sort, created_at)
values ($q$Web Accessibility Fundamentals Every Frontend Developer Should Know$q$, $q$frontend-web-accessibility-fundamentals$q$, $q$Frontend$q$, $q$Beginner$q$, $q$The core accessibility practices that cover most real-world needs: semantic HTML, keyboard support, labels, focus, and contrast. Practical examples with the reasoning behind each rule.$q$, $q$Accessibility means building interfaces that people can use regardless of how they interact with a device, whether through a screen reader, a keyboard alone, voice control, or a magnifier. Most accessibility wins come from a small set of fundamentals rather than exotic techniques. Getting these right benefits everyone, not only users with disabilities.

## Start with semantic HTML

The single most effective practice is using the correct element for the job. Native elements carry built-in roles, keyboard behavior, and states that assistive technology understands for free.

- A `button` element is focusable, is announced as a button, and responds to Enter and Space automatically.
- A styled `div` with a click handler has none of that.

```html
<!-- Accessible and keyboard-operable by default -->
<button type="button">Save</button>

<!-- Not focusable, not announced, no keyboard support -->
<div class="btn" onclick="save()">Save</div>
```

The same reasoning applies to headings, lists, `nav`, `main`, and form controls. Reaching for ARIA to recreate what a native element already provides is almost always the wrong move. The first rule of ARIA is to not use ARIA when a native element will do.

## Keyboard access

Many people navigate entirely by keyboard. Every interactive control must be reachable with Tab, operable with Enter or Space, and dismissible with Escape where relevant. Two things to verify:

- The tab order follows the visual and logical order. This usually happens naturally when the DOM order matches the layout.
- Focus is never trapped unexpectedly, except intentionally inside a modal dialog, which should return focus to the trigger on close.

Avoid positive `tabindex` values, which override natural order and cause confusing jumps. Use `tabindex="0"` only to make a custom interactive element focusable, and `tabindex="-1"` to move focus programmatically.

## Visible focus indicators

Keyboard users need to see where focus currently sits. Removing the focus outline without providing a replacement makes a page unusable for them.

```css
/* Do not do this with no alternative */
:focus { outline: none; }

/* Provide a clear, visible indicator instead */
:focus-visible {
  outline: 3px solid #1a73e8;
  outline-offset: 2px;
}
```

The `:focus-visible` selector shows the indicator for keyboard interaction while avoiding an outline on mouse clicks, which addresses the usual reason people remove outlines.

## Labels and names

Every form control needs an accessible name so a screen reader can announce its purpose. The most robust way is a real label associated with the control.

```html
<label for="email">Email address</label>
<input id="email" type="email" name="email" />
```

When a visible label is not possible, provide a name another way, but prefer a visible one. Placeholder text is not a label; it disappears on input and is often too low in contrast. For icon-only buttons, give an explicit name:

```html
<button type="button" aria-label="Close dialog">X</button>
```

## Images and alternative text

Images that convey information need descriptive alternative text. Images that are purely decorative should have an empty alt attribute so screen readers skip them.

- Informative: describe the content or function, not the file.
- Decorative: use `alt=""` so it is ignored rather than read as a filename.

```html
<img src="/chart.png" alt="Sales rose 20 percent from March to April" />
<img src="/divider.png" alt="" />
```

## Color and contrast

Text must have enough contrast against its background to be readable. The common target is a contrast ratio of at least 4.5 to 1 for normal text and 3 to 1 for large text. Also avoid using color as the only way to convey meaning: pair it with text, an icon, or a pattern so that users who cannot distinguish certain colors still get the information.

## Respect user preferences

Some users are sensitive to motion. Honor their system setting to reduce animation:

```css
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

## Test with real tools

Automated checkers catch only part of the picture, roughly a third of issues, but they are a fast first pass.

- Run an automated audit such as the accessibility checks in browser dev tools.
- Navigate the whole page using only the keyboard and confirm every action is possible.
- Try a screen reader to hear how content and controls are announced.

## A starting checklist

- Use native semantic elements before custom ones.
- Ensure everything works with the keyboard alone.
- Keep a visible focus indicator.
- Give every control and image an accessible name or empty alt.
- Meet contrast ratios and never rely on color alone.
- Respect reduced-motion preferences.

Accessibility is not a final polish step. Building on these fundamentals from the start is far cheaper than retrofitting, and it produces a more robust interface for every user.$q$, array[$q$Accessibility$q$, $q$HTML$q$, $q$ARIA$q$, $q$Keyboard$q$, $q$Inclusive Design$q$, $q$CSS$q$], true, 5, now() - interval '15 hours')
on conflict (slug) do update set title=excluded.title, category=excluded.category, level=excluded.level, summary=excluded.summary, body=excluded.body, tags=excluded.tags, published=true, sort=excluded.sort, updated_at=now();

-- ===== backend =====
insert into public.learn_articles (title, slug, category, level, summary, body, tags, published, sort, created_at)
values ($q$REST API Design: Resources, Status Codes, and Versioning$q$, $q$backend-rest-api-design-best-practices$q$, $q$Backend$q$, $q$Beginner$q$, $q$A practical guide to designing predictable REST APIs around resources, correct HTTP semantics, and a versioning strategy that survives change.$q$, $q$Well-designed REST APIs are predictable. Clients should be able to guess how an endpoint behaves from its shape, and servers should communicate outcomes through the HTTP contract rather than custom conventions. This guide covers the decisions that matter most in day-to-day API work.

## Model Resources, Not Actions

REST centers on resources identified by URLs. Prefer plural nouns and let the HTTP method carry the verb.

- `GET /orders` lists orders
- `POST /orders` creates one
- `GET /orders/42` fetches a single order
- `PATCH /orders/42` partially updates it
- `DELETE /orders/42` removes it

Avoid encoding verbs in paths such as `/getOrders` or `/createOrder`. When an operation genuinely is not CRUD, model it as a sub-resource or a resource that represents the process, for example `POST /orders/42/refunds`.

Nest only when a child cannot exist without its parent. Deeply nested paths like `/users/3/orders/42/items/9` become painful; after one level, prefer top-level access with a filter: `GET /items?order_id=42`.

## Use HTTP Methods Honestly

Method semantics are a contract, not decoration.

- `GET` and `HEAD` are safe and must not change state.
- `PUT` and `DELETE` are idempotent: repeating them yields the same end state.
- `POST` is neither safe nor idempotent and is used for creation or non-idempotent actions.
- `PATCH` applies a partial update.

Honoring these lets caches, proxies, and client retry logic work correctly. A `GET` with side effects breaks assumptions throughout the stack.

## Return the Right Status Codes

Status codes let clients branch without parsing prose.

- `200 OK` for a successful read or update
- `201 Created` with a `Location` header for a new resource
- `204 No Content` when there is nothing to return
- `400 Bad Request` for malformed input
- `401 Unauthorized` when authentication is missing or invalid
- `403 Forbidden` when the caller is authenticated but not allowed
- `404 Not Found` for a missing resource
- `409 Conflict` for version or uniqueness clashes
- `422 Unprocessable Entity` for semantically invalid data
- `429 Too Many Requests` when rate limited
- `500` and `503` for server faults

Reserve `4xx` for client errors and `5xx` for server errors. Mislabeling a validation failure as `500` sends clients into retry loops that make incidents worse.

## Design Consistent Payloads

Pick one error shape and use it everywhere. A machine-readable code plus a human message works well.

```json
{
  "error": {
    "code": "order_not_found",
    "message": "No order exists with id 42",
    "details": []
  }
}
```

For collections, return pagination metadata so clients never have to guess. Cursor pagination scales better than offset pagination on large, frequently changing tables because it avoids rows shifting between pages.

```http
GET /orders?limit=20&cursor=eyJpZCI6NDJ9
```

## Filtering, Sorting, and Partial Responses

Keep query parameters for behavior that modifies a read rather than identifies a resource.

- Filtering: `GET /orders?status=paid`
- Sorting: `GET /orders?sort=-created_at`
- Field selection: `GET /orders?fields=id,total`

Document defaults explicitly, including the default page size and maximum allowed limit, so clients cannot accidentally request unbounded result sets.

## Versioning That Survives Change

Breaking changes are inevitable; the goal is to introduce them without breaking existing clients.

- URL versioning (`/v1/orders`) is the most visible and the easiest to route and cache.
- Header versioning (`Accept: application/vnd.api.v2+json`) keeps URLs stable but is harder to test by hand.

URL versioning is the pragmatic default for most teams. Whatever the mechanism, treat additive changes (new optional fields, new endpoints) as non-breaking and avoid them triggering a version bump. Reserve new versions for removals, renames, and changes in meaning. Publish a deprecation timeline and signal it with a `Deprecation` header so clients have a migration window.

## Idempotency for Writes

Networks drop responses, so clients retry. For non-idempotent creation, accept an idempotency key.

```http
POST /payments
Idempotency-Key: 9f1c2b7a-5e2a-4a1e-9f3d-7c0b2a1d4e5f
```

The server stores the result for that key and returns the same response on a replay, preventing duplicate charges.

## Practical Checklist

- Use nouns for paths and methods for verbs.
- Map outcomes to accurate status codes.
- Standardize error and pagination shapes.
- Validate input and reject early with `400` or `422`.
- Version deliberately and deprecate on a schedule.
- Support idempotency keys for critical writes.

Consistency compounds. An API where every endpoint follows the same rules is far cheaper to consume, document, and maintain than one that is individually clever in a dozen different ways.$q$, array[$q$REST API$q$, $q$HTTP$q$, $q$API Design$q$, $q$Status Codes$q$, $q$Versioning$q$], true, 1, now() - interval '4 hours')
on conflict (slug) do update set title=excluded.title, category=excluded.category, level=excluded.level, summary=excluded.summary, body=excluded.body, tags=excluded.tags, published=true, sort=excluded.sort, updated_at=now();

insert into public.learn_articles (title, slug, category, level, summary, body, tags, published, sort, created_at)
values ($q$Authentication and Authorization: Sessions, JWT, and OAuth2$q$, $q$backend-authentication-authorization-sessions-jwt-oauth2$q$, $q$Backend$q$, $q$Intermediate$q$, $q$How sessions, JSON Web Tokens, and OAuth2 differ, and when each belongs in a backend. Covers the common security trade-offs for each approach.$q$, $q$Authentication answers who a caller is; authorization answers what that caller may do. Backends conflate the two at their peril. This article separates the concepts and then compares the three mechanisms teams reach for most often.

## Authentication vs Authorization

Authentication verifies identity, usually by checking a password, a token, or a trusted third party. Authorization is the policy layer that decides whether an authenticated principal can perform a specific action on a specific resource. A system can authenticate a user correctly and still make authorization mistakes, which is why access checks must live close to the data, not only at the edge.

## Session-Based Authentication

The classic approach stores server-side session state and hands the client an opaque session identifier in a cookie.

- The server creates a session record on login and returns a cookie.
- Each request includes the cookie; the server looks up the session.
- Logout deletes the session record, so revocation is immediate.

Sessions are simple to reason about and easy to revoke. The cost is state: every request needs access to the session store, which is usually Redis or a database. Secure cookie flags are essential.

```http
Set-Cookie: sid=abc123; HttpOnly; Secure; SameSite=Lax; Path=/
```

`HttpOnly` blocks JavaScript access, mitigating token theft via cross-site scripting. `SameSite` reduces cross-site request forgery exposure, though state-changing endpoints should still carry CSRF protection.

## JSON Web Tokens

A JWT is a signed, self-contained token. It carries claims the server can verify without a database lookup.

```json
{
  "sub": "user_42",
  "role": "editor",
  "exp": 1735689600
}
```

The token has three parts: a header, a payload of claims, and a signature. The server validates the signature and expiry, then trusts the claims.

The appeal is statelessness: any server holding the signing key can validate a token, which suits horizontally scaled services. The hard part is revocation. Because the token is self-contained, a logout or a compromised token cannot be invalidated before it expires unless extra machinery is added.

The common pattern is a short-lived access token paired with a longer-lived refresh token:

- Access tokens expire in minutes, limiting the damage of a leak.
- Refresh tokens are stored server-side so they can be revoked.
- A revocation list or token version counter handles emergencies.

Two frequent mistakes deserve attention. First, never accept the `alg` field blindly; pin the expected algorithm so an attacker cannot switch it to `none`. Second, do not place secrets in the payload, because it is only base64-encoded, not encrypted.

## OAuth2 and Delegated Access

OAuth2 is an authorization framework for delegated access. It lets a user grant one application limited access to resources held by another, without sharing a password. It is what powers "sign in with" buttons and third-party integrations.

The most common flow is Authorization Code with PKCE:

1. The app redirects the user to the authorization server.
2. The user authenticates and consents to specific scopes.
3. The authorization server returns a short-lived code.
4. The app exchanges the code plus a PKCE verifier for tokens.

PKCE protects public clients, such as mobile and single-page apps, that cannot keep a client secret. Scopes express granularity: a token might allow `read:orders` but not `write:orders`.

A crucial distinction: OAuth2 handles authorization, not identity. OpenID Connect is the layer built on top of OAuth2 that adds authentication by issuing an ID token describing the user. Using raw OAuth2 as a login mechanism without OpenID Connect is a well-known source of security bugs.

## Choosing an Approach

- A single web application with a backend it controls is well served by sessions. Revocation is trivial and the model is easy to audit.
- A fleet of internal services or a public API often benefits from short-lived JWTs for stateless verification, backed by refresh tokens for revocation.
- Third-party access, partner integrations, and social login call for OAuth2, with OpenID Connect when identity is needed.

These are not mutually exclusive. A browser session can protect the main app while the backend mints JWTs for service-to-service calls.

## Authorization Models

Once identity is settled, decide how permissions are expressed.

- Role-based access control assigns permissions to roles and roles to users. It is simple and covers most needs.
- Attribute-based access control evaluates rules over attributes of the user, resource, and context, which suits fine-grained policies.

Whatever the model, enforce checks on the server for every request. Hiding a button in the UI is not access control; the backend must assume any request can be forged and verify authorization each time.

## Summary

Keep authentication and authorization distinct. Sessions trade statefulness for easy revocation, JWTs trade easy revocation for stateless scale, and OAuth2 solves delegated access rather than login. Match the mechanism to the trust boundary, and never let a client-side check stand in for a server-side one.$q$, array[$q$Authentication$q$, $q$Authorization$q$, $q$JWT$q$, $q$OAuth2$q$, $q$Security$q$, $q$Sessions$q$], true, 2, now() - interval '7 hours')
on conflict (slug) do update set title=excluded.title, category=excluded.category, level=excluded.level, summary=excluded.summary, body=excluded.body, tags=excluded.tags, published=true, sort=excluded.sort, updated_at=now();

insert into public.learn_articles (title, slug, category, level, summary, body, tags, published, sort, created_at)
values ($q$Message Queues and Event-Driven Architecture Explained$q$, $q$backend-message-queues-event-driven-architecture$q$, $q$Backend$q$, $q$Intermediate$q$, $q$What message queues and event-driven systems actually buy a backend, the delivery guarantees involved, and the failure modes every design must plan for.$q$, $q$Synchronous request-response is the default way services talk, but it couples the caller to the callee's availability and latency. Message queues and event-driven architecture decouple them, trading immediacy for resilience and scale. Understanding the guarantees and the failure modes is what separates a robust design from a fragile one.

## Why Decouple with Messaging

When service A calls service B directly, A is only as available as B. If B is slow, A is slow; if B is down, A fails. Introducing a broker between them changes the dynamic.

- The producer writes a message and moves on.
- The broker durably holds the message.
- The consumer processes it when ready, at its own pace.

This buys three things: temporal decoupling, because producer and consumer need not be up at the same time; load leveling, because a queue absorbs bursts that would otherwise overwhelm a consumer; and independent scaling, because consumers can be added without changing the producer.

## Queues vs Logs

Two broker shapes dominate, and they behave differently.

A traditional message queue, such as RabbitMQ or a cloud equivalent, delivers each message to one consumer and removes it once acknowledged. This fits task distribution where each job should run exactly once across a pool of workers.

A distributed log, such as Apache Kafka, keeps an ordered, replayable record. Messages are not deleted on consumption; consumers track their own offset. Multiple consumer groups can read the same stream independently, and a new consumer can replay history from the beginning. This fits event streaming and analytics where many parties care about the same events.

## Commands vs Events

The payload's intent shapes the whole design.

- A command tells a specific service to do something: `ChargeCard`. It expresses a request and usually has one logical handler.
- An event states that something happened: `OrderPlaced`. It is a fact, broadcast to whoever cares, with no assumption about who reacts.

Event-driven architecture favors events. The producer announces facts and remains ignorant of consumers, which keeps services loosely coupled and lets new consumers appear without the producer changing.

```json
{
  "type": "OrderPlaced",
  "order_id": 42,
  "customer_id": 7,
  "total": 59.90,
  "occurred_at": "2026-02-01T10:15:00Z"
}
```

## Delivery Guarantees

No distributed system offers free exactly-once delivery end to end. The realistic options are:

- At-most-once: messages may be lost but never duplicated. Rarely acceptable.
- At-least-once: messages are never lost but may be delivered more than once. The common default.
- Exactly-once: achievable only within specific broker and processing boundaries, and usually emulated at the application level.

Because at-least-once is the norm, consumers must be idempotent. Processing the same `OrderPlaced` twice must not charge the customer twice. A typical technique records processed message identifiers and skips duplicates.

```js
async function handle(event) {
  if (await seen(event.id)) return;    // already processed
  await applyEffect(event);
  await markSeen(event.id);
}
```

Note the ordering risk: if the effect succeeds but marking fails, the message will be redelivered and the effect must still be safe to repeat. True idempotency lives in `applyEffect`, not only in the dedup check.

## Ordering and Partitioning

Global ordering across a high-throughput topic is expensive. Logs provide ordering only within a partition. To keep related events ordered, route them to the same partition using a key such as the order id. Events for different orders can then be processed in parallel while each order's events stay sequential.

## Failure Modes to Plan For

Messaging removes some failures and introduces others.

- Poison messages that always fail should be routed to a dead-letter queue after a retry limit, so one bad message does not block the stream.
- Consumer lag, where messages arrive faster than they are processed, needs monitoring; alert on queue depth and lag, not just error rates.
- Retry storms can amplify an outage; use capped exponential backoff rather than tight retry loops.
- Schema drift breaks consumers silently; version event schemas and prefer additive changes.

## The Outbox Pattern

A subtle bug: a service updates its database and then publishes an event, but crashes between the two steps. Now state and events disagree. The transactional outbox solves this by writing the event into an outbox table inside the same database transaction as the state change. A separate relay reads the outbox and publishes reliably, guaranteeing the event is sent if and only if the state committed.

## When Not to Use Messaging

Messaging is not free. It adds a broker to operate, eventual consistency to reason about, and debugging that spans multiple logs. If a caller genuinely needs an immediate answer, a synchronous call is simpler and clearer. Reach for messaging when decoupling, buffering, or fan-out provide real value, not by default.

## Summary

Message queues decouple producers from consumers in time and scale. Choose a queue for task distribution and a log for replayable event streams. Assume at-least-once delivery, make consumers idempotent, preserve ordering through partition keys, and protect the system with dead-letter queues and the outbox pattern.$q$, array[$q$Message Queues$q$, $q$Event-Driven$q$, $q$Kafka$q$, $q$Idempotency$q$, $q$Distributed Systems$q$, $q$Architecture$q$], true, 3, now() - interval '10 hours')
on conflict (slug) do update set title=excluded.title, category=excluded.category, level=excluded.level, summary=excluded.summary, body=excluded.body, tags=excluded.tags, published=true, sort=excluded.sort, updated_at=now();

insert into public.learn_articles (title, slug, category, level, summary, body, tags, published, sort, created_at)
values ($q$Building Resilient APIs: Rate Limiting, Retries, Idempotency, and Circuit Breakers$q$, $q$backend-resilient-apis-rate-limiting-retries-idempotency-circuit-breakers$q$, $q$Backend$q$, $q$Advanced$q$, $q$Four patterns that keep APIs stable under load and partial failure: rate limiting, safe retries, idempotency, and circuit breakers, with the trade-offs of each.$q$, $q$Resilience is the ability to keep working, or to fail gracefully, when dependencies misbehave. A healthy-looking service can still take down a whole system if it retries blindly, lacks backpressure, or duplicates side effects. These four patterns, used together, turn fragile call chains into stable ones.

## Rate Limiting and Backpressure

Rate limiting protects a service from being overwhelmed, whether by an abusive client, a buggy loop, or a legitimate traffic spike. It is a form of backpressure: the server tells callers to slow down rather than collapsing.

Two algorithms are common.

- The token bucket refills tokens at a steady rate and allows short bursts up to the bucket size. It is flexible and widely used.
- The sliding window counts requests over a moving interval and smooths out the boundary spikes that fixed windows suffer from.

Communicate limits clearly so clients can adapt.

```http
HTTP/1.1 429 Too Many Requests
Retry-After: 2
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 0
```

Rate limit per principal, not just per IP, since many users can share an address and one user can span many addresses. Place limits at the edge for coarse protection and inside critical services for fine protection of scarce resources such as a database connection pool.

## Retries Done Safely

Retries recover from transient faults such as a dropped packet or a brief restart. Done carelessly, they amplify outages: a struggling dependency receives a flood of retries exactly when it is least able to cope.

Safe retries follow a few rules.

- Retry only idempotent or clearly safe operations.
- Retry only transient errors: timeouts, connection resets, `503`, and `429`. Never retry a `400` or `422`; the input will not improve.
- Use exponential backoff with jitter so clients do not retry in lockstep.
- Cap the number of attempts and the total time budget.

```js
async function withRetry(fn, max = 4) {
  for (let attempt = 0; ; attempt++) {
    try {
      return await fn();
    } catch (err) {
      if (attempt >= max || !isTransient(err)) throw err;
      const base = 2 ** attempt * 100;
      const jitter = Math.random() * base;
      await sleep(base + jitter);
    }
  }
}
```

Jitter matters more than it looks. Without it, thousands of clients that failed at the same instant retry at the same instant, producing the synchronized thundering herd that backoff was meant to prevent.

## Idempotency Makes Retries Safe

Retries are only safe if repeating an operation is harmless. Reads are naturally idempotent. Writes are not, which is why creation endpoints need explicit idempotency.

The standard approach is an idempotency key supplied by the client.

```http
POST /payments
Idempotency-Key: 7c0b2a1d-4e5f-9f1c-2b7a-5e2a4a1e9f3d
```

On first receipt, the server processes the request and stores the response against the key. On a replay, it returns the stored response without repeating the side effect. The key must be stored atomically with the effect, often in the same transaction, so a crash cannot leave the effect done but the key unrecorded. Keys should expire after a reasonable window to bound storage.

Idempotency and retries are a pair: retries provide recovery, idempotency provides safety, and neither is complete alone.

## Circuit Breakers

When a dependency is truly down, continuing to call it wastes resources and ties up threads waiting for timeouts. A circuit breaker detects sustained failure and stops calls for a while, failing fast instead.

The breaker has three states.

- Closed: calls flow normally while failures stay below a threshold.
- Open: the failure threshold is crossed, so calls are rejected immediately for a cooldown period.
- Half-open: after the cooldown, a few trial calls are allowed. Success closes the breaker; failure reopens it.

Failing fast has two benefits. It frees the caller's resources that would otherwise block on timeouts, and it gives the struggling dependency room to recover instead of being hammered. Pair a breaker with a fallback where possible: serve stale cached data, a default value, or a clear degraded response rather than a hard error.

## Timeouts and Bulkheads

Two supporting patterns make the others work. Every outbound call needs an aggressive timeout; without one, a slow dependency exhausts the caller's thread or connection pool and the failure spreads. Bulkheads isolate resources so that one slow dependency cannot consume the capacity needed by others, much as compartments stop a ship from flooding entirely.

## Putting It Together

These patterns compose into a layered defense.

- Timeouts bound how long any call can hang.
- Retries with backoff and jitter recover from transient faults.
- Idempotency keys make those retries safe.
- Circuit breakers stop calls to a dependency that is genuinely down.
- Rate limiting and bulkheads protect the service from overload and isolate failures.

Each pattern has a cost: rate limits can reject valid traffic, retries add latency and load, idempotency adds storage and complexity, and breakers can trip too eagerly if tuned poorly. Measure real failure behavior, set thresholds from data rather than guesses, and test the system under induced failure so the resilience is proven rather than assumed.$q$, array[$q$Resilience$q$, $q$Rate Limiting$q$, $q$Retries$q$, $q$Idempotency$q$, $q$Circuit Breaker$q$, $q$Reliability$q$], true, 4, now() - interval '13 hours')
on conflict (slug) do update set title=excluded.title, category=excluded.category, level=excluded.level, summary=excluded.summary, body=excluded.body, tags=excluded.tags, published=true, sort=excluded.sort, updated_at=now();

insert into public.learn_articles (title, slug, category, level, summary, body, tags, published, sort, created_at)
values ($q$Monolith vs Microservices: Choosing a Backend Architecture$q$, $q$backend-monolith-vs-microservices-choosing-architecture$q$, $q$Backend$q$, $q$Advanced$q$, $q$An even-handed comparison of monolithic and microservice architectures, the organizational and operational costs each carries, and how to decide between them.$q$, $q$Few backend decisions attract as much dogma as monolith versus microservices. Neither is universally correct. The right answer depends on team size, operational maturity, and how clearly the domain boundaries are understood. This article lays out the trade-offs so the choice can be made on evidence rather than fashion.

## What Each Term Means

A monolith deploys the entire application as a single unit. Modules call each other in-process, share one codebase, and usually one database. A modular monolith keeps strong internal boundaries while retaining the single deployment.

Microservices split the system into independently deployable services, each owning its data and communicating over the network. Each service can be built, scaled, and released on its own.

The distinction that matters is not code organization but the deployment and data boundary. Crossing a network and splitting the database is what introduces most of the cost.

## The Case for the Monolith

For most teams starting out, a monolith is the pragmatic default.

- Simplicity: one codebase to build, test, and deploy.
- Local reasoning: a function call is reliable and fast; there is no network in between.
- Transactions: a single database allows ordinary ACID transactions across the whole operation, avoiding distributed consistency problems entirely.
- Debugging: one process, one log stream, one stack trace.

The weaknesses appear with scale. A large monolith can become hard to reason about, every change requires redeploying the whole system, and the entire application tends to scale as one even when only a fraction is a bottleneck. A disciplined modular monolith delays these problems considerably and is often the right first destination.

## The Case for Microservices

Microservices address organizational and scaling pressures that a monolith handles poorly.

- Independent deployment: teams release on their own cadence without coordinating one big deploy.
- Targeted scaling: the one hot service scales without scaling everything.
- Fault isolation: a crash in one service need not take down the rest, if boundaries are designed for it.
- Technology freedom: a service can use the stack that fits its job.

These benefits are real but conditional. They depend on genuinely independent services; if a change routinely spans several services, the split has added coordination rather than removing it.

## The Costs People Underestimate

Microservices trade code complexity for operational and distributed-systems complexity, which is harder.

- The network is unreliable. Calls fail, time out, and arrive out of order, so every inter-service call needs timeouts, retries, and often circuit breakers.
- Data consistency becomes distributed. A single transaction is no longer possible across services, so workflows rely on patterns such as sagas and eventual consistency.
- Testing spans processes. Integration and contract testing grow more involved than in-process tests.
- Observability is mandatory. Distributed tracing, centralized logging, and correlation identifiers move from nice-to-have to essential.
- Operational overhead multiplies: deployment pipelines, service discovery, configuration, and on-call surface area all increase per service.

A distributed transaction that was a one-line database commit in a monolith becomes a multi-step saga with compensating actions in microservices.

```js
// A saga coordinates steps that cannot share one transaction.
async function placeOrder(cmd) {
  const order = await orders.create(cmd);
  try {
    await payments.charge(order);
    await inventory.reserve(order);
  } catch (err) {
    await payments.refund(order);   // compensate
    await orders.cancel(order);
    throw err;
  }
}
```

## Conway's Law

Systems tend to mirror the communication structure of the organization that builds them. Microservices suit organizations already split into autonomous teams with clear ownership; the architecture matches how the people work. Imposing microservices on a small, tightly coupled team usually produces a distributed monolith: services that must deploy together, the operational cost of a split with none of the independence.

## How to Decide

Weigh these factors honestly.

- Team size and structure: a handful of engineers is almost always better served by a monolith.
- Domain clarity: splitting services along boundaries that are not yet understood tends to produce the wrong boundaries, which are expensive to move later.
- Operational maturity: without solid CI/CD, monitoring, and tracing, microservices amplify weaknesses instead of hiding them.
- Scaling pressure: adopt a split when one part genuinely needs separate scaling or deployment, not speculatively.

## A Reasonable Path

A common and effective progression is to start with a modular monolith, enforce clean internal boundaries, and watch where real pain appears. When a module shows clear, independent scaling needs, a stable interface, and ideally its own team, extract it into a service. This lets boundaries be validated in a cheap environment before paying the distributed-systems tax, and avoids both premature fragmentation and a tangled monolith.

## Summary

The monolith optimizes for simplicity and is the right starting point for most teams. Microservices optimize for independent deployment and scaling at the cost of significant operational complexity. Choose based on team structure, domain clarity, and operational maturity, and let an existing modular monolith guide where, and whether, to split.$q$, array[$q$Microservices$q$, $q$Monolith$q$, $q$Architecture$q$, $q$System Design$q$, $q$Scalability$q$, $q$Distributed Systems$q$], true, 5, now() - interval '16 hours')
on conflict (slug) do update set title=excluded.title, category=excluded.category, level=excluded.level, summary=excluded.summary, body=excluded.body, tags=excluded.tags, published=true, sort=excluded.sort, updated_at=now();

-- ===== dsa =====
insert into public.learn_articles (title, slug, category, level, summary, body, tags, published, sort, created_at)
values ($q$Big-O Notation and Complexity Analysis Made Simple$q$, $q$dsa-big-o-notation-complexity-analysis$q$, $q$DSA$q$, $q$Beginner$q$, $q$A practical introduction to Big-O notation that explains how to reason about time and space cost without heavy math. Covers common growth classes and how to analyze real code.$q$, $q$Big-O notation describes how the running time or memory use of an algorithm grows as the input size grows. It ignores machine speed and constant factors so two implementations can be compared on the same footing. The goal is not an exact instruction count but an honest picture of how an algorithm behaves when the input gets large.

## Why Growth Rate Matters

On ten elements almost anything is fast. The differences appear at scale. An algorithm that does roughly n operations and one that does n squared operations may both finish instantly on 100 items, but on one million items the second does a trillion operations while the first does a million. Big-O captures that gap.

Formally, a function is O(g(n)) if beyond some input size it stays below a constant multiple of g(n). In practice this means keep the fastest growing term and drop constants and lower-order terms. So 3n + 50 becomes O(n), and 2n squared + 10n becomes O(n squared).

## The Common Classes

Ordered from fastest to slowest growth:

- O(1) constant: cost does not depend on input size, such as reading an array index.
- O(log n) logarithmic: the input is repeatedly halved, as in binary search.
- O(n) linear: a single pass over the data.
- O(n log n): efficient sorting such as mergesort and heapsort.
- O(n squared) quadratic: nested loops over the same data.
- O(2^n) exponential and O(n!) factorial: brute-force over all subsets or permutations.

A useful reference point: log base 2 of one million is about 20, so an O(log n) step count stays tiny even for huge inputs.

## Analyzing Code

The mechanical approach is to count how many times the innermost work runs as a function of n.

```python
def has_duplicate(nums):
    # O(n^2): for each item, scan the rest
    for i in range(len(nums)):
        for j in range(i + 1, len(nums)):
            if nums[i] == nums[j]:
                return True
    return False
```

The outer loop runs n times and the inner loop runs up to n times, so the total is proportional to n squared. A set turns this into a single pass:

```python
def has_duplicate_fast(nums):
    # O(n) time, O(n) space
    seen = set()
    for x in nums:
        if x in seen:
            return True
        seen.add(x)
    return False
```

Set membership is O(1) on average, so the whole function is O(n). The trade is extra memory for the set, which is where space complexity enters.

## Sequential Versus Nested Work

Two loops one after another add, two loops nested multiply.

```python
# O(n) + O(n) = O(n)
for x in nums: process(x)
for x in nums: process(x)

# O(n) * O(n) = O(n^2)
for x in nums:
    for y in nums:
        pair(x, y)
```

When a loop halves the remaining range each step, the count is logarithmic:

```python
def binary_search(sorted_nums, target):
    lo, hi = 0, len(sorted_nums) - 1
    while lo <= hi:
        mid = (lo + hi) // 2
        if sorted_nums[mid] == target:
            return mid
        if sorted_nums[mid] < target:
            lo = mid + 1
        else:
            hi = mid - 1
    return -1
```

Each iteration discards half the candidates, so at most log base 2 of n iterations run. That is O(log n).

## Best, Average, and Worst Case

Big-O usually refers to the worst case, the upper bound on cost. The average case can differ. Hash lookups are O(1) on average but O(n) in a rare worst case with many collisions. Quicksort is O(n log n) on average but O(n squared) when pivots are chosen poorly. State which case is meant when it matters.

## Space Complexity

The same notation applies to memory beyond the input. A recursive function that goes n levels deep uses O(n) stack space even if it allocates nothing else. Building a hash set of all elements is O(n) space. Reversing an array in place is O(1) extra space.

## Common Pitfalls

- Dropping a hidden loop. Slicing or concatenating inside a loop can turn linear code into quadratic.
- Treating string concatenation in a loop as free. In many languages it copies the whole string each time.
- Ignoring the cost of library calls. Sorting inside a loop multiplies an n log n cost by the loop count.

## Worked Example

Consider summing the digits of every number from 1 to n. There are n numbers and each has about log(n) digits, so the total work is O(n log n), not O(n). Counting the inner work carefully is what separates a correct analysis from a guess. With these rules the growth class of most everyday code can be read directly off its loops and recursion.$q$, array[$q$Big-O$q$, $q$Complexity$q$, $q$Algorithms$q$, $q$Time Complexity$q$, $q$Space Complexity$q$], true, 1, now() - interval '5 hours')
on conflict (slug) do update set title=excluded.title, category=excluded.category, level=excluded.level, summary=excluded.summary, body=excluded.body, tags=excluded.tags, published=true, sort=excluded.sort, updated_at=now();

insert into public.learn_articles (title, slug, category, level, summary, body, tags, published, sort, created_at)
values ($q$Array and String Patterns: Two Pointers and Sliding Window$q$, $q$dsa-two-pointers-sliding-window-patterns$q$, $q$DSA$q$, $q$Intermediate$q$, $q$Two of the most reusable techniques for array and string problems. Learn when to use opposing pointers and how a sliding window turns nested loops into a single pass.$q$, $q$Many array and string problems that look like they need nested loops can be solved in a single pass. Two patterns do most of the work: two pointers, which walk indices toward each other or at different speeds, and the sliding window, which maintains a contiguous range and adjusts its edges. Both reduce an O(n squared) brute force to O(n).

## Two Pointers: Opposite Ends

When the input is sorted, two indices starting at opposite ends can converge based on a comparison. The classic case is finding a pair that sums to a target.

```python
def two_sum_sorted(nums, target):
    lo, hi = 0, len(nums) - 1
    while lo < hi:
        s = nums[lo] + nums[hi]
        if s == target:
            return (lo, hi)
        if s < target:
            lo += 1   # need a larger sum
        else:
            hi -= 1   # need a smaller sum
    return None
```

Because the array is sorted, moving the left pointer can only increase the sum and moving the right can only decrease it, so no valid pair is skipped. Each index moves at most n times, giving O(n) time and O(1) space.

The same converging idea reverses a string in place, checks a palindrome, or merges two sorted arrays from the back.

## Two Pointers: Fast and Slow

A second variant runs two pointers over the same sequence at different speeds. It removes duplicates from a sorted array in place:

```python
def dedupe_sorted(nums):
    if not nums:
        return 0
    write = 1
    for read in range(1, len(nums)):
        if nums[read] != nums[write - 1]:
            nums[write] = nums[read]
            write += 1
    return write   # new length
```

The read pointer scans every element while the write pointer marks where the next unique value belongs. Fast and slow pointers also detect cycles in linked lists, where one moves two steps per one step of the other.

## The Sliding Window

A sliding window maintains a contiguous subarray or substring and expands or shrinks it to satisfy a constraint. It fits problems about the longest, shortest, or best contiguous range.

Consider the longest substring without repeating characters.

```python
def longest_unique(s):
    seen = {}
    start = 0
    best = 0
    for end, ch in enumerate(s):
        if ch in seen and seen[ch] >= start:
            start = seen[ch] + 1   # jump past the repeat
        seen[ch] = end
        best = max(best, end - start + 1)
    return best
```

The window is the range from start to end. When a repeat appears inside the window, the left edge jumps past the previous occurrence. Each character is visited a constant number of times, so the algorithm is O(n) time and O(k) space where k is the alphabet size.

## Fixed-Size Windows

When the window length is fixed, maintain a running aggregate and slide by adding the entering element and removing the leaving one. This finds the maximum sum of any k consecutive numbers.

```python
def max_window_sum(nums, k):
    window = sum(nums[:k])
    best = window
    for i in range(k, len(nums)):
        window += nums[i] - nums[i - k]
        best = max(best, window)
    return best
```

Recomputing each window from scratch would be O(n times k). Reusing the previous sum makes it O(n).

## Choosing the Pattern

A few signals help pick the right tool:

- The array is sorted and a pair or triple is wanted: opposing two pointers.
- Modify an array in place with a stable order: fast and slow pointers.
- Longest or shortest contiguous range under a constraint: variable sliding window.
- A statistic over every fixed-length block: fixed sliding window.

## A Worked Walkthrough

Find the smallest subarray whose sum is at least a target. Expand the window by moving the right edge and adding values. Once the sum reaches the target, shrink from the left while the condition still holds, recording the smallest length.

```python
def min_subarray_len(target, nums):
    start = 0
    total = 0
    best = float('inf')
    for end in range(len(nums)):
        total += nums[end]
        while total >= target:
            best = min(best, end - start + 1)
            total -= nums[start]
            start += 1
    return 0 if best == float('inf') else best
```

The right edge advances n times and the left edge advances at most n times total, so even with the inner while loop the work is O(n). The key insight is that each pointer only moves forward, never backward, which is what keeps these patterns linear.

## Common Mistakes

- Forgetting to shrink the window, which leaves it monotonically growing and wrong.
- Comparing against a stale index after the window start has moved.
- Using a variable window when the problem actually fixes the length, or the reverse.

Mastering these two shapes covers a large fraction of array and string interview questions.$q$, array[$q$Two Pointers$q$, $q$Sliding Window$q$, $q$Arrays$q$, $q$Strings$q$, $q$Patterns$q$], true, 2, now() - interval '8 hours')
on conflict (slug) do update set title=excluded.title, category=excluded.category, level=excluded.level, summary=excluded.summary, body=excluded.body, tags=excluded.tags, published=true, sort=excluded.sort, updated_at=now();

insert into public.learn_articles (title, slug, category, level, summary, body, tags, published, sort, created_at)
values ($q$Hashing and Hash Maps: The Interview Workhorse$q$, $q$dsa-hashing-hash-maps-interview-workhorse$q$, $q$DSA$q$, $q$Intermediate$q$, $q$How hash maps deliver average constant-time lookups, why collisions matter, and the problem patterns where a map turns slow solutions into fast ones.$q$, $q$The hash map is the single most useful data structure in coding interviews. It stores key-value pairs and supports insert, lookup, and delete in average O(1) time. Understanding how it achieves that, and where it can degrade, makes it a tool rather than a black box.

## How Hashing Works

A hash function maps a key to an integer, which is reduced to an index in a backing array. The value is stored at that index. Lookups rehash the key and go straight to the slot, so the cost does not grow with the number of stored items on average.

Two keys can hash to the same slot. This is a collision, and every real hash map handles it. The two dominant strategies are:

- Separate chaining: each slot holds a small list of entries that landed there. A lookup scans that short list.
- Open addressing: on collision the map probes nearby slots by a fixed rule until a free one is found.

As long as the load factor, the ratio of entries to slots, stays low, chains stay short and operations stay near O(1). When the table fills past a threshold it resizes, allocating a larger array and rehashing every entry. A single insert can therefore occasionally be O(n), but spread across many inserts the amortized cost is still O(1).

## The Worst Case

If many keys collide into one slot, lookups degrade to O(n) because the map must scan a long chain. This happens with a poor hash function or with adversarial input crafted to collide. Good general-purpose hash functions and randomized seeds make this rare in practice, but it is why worst-case analysis of hash-based algorithms lists O(n).

## Maps Versus Sets

A set stores only keys and answers membership questions. A map stores keys with associated values. Both share the same hashing machinery. Reach for a set when the question is only whether something was seen, and a map when a count, index, or payload must travel with each key.

## Pattern: Lookups That Replace a Loop

The canonical example is two-sum on an unsorted array. Brute force checks every pair in O(n squared). A map stores each value as it is seen and asks whether the complement already exists.

```python
def two_sum(nums, target):
    seen = {}            # value -> index
    for i, x in enumerate(nums):
        need = target - x
        if need in seen:
            return (seen[need], i)
        seen[x] = i
    return None
```

Each lookup is O(1) on average, so the whole function is O(n) time and O(n) space. The map trades memory for a dimension of looping.

## Pattern: Frequency Counting

Counting occurrences is a natural fit. Grouping anagrams, finding a majority element, or checking whether two strings are anagrams all reduce to comparing counts.

```python
from collections import Counter

def are_anagrams(a, b):
    return Counter(a) == Counter(b)
```

Building each count is O(n) and comparing is O(k) over the distinct characters. Doing the same with sorting would be O(n log n).

## Pattern: Grouping by a Derived Key

Many problems cluster items that share a computed property. Anagrams group by their sorted letters:

```python
from collections import defaultdict

def group_anagrams(words):
    groups = defaultdict(list)
    for w in words:
        key = tuple(sorted(w))
        groups[key].append(w)
    return list(groups.values())
```

The derived key is the signature that collapses equivalent items into one bucket. This shape appears whenever the task is to partition data by some invariant.

## Choosing Keys Carefully

Keys must be hashable and compare by value. In most languages immutable types such as numbers, strings, and tuples work; mutable types such as lists do not. A frequent bug is using a mutable object as a key and then mutating it, which corrupts the map because its slot no longer matches its hash.

For composite keys, build a tuple or a canonical string. For counting over a grid, a tuple of coordinates is a clean key.

## Space and When to Avoid

Hash maps cost O(n) extra memory, which can matter on large inputs or tight constraints. They also do not maintain order by key. When sorted traversal or range queries are needed, a balanced tree or sorted structure giving O(log n) operations is the better choice. When exact worst-case guarantees are required, the amortized O(1) of a hash map may not be acceptable.

## Worked Example

To find the length of the longest consecutive run of integers in an unsorted array, put every value in a set, then for each value that starts a run, meaning its predecessor is absent, count upward.

```python
def longest_consecutive(nums):
    s = set(nums)
    best = 0
    for x in s:
        if x - 1 not in s:        # only start at run beginnings
            length = 1
            while x + length in s:
                length += 1
            best = max(best, length)
    return best
```

Although it looks nested, each number is visited only inside the run it belongs to, so the total is O(n). The set membership checks are what make it possible. This combination of constant-time lookup and clever iteration is the essence of why hash maps dominate interview solutions.$q$, array[$q$Hashing$q$, $q$Hash Maps$q$, $q$Hash Tables$q$, $q$Sets$q$, $q$Collisions$q$, $q$Frequency Counting$q$], true, 3, now() - interval '11 hours')
on conflict (slug) do update set title=excluded.title, category=excluded.category, level=excluded.level, summary=excluded.summary, body=excluded.body, tags=excluded.tags, published=true, sort=excluded.sort, updated_at=now();

insert into public.learn_articles (title, slug, category, level, summary, body, tags, published, sort, created_at)
values ($q$Trees and Graphs: BFS and DFS Traversal$q$, $q$dsa-trees-graphs-bfs-dfs-traversal$q$, $q$DSA$q$, $q$Intermediate$q$, $q$The two foundational graph traversals explained with trees, grids, and general graphs. Covers when to prefer breadth-first over depth-first and how to avoid revisiting nodes.$q$, $q$Most problems about trees, grids, and networks reduce to visiting nodes in a disciplined order. Two traversals cover nearly all of them: breadth-first search, which explores level by level using a queue, and depth-first search, which dives as deep as possible using a stack or recursion. Both run in O(V + E) time, visiting every vertex and edge once.

## Trees as a Starting Point

A tree is a graph with no cycles and one path between any two nodes, so traversal never needs to guard against revisiting. Depth-first traversal of a binary tree has three orders defined by when the node is processed relative to its children.

```python
def inorder(node, out):
    if node is None:
        return
    inorder(node.left, out)
    out.append(node.val)       # left, node, right
    inorder(node.right, out)
```

Inorder on a binary search tree yields sorted values. Preorder processes the node before its children and is useful for copying a tree. Postorder processes children first and suits deletion and computing subtree aggregates. Each is O(n) time and O(h) space for the recursion stack, where h is the height.

## Breadth-First Search

BFS visits all neighbors at the current distance before moving outward. It uses a queue, adding neighbors to the back and processing from the front.

```python
from collections import deque

def bfs_levels(root):
    if root is None:
        return []
    result = []
    q = deque([root])
    while q:
        level = []
        for _ in range(len(q)):      # fixed count = current level
            node = q.popleft()
            level.append(node.val)
            if node.left:  q.append(node.left)
            if node.right: q.append(node.right)
        result.append(level)
    return result
```

Processing exactly the queue length at each step cleanly separates levels. BFS is the natural choice when the answer depends on distance from a source, because the first time it reaches a node is along a shortest path in edge count.

## Depth-First Search on General Graphs

General graphs contain cycles, so a visited set is required or the traversal loops forever. The graph is usually stored as an adjacency list mapping each node to its neighbors.

```python
def dfs(graph, start):
    visited = set()
    order = []
    def visit(node):
        visited.add(node)
        order.append(node)
        for nxt in graph[node]:
            if nxt not in visited:
                visit(nxt)
    visit(start)
    return order
```

The iterative form replaces recursion with an explicit stack, which avoids stack overflow on deep graphs.

```python
def dfs_iterative(graph, start):
    visited = set()
    stack = [start]
    order = []
    while stack:
        node = stack.pop()
        if node in visited:
            continue
        visited.add(node)
        order.append(node)
        for nxt in graph[node]:
            if nxt not in visited:
                stack.append(nxt)
    return order
```

## Shortest Path on Unweighted Graphs

BFS finds the fewest edges from a source to every reachable node. Marking distance as each node is first dequeued guarantees correctness because BFS reaches nodes in nondecreasing distance order.

```python
def shortest_hops(graph, start):
    dist = {start: 0}
    q = deque([start])
    while q:
        node = q.popleft()
        for nxt in graph[node]:
            if nxt not in dist:
                dist[nxt] = dist[node] + 1
                q.append(nxt)
    return dist
```

For weighted edges this does not hold; Dijkstra or a similar algorithm is needed instead.

## Grids as Graphs

A two-dimensional grid is a graph where each cell connects to its orthogonal neighbors. Counting islands, a connected-components problem, uses either traversal from each unvisited land cell.

```python
def count_islands(grid):
    rows, cols = len(grid), len(grid[0])
    seen = set()
    def flood(r, c):
        stack = [(r, c)]
        while stack:
            x, y = stack.pop()
            if (x, y) in seen:
                continue
            seen.add((x, y))
            for dx, dy in ((1,0),(-1,0),(0,1),(0,-1)):
                nx, ny = x + dx, y + dy
                if 0 <= nx < rows and 0 <= ny < cols and grid[nx][ny] == 1 and (nx, ny) not in seen:
                    stack.append((nx, ny))
    count = 0
    for r in range(rows):
        for c in range(cols):
            if grid[r][c] == 1 and (r, c) not in seen:
                flood(r, c)
                count += 1
    return count
```

## Choosing Between Them

- Shortest path in edges, or a level-by-level answer: BFS.
- Exploring all paths, detecting cycles, topological ordering, or subtree computations: DFS.
- Very deep graphs where recursion could overflow: iterative DFS or BFS.
- Memory matters: DFS uses O(h) stack space on a tree, while BFS can hold a whole level, which is wide near the bottom.

## Common Mistakes

- Forgetting the visited set on a cyclic graph, causing infinite loops.
- Marking a node visited when dequeuing rather than when enqueuing in BFS, which can add duplicates to the queue.
- Confusing distance in edges with weighted distance.

With these two traversals and a visited set, the majority of tree and graph problems become variations on a familiar template.$q$, array[$q$Trees$q$, $q$Graphs$q$, $q$BFS$q$, $q$DFS$q$, $q$Traversal$q$, $q$Shortest Path$q$], true, 4, now() - interval '14 hours')
on conflict (slug) do update set title=excluded.title, category=excluded.category, level=excluded.level, summary=excluded.summary, body=excluded.body, tags=excluded.tags, published=true, sort=excluded.sort, updated_at=now();

insert into public.learn_articles (title, slug, category, level, summary, body, tags, published, sort, created_at)
values ($q$Dynamic Programming: From Recursion to Memoization and Tabulation$q$, $q$dsa-dynamic-programming-memoization-tabulation$q$, $q$DSA$q$, $q$Advanced$q$, $q$A step-by-step path from naive recursion to efficient dynamic programming. Learn to spot overlapping subproblems and convert them into memoized or tabulated solutions.$q$, $q$Dynamic programming solves a problem by combining answers to smaller subproblems, storing each answer so it is never recomputed. It applies when a problem has two properties: optimal substructure, meaning an optimal solution is built from optimal solutions to subproblems, and overlapping subproblems, meaning the same subproblem recurs many times. The reliable route is to write the recursion first, then cache it.

## Starting From Recursion

The Fibonacci sequence shows the pattern in miniature. The naive recursion is correct but exponential because it recomputes the same values repeatedly.

```python
def fib(n):
    if n < 2:
        return n
    return fib(n - 1) + fib(n - 2)
```

Computing fib(5) calls fib(3) twice, fib(2) three times, and so on. The call tree has about 2^n nodes, so this is O(2^n) time. The subproblems overlap heavily, which is exactly the signal that dynamic programming will help.

## Top-Down Memoization

Memoization keeps the natural recursion but stores each computed answer in a cache. Before computing, it checks whether the answer already exists.

```python
def fib_memo(n, cache=None):
    if cache is None:
        cache = {}
    if n < 2:
        return n
    if n in cache:
        return cache[n]
    cache[n] = fib_memo(n - 1, cache) + fib_memo(n - 2, cache)
    return cache[n]
```

Now each value from 0 to n is computed once, so the time drops to O(n) with O(n) space for the cache and the call stack. Memoization is often the quickest conversion because the recursive structure is unchanged; only a lookup and a store are added.

## Bottom-Up Tabulation

Tabulation flips the direction. Instead of recursing from the target down, it fills a table from the base cases up, so every value a formula needs is already present.

```python
def fib_tab(n):
    if n < 2:
        return n
    dp = [0] * (n + 1)
    dp[1] = 1
    for i in range(2, n + 1):
        dp[i] = dp[i - 1] + dp[i - 2]
    return dp[n]
```

This removes recursion entirely, avoiding stack limits. Because each entry depends only on the two before it, the table can collapse to two variables and O(1) space.

```python
def fib_constant(n):
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a
```

Recognizing that only a small window of the table is needed is a common optimization once the recurrence is clear.

## Defining the State and Transition

Every dynamic programming solution rests on two decisions. The state is what a subproblem is indexed by, such as a position, a remaining capacity, or a pair of indices. The transition is the recurrence that builds a state from smaller states. Writing these explicitly before coding prevents most mistakes.

Consider the 0/1 knapsack problem: choose items with given weights and values to maximize value without exceeding capacity. The state is the best value using the first i items with capacity c. The transition is to either skip item i or take it.

```python
def knapsack(weights, values, capacity):
    n = len(weights)
    dp = [[0] * (capacity + 1) for _ in range(n + 1)]
    for i in range(1, n + 1):
        w, v = weights[i - 1], values[i - 1]
        for c in range(capacity + 1):
            dp[i][c] = dp[i - 1][c]                 # skip item i
            if w <= c:
                take = dp[i - 1][c - w] + v         # take item i
                dp[i][c] = max(dp[i][c], take)
    return dp[n][capacity]
```

There are n times capacity states and each is O(1) to fill, so the time is O(n times capacity) and the space is the same, reducible to a single row processed carefully.

## A Classic One-Dimensional Example

The longest increasing subsequence asks for the length of the longest strictly increasing run of elements, not necessarily contiguous. The state is the length of the best subsequence ending at index i.

```python
def length_of_lis(nums):
    if not nums:
        return 0
    dp = [1] * len(nums)
    for i in range(len(nums)):
        for j in range(i):
            if nums[j] < nums[i]:
                dp[i] = max(dp[i], dp[j] + 1)
    return max(dp)
```

Each element looks back at all earlier elements, giving O(n squared) time. A more advanced version using binary search reaches O(n log n), which illustrates that a correct dynamic program is often the first step, not the last.

## Memoization or Tabulation

Both reach the same complexity, so the choice is practical:

- Memoization is faster to write from a working recursion and naturally skips states that are never reached.
- Tabulation avoids recursion depth limits and makes space optimization obvious, since the fill order is explicit.
- Tabulation can be marginally faster by avoiding function-call overhead.

## A Reliable Method

1. Write the brute-force recursion and confirm it is correct.
2. Identify the parameters that change between calls; those become the state.
3. Add a cache keyed by the state for memoization, or build a table and fill it in dependency order for tabulation.
4. Optimize space if each state depends on only a few recent states.

## Common Mistakes

- Choosing a state that does not capture everything the transition needs, producing wrong answers.
- Filling a table in an order where a needed entry is not yet computed.
- Forgetting base cases, which corrupts every value built on them.

Following the progression from recursion to a cache keeps dynamic programming approachable even for unfamiliar problems.$q$, array[$q$Dynamic Programming$q$, $q$Memoization$q$, $q$Tabulation$q$, $q$Recursion$q$, $q$Optimization$q$], true, 5, now() - interval '17 hours')
on conflict (slug) do update set title=excluded.title, category=excluded.category, level=excluded.level, summary=excluded.summary, body=excluded.body, tags=excluded.tags, published=true, sort=excluded.sort, updated_at=now();

-- ===== devops-cloud =====
insert into public.learn_articles (title, slug, category, level, summary, body, tags, published, sort, created_at)
values ($q$CI/CD Pipelines Explained: From Commit to Production$q$, $q$devops-cicd-pipelines-commit-to-production$q$, $q$DevOps & Cloud$q$, $q$Beginner$q$, $q$A practical walkthrough of how code moves from a commit to production through automated build, test, and deploy stages. Covers the core pipeline anatomy and common trade-offs.$q$, $q$Continuous Integration and Continuous Delivery describe the automation that turns a source change into a running, verified artifact. The goal is to shorten the feedback loop so that defects surface in minutes rather than days, and to make releases a routine, low-drama event.

## What CI and CD Actually Mean

Continuous Integration is the practice of merging work into a shared branch frequently and verifying each merge with automated builds and tests. Continuous Delivery extends this: every change that passes the pipeline is kept in a deployable state. Continuous Deployment goes one step further and pushes every passing change to production automatically, with no manual gate.

The distinction matters. Continuous Delivery keeps a human in the loop for the final promotion; Continuous Deployment removes it. Teams usually start with Delivery and graduate to Deployment once test coverage and observability are strong enough to trust.

## Anatomy of a Pipeline

A typical pipeline runs as a sequence of stages, each gating the next:

- **Build**: compile code, resolve dependencies, produce an artifact.
- **Test**: unit, integration, and sometimes end-to-end suites.
- **Package**: create an immutable artifact such as a container image.
- **Scan**: static analysis, dependency and secret scanning.
- **Deploy**: promote to staging, then production.

A key principle is *build once, deploy many*. The same artifact that passed testing should be the one promoted to production. Rebuilding per environment reintroduces risk, because the bytes you tested are not the bytes you ship.

## A Minimal Example

Most hosted CI systems use declarative YAML. The example below builds, tests, and publishes a container image:

```yaml
name: ci
on:
  push:
    branches: [main]
jobs:
  build-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
      - run: npm ci
      - run: npm test
      - run: docker build -t registry.example.com/app:${{ github.sha }} .
      - run: docker push registry.example.com/app:${{ github.sha }}
```

Tagging the image with the commit SHA makes every build traceable to its source and avoids the ambiguity of a mutable tag like latest.

## Deployment Strategies

How an artifact reaches production is as important as building it. Common patterns include:

- **Rolling update**: replace instances gradually. Simple, but mixes old and new versions during rollout.
- **Blue-green**: run two identical environments and switch traffic at once. Fast rollback, but doubles infrastructure during the cutover.
- **Canary**: route a small slice of traffic to the new version, watch metrics, then widen. Lowest blast radius, but needs good monitoring.

The right choice depends on tolerance for risk and the cost of idle capacity. Canary deployments pair naturally with automated rollback triggered by error-rate thresholds.

## Making Pipelines Fast and Reliable

Slow pipelines get bypassed, so speed is a feature. Practical levers:

```bash
# Cache dependencies between runs
npm ci --cache .npm --prefer-offline

# Run independent test suites in parallel
pytest -n auto
```

- Cache dependency downloads and build layers.
- Parallelize independent test suites.
- Fail fast: run cheap, high-signal checks first.
- Keep tests deterministic; a flaky suite erodes trust until people ignore red builds.

## Trade-offs to Weigh

More automation is not automatically better. A pipeline that gates on a two-hour end-to-end suite will frustrate developers and encourage workarounds. Conversely, deploying automatically without health checks invites outages. Reasonable defaults: keep the critical path under ten minutes, require passing tests before merge, and separate fast feedback (unit tests on every push) from slower verification (nightly integration runs).

Secrets management is another trade-off. Injecting credentials as pipeline variables is convenient but widens the attack surface. Short-lived, scoped tokens from a secrets manager reduce exposure at the cost of extra setup.

## Summary

A healthy CI/CD pipeline builds an artifact once, verifies it with fast and trustworthy tests, and promotes it through environments with a deployment strategy matched to risk. Start simple, measure pipeline duration and failure rate, and add gates only where they earn their keep.$q$, array[$q$CI/CD$q$, $q$DevOps$q$, $q$Automation$q$, $q$GitHub Actions$q$, $q$Deployment$q$], true, 1, now() - interval '6 hours')
on conflict (slug) do update set title=excluded.title, category=excluded.category, level=excluded.level, summary=excluded.summary, body=excluded.body, tags=excluded.tags, published=true, sort=excluded.sort, updated_at=now();

insert into public.learn_articles (title, slug, category, level, summary, body, tags, published, sort, created_at)
values ($q$Docker and Containers: A Practical Introduction$q$, $q$devops-docker-containers-practical-intro$q$, $q$DevOps & Cloud$q$, $q$Beginner$q$, $q$An introduction to containers and Docker, covering images, layers, and how to write a lean, reproducible Dockerfile. Explains the difference between containers and virtual machines.$q$, $q$Containers package an application together with its dependencies so it runs the same way on a laptop, a CI runner, and a production server. Docker is the most common toolchain for building and running them, and understanding its core model removes most of the confusion newcomers face.

## Containers Versus Virtual Machines

A virtual machine virtualizes hardware and runs a full guest operating system, including its own kernel. A container virtualizes the operating system: it shares the host kernel and isolates processes using kernel features such as namespaces and cgroups. The practical consequences:

- Containers start in milliseconds; VMs take seconds to minutes.
- A container image is megabytes; a VM image is gigabytes.
- VMs give stronger isolation because the kernel is not shared.

Containers are not a security boundary as strong as a VM. For hostile multi-tenant workloads, teams often run containers inside VMs to get both density and isolation.

## Images and Layers

An image is a read-only template; a container is a running instance of that image. Images are built in layers, and each instruction in a Dockerfile produces one layer. Layers are cached and shared, which is why ordering instructions well matters for build speed.

```dockerfile
FROM node:20-slim
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev
COPY . .
EXPOSE 3000
CMD ["node", "server.js"]
```

Copying the dependency manifest and installing *before* copying source code means the expensive install layer is reused whenever only application code changes. Reversing those two steps would invalidate the cache on every edit.

## Writing a Lean Image

Image size affects pull times, storage, and attack surface. Two techniques help the most.

First, choose a small base. A slim or alpine variant drops hundreds of megabytes compared to a full distribution image, though alpine uses musl libc, which can cause subtle incompatibilities with some native modules.

Second, use multi-stage builds to keep build tools out of the final image:

```dockerfile
FROM golang:1.22 AS build
WORKDIR /src
COPY . .
RUN CGO_ENABLED=0 go build -o /bin/app .

FROM gcr.io/distroless/static
COPY --from=build /bin/app /app
ENTRYPOINT ["/app"]
```

The compiler and source never ship; only the compiled binary lands in a minimal runtime image.

## Running Containers

Common day-to-day commands:

```bash
# Build an image and tag it
docker build -t myapp:1.0 .

# Run it, mapping a port and setting an env var
docker run -p 3000:3000 -e NODE_ENV=production myapp:1.0

# List running containers and view logs
docker ps
docker logs -f <container-id>
```

Data written inside a container disappears when the container is removed. For anything that must persist, mount a volume:

```bash
docker run -v pgdata:/var/lib/postgresql/data postgres:16
```

## Good Practices and Trade-offs

- **Run as a non-root user.** By default processes run as root inside the container, which is unnecessary risk. Add a user and switch to it.
- **One main process per container.** Containers are designed around a single foreground process; cramming several services into one makes logging, scaling, and restarts harder.
- **Treat images as immutable.** Rebuild and redeploy rather than patching a running container, so the running state always matches a known artifact.
- **Pin base image versions.** Using a floating tag means rebuilds can pull a different base without warning, undermining reproducibility.

There is a trade-off between reproducibility and freshness. Pinning exact versions gives repeatable builds but requires deliberate updates to pick up security patches. A reasonable compromise is pinning the major and minor version while allowing patch updates, combined with regular image scanning.

## Summary

Containers share the host kernel to deliver fast, lightweight, reproducible environments. Docker builds them as cached layers from a Dockerfile; ordering instructions well and using multi-stage builds keeps images small. Run a single non-root process per container, persist state in volumes, and treat images as immutable artifacts you rebuild rather than edit.$q$, array[$q$Docker$q$, $q$Containers$q$, $q$DevOps$q$, $q$Dockerfile$q$, $q$Images$q$], true, 2, now() - interval '9 hours')
on conflict (slug) do update set title=excluded.title, category=excluded.category, level=excluded.level, summary=excluded.summary, body=excluded.body, tags=excluded.tags, published=true, sort=excluded.sort, updated_at=now();

insert into public.learn_articles (title, slug, category, level, summary, body, tags, published, sort, created_at)
values ($q$Kubernetes Basics: Pods, Deployments, and Services$q$, $q$devops-kubernetes-pods-deployments-services$q$, $q$DevOps & Cloud$q$, $q$Intermediate$q$, $q$An orientation to the core Kubernetes objects that most workloads rely on: pods, deployments, and services. Explains the declarative model and how traffic reaches a container.$q$, $q$Kubernetes orchestrates containers across a cluster of machines, handling scheduling, scaling, and recovery. Its power comes from a declarative model: you describe the desired state, and controllers continuously reconcile reality toward it. Three objects cover most of what beginners need.

## The Declarative Model

Instead of issuing commands like start this container, you submit a manifest describing what should exist. A controller compares desired state against actual state and acts to close the gap. If a pod dies, the controller notices the mismatch and creates a replacement. This reconciliation loop is the heart of Kubernetes and explains why the system is self-healing.

## Pods

A pod is the smallest deployable unit. It wraps one or more containers that share a network namespace and storage. Containers in the same pod reach each other over localhost, which is why tightly coupled helpers such as a logging sidecar live together in one pod.

Pods are deliberately disposable. They are not meant to be created directly for long-running work, because nothing would recreate them if the node failed. Instead they are managed by higher-level controllers.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: web
spec:
  containers:
    - name: web
      image: nginx:1.27
      ports:
        - containerPort: 80
```

## Deployments

A Deployment manages a set of identical pods through a ReplicaSet, maintaining a desired replica count and handling rollouts. This is the object most applications are deployed with.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
        - name: web
          image: nginx:1.27
          ports:
            - containerPort: 80
```

Updating the image field triggers a rolling update: Kubernetes creates new pods, waits for them to become ready, and removes old ones gradually. If something goes wrong, a rollback restores the previous revision:

```bash
kubectl rollout status deployment/web
kubectl rollout undo deployment/web
```

The selector and the pod template labels must match, or the Deployment will not manage the pods it creates. This is a frequent source of confusion.

## Services

Pods get individual IP addresses, but those addresses change as pods are rescheduled. A Service provides a stable virtual IP and DNS name that load-balances across the pods matching its selector.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web
spec:
  selector:
    app: web
  ports:
    - port: 80
      targetPort: 80
```

The main Service types:

- **ClusterIP** (default): reachable only inside the cluster. Used for service-to-service traffic.
- **NodePort**: exposes a port on every node. Simple but awkward for production.
- **LoadBalancer**: provisions an external load balancer from the cloud provider.

For HTTP routing with host and path rules, an Ingress sits in front of Services and is usually preferred over many LoadBalancers, since it consolidates external entry points.

## Health Checks and Resources

Two settings make workloads reliable. Readiness probes tell Kubernetes when a pod can receive traffic; liveness probes tell it when to restart a stuck pod. Resource requests and limits let the scheduler place pods sensibly and prevent one container from starving others.

```yaml
          readinessProbe:
            httpGet:
              path: /healthz
              port: 80
          resources:
            requests:
              cpu: 100m
              memory: 128Mi
            limits:
              memory: 256Mi
```

Setting a memory limit without a request, or omitting probes, is a common cause of unstable deployments.

## Trade-offs

Kubernetes is powerful but carries real operational cost. For a single small service, a managed container platform may be simpler and cheaper. Kubernetes earns its complexity when running many services that benefit from shared scheduling, autoscaling, and self-healing. Managed control planes from cloud providers remove much of the maintenance burden and are a sensible default over self-hosting the control plane.

## Summary

Pods run containers, Deployments keep the right number of pods running and roll out changes safely, and Services give pods a stable address and load balancing. Combined with probes and resource limits, these objects cover the majority of everyday Kubernetes work.$q$, array[$q$Kubernetes$q$, $q$Containers$q$, $q$Orchestration$q$, $q$DevOps$q$, $q$Cloud Native$q$], true, 3, now() - interval '12 hours')
on conflict (slug) do update set title=excluded.title, category=excluded.category, level=excluded.level, summary=excluded.summary, body=excluded.body, tags=excluded.tags, published=true, sort=excluded.sort, updated_at=now();

insert into public.learn_articles (title, slug, category, level, summary, body, tags, published, sort, created_at)
values ($q$Infrastructure as Code with Terraform$q$, $q$devops-infrastructure-as-code-terraform$q$, $q$DevOps & Cloud$q$, $q$Intermediate$q$, $q$How Terraform manages cloud infrastructure declaratively through providers, state, and plan-and-apply workflows. Covers modules, state safety, and common pitfalls.$q$, $q$Infrastructure as Code means defining servers, networks, and other resources in version-controlled files rather than clicking through a console. Terraform is a widely used tool for this: you declare the desired infrastructure, and it figures out the API calls needed to make reality match.

## The Core Workflow

Terraform centers on three commands. Plan shows what will change, apply executes those changes, and destroy tears resources down. The plan step is the safety mechanism, because it reveals the exact set of creations, updates, and deletions before anything happens.

```bash
terraform init      # download providers and set up the backend
terraform plan      # preview changes
terraform apply     # make reality match the configuration
```

Configuration is written in HCL. A minimal example provisions a storage bucket:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "assets" {
  bucket = "my-app-assets-prod"
}
```

Pinning the provider version with a version constraint prevents an unexpected upgrade from changing behavior on the next init.

## Providers

Providers are plugins that translate Terraform resources into API calls for a specific platform: a cloud, a SaaS product, or even a database. The same declarative workflow applies regardless of provider, which is part of Terraform's appeal across heterogeneous environments.

## State: The Thing to Understand First

Terraform records what it manages in a state file that maps resources in the configuration to real-world objects. On each plan, it compares the configuration, the state, and the live infrastructure. Misunderstanding state causes most Terraform accidents.

Two rules matter above all:

- **Never edit infrastructure out of band.** Manual console changes create drift, where state and reality disagree. The next apply may try to revert or clobber those changes.
- **Store state remotely and lock it.** The default local state file does not work for teams. A remote backend keeps a shared copy and uses locking so two people cannot apply at once.

```hcl
terraform {
  backend "s3" {
    bucket         = "my-tf-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-locks"
  }
}
```

State often contains secrets such as generated passwords in plain text, so the backend must be encrypted and access-controlled.

## Modules

A module is a reusable group of resources with inputs and outputs. Modules keep configurations DRY and let teams standardize patterns such as a network or a database.

```hcl
module "network" {
  source     = "./modules/network"
  cidr_block = "10.0.0.0/16"
  env        = "prod"
}
```

Variables parameterize a module, and outputs expose values for other code to consume:

```hcl
variable "cidr_block" {
  type = string
}

output "vpc_id" {
  value = aws_vpc.main.id
}
```

A useful discipline is one state per environment. Keeping production and staging in separate states limits the blast radius of a mistaken apply.

## Common Pitfalls and Trade-offs

- **Reading the plan carefully.** A change that forces replacement destroys and recreates a resource. For a database, that can mean data loss. The plan flags this; ignoring it is dangerous.
- **Count and for_each indexing.** Removing an item from the middle of a count-based list can cause Terraform to recreate unrelated resources, because they are tracked by position. Using for_each with stable keys avoids this.
- **Drift management.** Terraform only knows about resources it manages. Mixing manual changes with Terraform-managed ones leads to surprises.

There is a broader trade-off between declarative infrastructure and imperative scripts. Terraform excels at provisioning and converging to a desired state, but it is not a configuration management tool for in-place server tuning, nor an application deployment tool. Using it for jobs it was not designed for leads to brittle setups.

## Summary

Terraform turns infrastructure into reviewed, version-controlled code. The plan-and-apply loop makes changes previewable, providers abstract each platform, and modules make configurations reusable. The single most important skill is respecting state: store it remotely, lock it, keep it per environment, and never let manual changes drift away from it.$q$, array[$q$Terraform$q$, $q$Infrastructure As Code$q$, $q$AWS$q$, $q$DevOps$q$, $q$Cloud$q$], true, 4, now() - interval '15 hours')
on conflict (slug) do update set title=excluded.title, category=excluded.category, level=excluded.level, summary=excluded.summary, body=excluded.body, tags=excluded.tags, published=true, sort=excluded.sort, updated_at=now();

insert into public.learn_articles (title, slug, category, level, summary, body, tags, published, sort, created_at)
values ($q$Observability: Logging, Metrics, and Tracing Done Right$q$, $q$devops-observability-logging-metrics-tracing$q$, $q$DevOps & Cloud$q$, $q$Advanced$q$, $q$A guide to the three pillars of observability and how to combine logs, metrics, and traces to understand production systems. Covers cardinality, sampling, and SLO-based alerting.$q$, $q$Observability is the ability to understand a system's internal state from the signals it emits. In distributed systems, failures are rarely reproducible on a laptop, so the data a system produces in production becomes the primary debugging tool. Three complementary signals, often called the three pillars, do most of the work.

## Logs, Metrics, and Traces

Each signal answers a different question:

- **Logs** are discrete, timestamped records of events. They answer *what happened* in detail, including context specific to one request.
- **Metrics** are numeric measurements aggregated over time, such as request rate or error count. They answer *how much* and *how often*, and they are cheap to store and query.
- **Traces** follow a single request as it crosses service boundaries. They answer *where* time was spent and *which* service failed.

The three are strongest together. A metric alerts that error rate rose, a trace localizes the failing service, and logs from that service explain the specific cause.

## Structured Logging

Plain text logs are hard to query at scale. Structured logs emit machine-parseable records, usually one JSON object per line, so a log platform can filter and aggregate them.

```json
{"level":"error","ts":"2026-11-14T10:00:00Z","service":"checkout","trace_id":"abc123","msg":"payment declined","order_id":"7788"}
```

Including a trace identifier in every log line is what links logs back to traces. Avoid logging secrets or personal data, and prefer levels consistently so that error truly means something actionable.

## Metrics and Cardinality

Metrics are typically stored as time series identified by a name and a set of labels. The critical constraint is cardinality: the number of unique label combinations. Each distinct combination is a separate time series, and unbounded cardinality is the most common way to overwhelm a metrics backend.

```yaml
# Good: bounded label values
http_requests_total{method="GET", status="200", route="/api/users"}

# Dangerous: user_id has unbounded values
http_requests_total{user_id="500123"}
```

Putting a user identifier, request identifier, or raw URL with query strings into a label can create millions of series. Keep labels to low-cardinality dimensions such as method, route template, and status class. High-cardinality context belongs in logs or traces, not metrics.

## Distributed Tracing

A trace is a tree of spans, each representing a unit of work with a start time and duration. Context is propagated between services through headers, commonly the W3C traceparent header, so spans from different services join into one trace.

Instrumenting every request fully is expensive, so tracing relies on sampling:

- **Head-based sampling** decides at the start of a request whether to record it. Simple and cheap, but it may miss rare errors.
- **Tail-based sampling** buffers spans and decides after the request finishes, so it can keep all traces that errored or were slow. More accurate, but requires more infrastructure.

A common approach is to always sample errors and slow requests while sampling a small percentage of normal traffic, balancing cost against coverage.

## Alerting on What Matters

Alerting on raw resource metrics such as high CPU produces noise, because high CPU is not inherently a problem. Better alerts are tied to user-facing symptoms expressed as Service Level Objectives.

An SLO sets a target, for example 99.9 percent of requests succeed over 30 days. The allowed failure is the error budget. Alerting on the rate at which the budget is burning catches real degradation while tolerating harmless blips.

```yaml
# Alert when the fast burn rate would exhaust the budget quickly
- alert: HighErrorBurn
  expr: error_rate_5m > (14 * 0.001)
  for: 5m
```

This symptom-based approach reduces pager fatigue, because engineers are woken for problems that affect users rather than for transient internal spikes.

## Trade-offs

Observability is not free. More signals mean more storage, more network overhead, and more cost. Logging every request at debug level in production is rarely justified; sampling and log levels exist to contain this. Similarly, a thousand dashboards nobody reads provide a false sense of safety. The useful measure is time to diagnose an incident, not the volume of data collected.

Open standards reduce lock-in. Instrumenting with a vendor-neutral format lets teams switch backends without re-instrumenting every service, which is valuable given how quickly the tooling landscape changes.

## Summary

Logs, metrics, and traces answer different questions and are strongest in combination, linked by shared identifiers. Keep metric cardinality bounded, sample traces to control cost while preserving errors, use structured logs, and alert on user-facing symptoms through SLOs rather than raw resource usage.$q$, array[$q$Observability$q$, $q$Monitoring$q$, $q$Logging$q$, $q$Metrics$q$, $q$Tracing$q$, $q$SRE$q$], true, 5, now() - interval '18 hours')
on conflict (slug) do update set title=excluded.title, category=excluded.category, level=excluded.level, summary=excluded.summary, body=excluded.body, tags=excluded.tags, published=true, sort=excluded.sort, updated_at=now();

-- ===== databases =====
insert into public.learn_articles (title, slug, category, level, summary, body, tags, published, sort, created_at)
values ($q$SQL vs NoSQL: Choosing the Right Database$q$, $q$databases-sql-vs-nosql-choosing$q$, $q$Databases$q$, $q$Beginner$q$, $q$A practical comparison of relational and non-relational databases, with guidance on when each model fits a workload.$q$, $q$The "SQL vs NoSQL" debate is less about one technology winning and more about matching a data model to a workload. Both families are mature and production-ready; the right choice depends on access patterns, consistency needs, and how the data is shaped.

## What the terms actually mean

"SQL" databases are relational systems such as PostgreSQL, MySQL, and SQL Server. They store data in tables with fixed columns, enforce types and constraints, and use SQL for queries and joins. "NoSQL" is an umbrella term covering several distinct models:

- Document stores (MongoDB, Couchbase) hold JSON-like documents.
- Key-value stores (Redis, DynamoDB) map keys to opaque values.
- Wide-column stores (Cassandra, HBase) group columns into families for huge write volumes.
- Graph databases (Neo4j) model richly connected nodes and edges.

Grouping all of these as "NoSQL" hides big differences. A graph database and a key-value cache solve very different problems.

## Where relational databases shine

Relational engines enforce a schema and support ACID transactions across multiple rows and tables. That matters when correctness is non-negotiable, such as finance, inventory, or any system where partial updates would corrupt state.

Joins are the other major strength. Normalizing data once and combining it at query time avoids duplication and keeps a single source of truth.

```sql
select u.name, count(o.id) as orders
from users u
join orders o on o.user_id = u.id
where o.created_at >= now() - interval '30 days'
group by u.name
order by orders desc;
```

Modern PostgreSQL also stores and indexes JSON through the `jsonb` type, so the line between relational and document storage is blurrier than it used to be.

## Where NoSQL fits

NoSQL systems typically trade strict consistency or ad-hoc joins for scale, flexibility, or latency:

- A document store suits data that is read and written as a self-contained unit, like a product catalog entry with nested attributes.
- A key-value store gives microsecond lookups for sessions, caches, or feature flags.
- A wide-column store handles massive append-heavy workloads such as time-series or event logs.
- A graph database answers questions about relationships, like shortest paths or recommendation traversals, far faster than repeated joins.

Horizontal scaling is a common theme. Many NoSQL systems were designed to shard across commodity nodes from day one.

## Consistency and the CAP trade-off

Distributed systems face the CAP trade-off: during a network partition, a system must choose between consistency and availability. Many NoSQL stores default to eventual consistency, meaning a read may briefly return stale data after a write. That is acceptable for a social feed and unacceptable for a bank balance. Several modern systems let this be tuned per operation, so the label matters less than the configured behavior.

## A decision checklist

Ask these questions before committing:

1. Is the data highly relational, with many entities referencing each other? Relational usually wins.
2. Do writes need multi-row atomic guarantees? Prefer a system with strong transactional support.
3. Is the schema still changing rapidly? A document model can reduce migration friction early on.
4. What is the dominant access pattern? Design storage around how data is read, not only how it is stored.
5. What scale is realistic in 18 months? Avoid architecting for hypothetical scale that never arrives.

## A pragmatic default

For most new applications, a relational database is the safer starting point. It offers strong guarantees, mature tooling, and flexible querying, and PostgreSQL in particular covers many document-style needs through `jsonb`. NoSQL stores earn their place when a specific, well-understood requirement, such as caching, extreme write throughput, or graph traversal, outgrows what the relational engine does well.

The strongest architectures are often polyglot: a relational system as the system of record, a cache for hot reads, and a specialized store for the one workload that truly needs it.$q$, array[$q$SQL$q$, $q$NoSQL$q$, $q$Databases$q$, $q$Architecture$q$, $q$PostgreSQL$q$], true, 1, now() - interval '7 hours')
on conflict (slug) do update set title=excluded.title, category=excluded.category, level=excluded.level, summary=excluded.summary, body=excluded.body, tags=excluded.tags, published=true, sort=excluded.sort, updated_at=now();

insert into public.learn_articles (title, slug, category, level, summary, body, tags, published, sort, created_at)
values ($q$Database Indexing Deep Dive: How Indexes Really Work$q$, $q$databases-indexing-deep-dive$q$, $q$Databases$q$, $q$Advanced$q$, $q$An explanation of B-tree and other index types, how the planner uses them, and the trade-offs of adding indexes.$q$, $q$Indexes are the single most effective tool for speeding up reads, yet they are easy to misuse. Understanding how they are structured and when the planner chooses them turns indexing from guesswork into engineering.

## The B-tree, the default for a reason

Most relational indexes are balanced B-trees. Keys are kept sorted across a shallow tree of pages, so a lookup touches only a handful of pages regardless of table size. Because the tree stays balanced, point lookups and range scans both run in logarithmic time.

B-trees serve equality, range, sorting, and prefix queries. A single index on `(a, b, c)` can satisfy filters on `a`, on `a` and `b`, or all three, but it cannot efficiently filter on `b` alone. This left-to-right rule is the most important thing to internalize about composite indexes.

```sql
create index idx_orders_customer_date
  on orders (customer_id, created_at);

-- Uses the index efficiently:
select * from orders
where customer_id = 42 and created_at >= date '2026-01-01';
```

## Other index types

B-trees are not the only option:

- Hash indexes handle only equality but can be smaller and faster for that case.
- GIN indexes accelerate containment queries on arrays, `jsonb`, and full-text search.
- GiST indexes support geometric and range overlap queries.
- BRIN indexes store per-block summaries, giving tiny indexes for naturally ordered data like append-only timestamps.

Choosing the right type matters as much as choosing the right columns. A GIN index on a `jsonb` column can transform a sequential scan into an instant lookup.

## Covering indexes and index-only scans

If an index contains every column a query needs, the engine can answer from the index alone without visiting the table heap. PostgreSQL supports this with `INCLUDE` columns.

```sql
create index idx_orders_covering
  on orders (customer_id) include (status, total);
```

A query selecting only `status` and `total` filtered by `customer_id` can now run as an index-only scan, avoiding heap fetches entirely.

## How the planner decides

Having an index does not guarantee it is used. The query planner estimates the cost of each access path from table statistics and picks the cheapest. If a filter matches a large fraction of rows, a sequential scan can genuinely be faster than random index lookups, so the planner skips the index on purpose.

Use `EXPLAIN ANALYZE` to see the real plan and compare estimated to actual rows:

```sql
explain analyze
select * from orders where status = 'pending';
```

Large gaps between estimated and actual row counts usually mean stale statistics. Running `ANALYZE` refreshes them.

## The cost of every index

Indexes are not free. Each one:

- Consumes storage, sometimes as much as the table itself.
- Slows down every insert, update, and delete, since the index must be maintained.
- Can be updated on write even when the indexed column did not change, depending on the engine.

The practical guidance is to index for the queries that actually run, measure, and remove indexes that the planner never picks. Monitoring unused indexes is as valuable as adding new ones.

## Common pitfalls

- Wrapping an indexed column in a function, such as `where lower(email) = ...`, prevents index use unless an expression index exists.
- Leading wildcards like `like '%term'` cannot use a standard B-tree.
- Low-cardinality columns, such as a boolean flag, rarely benefit from a plain index; a partial index is often better.

```sql
create index idx_orders_open
  on orders (created_at)
  where status = 'open';
```

A partial index stays small because it covers only the rows that matter, which keeps both lookups and writes cheap.

## Takeaways

Index the columns your real queries filter and sort on, prefer composite indexes ordered by selectivity and usage, and verify every choice with `EXPLAIN ANALYZE` against representative data. Indexing is an ongoing process of measuring and pruning, not a one-time setup.$q$, array[$q$Indexing$q$, $q$B-Tree$q$, $q$Performance$q$, $q$PostgreSQL$q$, $q$Query Planner$q$, $q$SQL$q$], true, 2, now() - interval '10 hours')
on conflict (slug) do update set title=excluded.title, category=excluded.category, level=excluded.level, summary=excluded.summary, body=excluded.body, tags=excluded.tags, published=true, sort=excluded.sort, updated_at=now();

insert into public.learn_articles (title, slug, category, level, summary, body, tags, published, sort, created_at)
values ($q$Transactions, ACID, and Isolation Levels Explained$q$, $q$databases-transactions-acid-isolation$q$, $q$Databases$q$, $q$Intermediate$q$, $q$A grounded look at ACID guarantees, the four SQL isolation levels, and the anomalies each one prevents.$q$, $q$A transaction groups several operations so they succeed or fail as a unit. Behind that simple idea sit the ACID guarantees and a set of isolation levels that control how concurrent transactions see each other's work.

## The ACID properties

ACID is four promises a transactional database makes:

- Atomicity: all statements in a transaction commit together, or none do. A failure rolls everything back.
- Consistency: a transaction moves the database from one valid state to another, respecting constraints.
- Isolation: concurrent transactions do not corrupt each other; the result is as if they ran in some serial order.
- Durability: once committed, data survives a crash, typically guaranteed by a write-ahead log.

A basic transaction looks like this:

```sql
begin;
update accounts set balance = balance - 100 where id = 1;
update accounts set balance = balance + 100 where id = 2;
commit;
```

If the second update fails, `rollback` undoes the first, so money is never lost or created.

## Why isolation is negotiable

Isolation is the one ACID property databases let you relax, because full isolation is expensive under concurrency. The SQL standard defines four levels, each allowing more anomalies in exchange for more throughput.

The three classic anomalies:

- Dirty read: reading another transaction's uncommitted changes.
- Non-repeatable read: a row read twice returns different values because another transaction changed it in between.
- Phantom read: a query run twice returns different rows because another transaction inserted or deleted matching rows.

## The four isolation levels

1. Read Uncommitted allows dirty reads. Rarely useful; some engines do not even implement it as distinct.
2. Read Committed prevents dirty reads. Each statement sees only committed data, but two reads in the same transaction can differ. This is the common default.
3. Repeatable Read prevents dirty and non-repeatable reads. Rows seen once stay stable for the whole transaction.
4. Serializable is the strictest: transactions behave as if executed one at a time, preventing all three anomalies.

```sql
begin isolation level repeatable read;
select balance from accounts where id = 1;
-- The same row returns the same value for the rest of this transaction.
commit;
```

## Implementation differs by engine

The standard names behavior, not mechanism, so engines differ. PostgreSQL uses multi-version concurrency control (MVCC): readers see a snapshot and never block writers. Its Repeatable Read also prevents phantoms through snapshot isolation, going beyond the minimum the standard requires. Its Serializable level adds predicate checks and may abort a transaction with a serialization failure that the application must retry.

Because of this, portable code should treat a serialization error as an expected outcome under high contention:

```sql
-- On serialization_failure, roll back and retry the whole transaction.
begin isolation level serializable;
update inventory set qty = qty - 1 where sku = 'A1' and qty > 0;
commit;
```

## Choosing a level

- Read Committed is a sound default for most applications. It avoids dirty reads with minimal overhead.
- Repeatable Read suits reports or multi-step reads that must see a consistent snapshot.
- Serializable is the safest when correctness under concurrency is critical, at the cost of retries and reduced throughput.

A useful rule: start at the default, then raise the level only for the specific transactions that exhibit a real anomaly.

## Pitfalls to watch

- Long-running transactions hold locks and snapshots, bloating storage and blocking cleanup. Keep them short.
- Optimistic approaches at Serializable require retry logic; omitting it turns rare conflicts into user-facing errors.
- Isolation protects within the database only. Logic split across services may still need application-level coordination such as idempotency keys.

## Summary

ACID defines what a transaction guarantees; isolation levels define how much concurrency those guarantees tolerate. Understanding the anomalies each level prevents lets you pick the weakest setting that is still correct for the workload, which is usually the fastest safe choice.$q$, array[$q$Transactions$q$, $q$ACID$q$, $q$Isolation Levels$q$, $q$Concurrency$q$, $q$MVCC$q$, $q$SQL$q$], true, 3, now() - interval '13 hours')
on conflict (slug) do update set title=excluded.title, category=excluded.category, level=excluded.level, summary=excluded.summary, body=excluded.body, tags=excluded.tags, published=true, sort=excluded.sort, updated_at=now();

insert into public.learn_articles (title, slug, category, level, summary, body, tags, published, sort, created_at)
values ($q$Data Modeling: Normalization vs Denormalization$q$, $q$databases-normalization-vs-denormalization$q$, $q$Databases$q$, $q$Intermediate$q$, $q$How normal forms reduce redundancy, when denormalization pays off, and how to balance integrity against read performance.$q$, $q$Data modeling decides how information is split across tables. Normalization removes redundancy to protect integrity; denormalization reintroduces some redundancy to speed up reads. Good schemas choose deliberately between the two.

## What normalization solves

Normalization organizes columns so that each fact is stored exactly once. The goal is to eliminate update, insert, and delete anomalies, situations where redundant data drifts out of sync.

Consider a flat orders table that repeats the customer's address on every row. If the customer moves, every row must change, and missing one leaves conflicting addresses. Splitting customers into their own table fixes this.

## The normal forms

The normal forms build on each other:

- First normal form (1NF): columns hold atomic values, with no repeating groups or arrays standing in for separate rows.
- Second normal form (2NF): every non-key column depends on the whole primary key, not just part of a composite key.
- Third normal form (3NF): non-key columns depend only on the key, not on other non-key columns.

Most operational schemas aim for 3NF. A normalized design for orders might look like this:

```sql
create table customers (
  id   bigint primary key,
  name text not null,
  city text not null
);

create table orders (
  id          bigint primary key,
  customer_id bigint references customers(id),
  total       numeric(10,2) not null,
  created_at  timestamptz not null default now()
);
```

Here the customer's city lives in one place. Updating it touches a single row, and orders join to it when needed.

## The cost of normalization

Normalized data must be recombined at read time with joins. For deeply related data, a single logical record can span many tables, and assembling it requires several joins that grow more expensive as data grows. Read-heavy systems can feel this cost on hot paths.

This is the core tension: normalization optimizes for correct, cheap writes and storage, while denormalization optimizes for cheap reads.

## When denormalization helps

Denormalization stores redundant copies or precomputed values to avoid work at read time. Common techniques:

- Duplicating a frequently read attribute onto a child table to skip a join.
- Storing a computed aggregate, such as an order count, instead of recalculating it.
- Collapsing related entities into a single document or `jsonb` column when they are always read together.

```sql
alter table customers add column order_count integer not null default 0;

-- Maintained on each new order, often via a trigger or application logic.
update customers set order_count = order_count + 1 where id = 42;
```

The precomputed `order_count` turns an aggregate query into a single column read. The price is that this value can now disagree with reality if the maintenance logic has a bug.

## Managing the trade-off

Denormalization trades write complexity and consistency risk for read speed. To keep it safe:

1. Normalize first. Start from a clean 3NF model so the source of truth is unambiguous.
2. Denormalize only where measurements show a real read bottleneck, not preemptively.
3. Keep the derived data maintainable, ideally through triggers, materialized views, or a single well-tested code path.
4. Document every redundant copy so future changes update all locations.

Materialized views are often the best compromise. They store a denormalized result that can be refreshed on a schedule, keeping the base tables normalized while serving fast reads.

```sql
create materialized view customer_order_stats as
select customer_id, count(*) as orders, sum(total) as revenue
from orders
group by customer_id;

refresh materialized view customer_order_stats;
```

## Context changes the answer

Analytical and transactional systems pull in opposite directions. Transactional (OLTP) workloads favor normalization for integrity under frequent writes. Analytical (OLAP) warehouses often denormalize aggressively into star schemas because reads dominate and data is loaded in batches.

## Summary

Normalization is the sound default: it keeps each fact in one place and makes writes correct. Denormalization is a targeted optimization applied after measurement, accepting controlled redundancy for faster reads. The skill is knowing which pressure a given workload faces and reaching for materialized views or derived columns only when the read cost is proven.$q$, array[$q$Data Modeling$q$, $q$Normalization$q$, $q$Schema Design$q$, $q$Denormalization$q$, $q$SQL$q$], true, 4, now() - interval '16 hours')
on conflict (slug) do update set title=excluded.title, category=excluded.category, level=excluded.level, summary=excluded.summary, body=excluded.body, tags=excluded.tags, published=true, sort=excluded.sort, updated_at=now();

insert into public.learn_articles (title, slug, category, level, summary, body, tags, published, sort, created_at)
values ($q$Query Optimization and Performance Tuning$q$, $q$databases-query-optimization-tuning$q$, $q$Databases$q$, $q$Advanced$q$, $q$A workflow for diagnosing slow queries with EXPLAIN, fixing common bottlenecks, and tuning for sustained performance.$q$, $q$Query tuning is a loop: measure, find the bottleneck, change one thing, measure again. Guessing wastes effort, because the slow part is often not where intuition points. The tools below make the real cost visible.

## Read the plan first

Every tuning session starts with the execution plan. `EXPLAIN` shows the planner's chosen strategy and estimated costs; `EXPLAIN ANALYZE` actually runs the query and reports real timings and row counts.

```sql
explain analyze
select c.name, sum(o.total)
from customers c
join orders o on o.customer_id = c.id
where o.created_at >= now() - interval '7 days'
group by c.name;
```

Read it from the innermost node outward. The two numbers that matter most are the time spent in each node and the gap between estimated and actual rows. A large gap means the planner is working from bad statistics and is likely choosing a poor plan.

## Recognize the expensive operators

A handful of plan nodes explain most slow queries:

- Sequential Scan on a large table where a filter should have used an index.
- Nested Loop joining many rows, where a hash or merge join would be cheaper.
- Sort or Hash spilling to disk because work memory is too small.
- Rows Removed by Filter showing the engine read far more rows than it returned.

Each points to a different fix: a missing index, stale statistics, a memory setting, or a query that fetches too much.

## Common fixes

Most wins come from a short list of changes:

1. Add or adjust an index so the hot filter and join columns are covered.
2. Select only the columns needed. `select *` blocks index-only scans and moves extra data.
3. Filter as early as possible so later operators handle fewer rows.
4. Replace a correlated subquery that runs per row with a join or a single aggregate.
5. Refresh statistics with `ANALYZE` after large data changes.

A correlated subquery is a frequent culprit:

```sql
-- Slow: runs the subquery once per customer row.
select c.name,
       (select count(*) from orders o where o.customer_id = c.id)
from customers c;

-- Faster: one grouped pass.
select c.name, count(o.id)
from customers c
left join orders o on o.customer_id = c.id
group by c.name;
```

## Pagination and large result sets

Offset-based pagination grows slower as the offset increases, because the engine still reads and discards every skipped row. Keyset pagination scales far better by seeking from the last seen key.

```sql
-- Keyset pagination: stays fast at any depth.
select * from orders
where created_at < '2026-11-01 00:00:00'
order by created_at desc
limit 20;
```

## Server-level tuning

Beyond individual queries, a few settings shape overall behavior:

- Work memory controls how much a sort or hash can use before spilling to disk.
- Shared buffers set how much data the engine caches in memory.
- Autovacuum keeps statistics fresh and reclaims dead rows left by updates and deletes.

Neglecting autovacuum is a classic cause of gradual slowdown: dead tuples accumulate, tables bloat, and plans degrade as statistics age.

## Find the worst offenders

Tune where it counts. Extensions and views that track statement statistics reveal which queries consume the most total time, which is usually a frequent medium-cost query rather than one dramatic slow one.

```sql
select query, calls, mean_exec_time, total_exec_time
from pg_stat_statements
order by total_exec_time desc
limit 10;
```

Optimizing the top entries by total time gives the largest system-wide gain.

## A repeatable workflow

Put it together into a loop:

1. Identify the costliest statements from collected statistics.
2. Capture a plan with `EXPLAIN ANALYZE` on realistic data volumes.
3. Form one hypothesis about the bottleneck.
4. Apply a single change: an index, a rewrite, or a setting.
5. Re-measure and keep the change only if it genuinely helped.

## Summary

Performance tuning rewards discipline over cleverness. Let the execution plan point to the real bottleneck, change one variable at a time, and always validate against production-like data. Small, measured adjustments compound into a system that stays fast as it grows.$q$, array[$q$Query Optimization$q$, $q$Performance$q$, $q$EXPLAIN$q$, $q$Indexing$q$, $q$Tuning$q$, $q$SQL$q$], true, 5, now() - interval '19 hours')
on conflict (slug) do update set title=excluded.title, category=excluded.category, level=excluded.level, summary=excluded.summary, body=excluded.body, tags=excluded.tags, published=true, sort=excluded.sort, updated_at=now();

-- ===== ai-ml =====
insert into public.learn_articles (title, slug, category, level, summary, body, tags, published, sort, created_at)
values ($q$How Large Language Models Work: Tokens, Transformers, and Inference$q$, $q$ai-ml-how-llms-work-tokens-transformers-inference$q$, $q$AI / ML$q$, $q$Beginner$q$, $q$A practical tour of what happens inside a large language model, from splitting text into tokens to generating one word at a time. Written for application developers who call these models through an API.$q$, $q$Large language models (LLMs) look like magic from the outside: text goes in, fluent text comes out. Underneath, the behavior is mechanical and predictable enough that developers can reason about cost, latency, and failure modes. This article explains the three pieces that matter most in practice: tokens, the transformer architecture, and the inference loop.

## Tokens: the real unit of work

Models do not read characters or words. They read tokens, which are chunks of text produced by a tokenizer. A token is often a word fragment. Common English words are usually one token, while rare words, code, and non-English text split into several.

As a rough rule of thumb, one token is about four characters of English, so 1,000 tokens is roughly 750 words. This matters because billing, context limits, and latency are all measured in tokens, not words.

- Input tokens are the prompt you send.
- Output tokens are what the model generates.
- Most providers charge more per output token than per input token.

A short prompt that asks for a long answer can cost more than a long prompt that asks for a short one. When estimating cost, count both directions.

## The context window

Every model has a maximum number of tokens it can consider at once, called the context window. Prompt plus generated output must fit inside it. If a conversation grows past the limit, the earliest messages must be dropped or summarized.

Two practical consequences:

1. Long documents may need to be chunked and processed in pieces.
2. Information buried in the middle of a very long context is sometimes used less reliably than information at the start or end, so placement matters.

## Transformers and attention

The transformer is the neural network architecture behind modern LLMs. Its central mechanism is attention, which lets the model weigh how relevant every earlier token is to the token it is currently processing. This is why a pronoun can be linked to a noun mentioned paragraphs earlier.

The model is trained to do one narrow thing: given a sequence of tokens, predict a probability distribution over the next token. Fluency, reasoning, and style are all emergent effects of doing that prediction well across enormous training data. The model has no built-in database of facts and no live access to the world; it has learned statistical patterns, which is why it can state false things confidently.

## The inference loop

Generation is autoregressive, meaning the model produces one token, appends it to the input, and runs again. The loop looks like this:

```python
tokens = tokenize(prompt)
while not done:
    logits = model(tokens)          # scores for every possible next token
    probs = softmax(logits[-1])     # turn scores into probabilities
    next_token = sample(probs)      # pick one
    tokens.append(next_token)
    done = next_token == END or len(tokens) >= max_tokens
```

Because each new token depends on all previous ones, output time grows with output length. This is also why streaming works: the API can send each token as soon as it is produced.

## Sampling knobs developers control

The sample step is where temperature and related settings act.

- Temperature scales randomness. Near 0 the model almost always picks the highest-probability token, giving stable, repeatable output. Higher values spread probability out and produce more varied, creative text.
- Top-p (nucleus sampling) restricts choices to the smallest set of tokens whose combined probability crosses a threshold.
- Max tokens caps output length and protects against runaway cost.

For extraction, classification, and anything requiring consistency, use a low temperature. For brainstorming or varied copy, raise it.

## What this means in practice

A few operational takeaways follow directly from the mechanics:

- Latency has two parts: time to first token (processing the prompt) and time per output token. Long prompts raise the first; long answers raise the second.
- To cut cost, shorten outputs before shortening inputs, since output tokens usually cost more.
- Determinism is limited. Even at temperature 0, hardware and batching can introduce small variations, so do not assume byte-identical responses.
- The model predicts plausible text, not verified truth. Treat factual claims as drafts to check, especially names, numbers, and citations.

Understanding tokens, attention, and the generation loop turns an LLM from a black box into a component with knowable costs and limits, which is exactly what you need to build reliable features on top of it.$q$, array[$q$LLM$q$, $q$Transformers$q$, $q$Tokens$q$, $q$Inference$q$, $q$Fundamentals$q$], true, 1, now() - interval '8 hours')
on conflict (slug) do update set title=excluded.title, category=excluded.category, level=excluded.level, summary=excluded.summary, body=excluded.body, tags=excluded.tags, published=true, sort=excluded.sort, updated_at=now();

insert into public.learn_articles (title, slug, category, level, summary, body, tags, published, sort, created_at)
values ($q$Prompt Engineering Fundamentals for Developers$q$, $q$ai-ml-prompt-engineering-fundamentals$q$, $q$AI / ML$q$, $q$Beginner$q$, $q$Core techniques for writing prompts that produce reliable, parseable output. Covers structure, examples, output formatting, and common failure modes.$q$, $q$Prompt engineering is the practical skill of shaping an LLM's behavior through its input. For application developers the goal is rarely clever phrasing; it is producing output that is correct, consistent, and easy to consume in code. This article covers the techniques that move the needle and the traps that waste time.

## Structure a prompt in clear sections

A reliable prompt usually has three parts: a role or instruction, the context or data, and the requested output format. Separating them helps the model and makes the prompt easier to maintain.

```text
You are a support-ticket classifier.

Ticket:
"My invoice shows two charges for the same order."

Classify the ticket into one of: billing, shipping, technical, other.
Respond with only the category word.
```

Keeping instructions and data visually distinct reduces the chance the model treats part of the data as a command.

## Be specific about the output

Vague requests produce vague, hard-to-parse answers. State the exact shape you want.

- Name the format: JSON, a single word, a markdown table.
- List allowed values for categories so the model cannot invent new ones.
- Say what to do when unsure, such as returning the string unknown rather than guessing.

When you need structured data, ask for JSON and describe the schema in the prompt:

```text
Return a JSON object with keys:
  "sentiment": one of "positive", "neutral", "negative"
  "confidence": a number from 0 to 1
No prose, no code fences.
```

Many providers also offer a structured-output or JSON mode that guarantees valid JSON. Prefer that over parsing free text when it is available, and still validate against a schema in code.

## Show examples (few-shot prompting)

When a task is hard to describe but easy to demonstrate, include a few worked examples. This is called few-shot prompting, as opposed to zero-shot where you only give instructions.

```text
Convert dates to ISO format.
Input: March 3, 2024 -> 2024-03-03
Input: 7/4/21 -> 2021-07-04
Input: next Tuesday -> unknown
Input: Jan 1 2030 ->
```

Two or three good examples usually outperform a longer paragraph of instructions. Make sure examples cover edge cases, including how to handle inputs that should be rejected.

## Give the model room to reason

For multi-step reasoning, math, or logic, asking the model to work through the problem before answering improves accuracy. A simple instruction like think step by step can help, but if you need a clean final value, separate the reasoning from the answer so you can discard the former.

```text
First, work out the calculation in a "reasoning" field.
Then put only the final number in an "answer" field.
```

This keeps the useful output parseable while still benefiting from intermediate steps.

## Common failure modes

- Overstuffing: cramming many unrelated tasks into one prompt lowers quality on each. Split them.
- Conflicting instructions: telling the model to be thorough and to answer in one word forces a trade-off it may resolve unpredictably.
- Leading questions: phrasing that assumes a conclusion biases the answer.
- Prompt injection: when a prompt includes untrusted text (a web page, a user message, a document), that text may contain instructions like ignore previous directions. Treat external content as data, isolate it clearly, and never let it control privileged actions without validation.

## Iterate with a small test set

Treat prompts like code. Keep a handful of representative inputs with expected outputs, and re-run them whenever you change the prompt or the model version. A prompt that works on one example often breaks on the next, and a tiny regression set catches that early.

## Keep it as simple as it can be

Start with the shortest prompt that could work and add detail only when a real failure shows up. Every extra instruction is another thing the model can misread and another token you pay for. Clear structure, explicit output rules, a few targeted examples, and a repeatable test set will handle the large majority of application needs before any advanced technique is required.$q$, array[$q$Prompt Engineering$q$, $q$LLM$q$, $q$Few-Shot$q$, $q$Structured Output$q$, $q$Best Practices$q$], true, 2, now() - interval '11 hours')
on conflict (slug) do update set title=excluded.title, category=excluded.category, level=excluded.level, summary=excluded.summary, body=excluded.body, tags=excluded.tags, published=true, sort=excluded.sort, updated_at=now();

insert into public.learn_articles (title, slug, category, level, summary, body, tags, published, sort, created_at)
values ($q$Retrieval-Augmented Generation (RAG), Explained$q$, $q$ai-ml-retrieval-augmented-generation-explained$q$, $q$AI / ML$q$, $q$Intermediate$q$, $q$How to ground an LLM in your own data by retrieving relevant passages at query time and feeding them into the prompt. Covers embeddings, vector search, chunking, and evaluation.$q$, $q$A base LLM only knows what was in its training data, which is frozen at some cutoff date and does not include your private documents. Retrieval-Augmented Generation (RAG) closes that gap by fetching relevant text at query time and placing it in the prompt, so the model can answer from current, specific sources instead of memory. It is the most common way to build a question-answering feature over a private knowledge base.

## The core pipeline

RAG has two phases. First, an offline indexing phase prepares your data. Second, an online query phase runs for each user question.

Indexing:

1. Split documents into chunks.
2. Convert each chunk into an embedding, a vector of numbers that captures meaning.
3. Store the vectors in a vector database alongside the original text.

Querying:

1. Embed the user's question with the same model.
2. Find the chunks whose vectors are most similar to the question.
3. Insert those chunks into the prompt and ask the model to answer using them.

```text
Answer the question using only the context below.
If the context does not contain the answer, say you do not know.

Context:
{retrieved_chunks}

Question: {user_question}
```

## Embeddings and similarity

An embedding model maps text to a point in a high-dimensional space where similar meanings land near each other. Similarity is usually measured with cosine similarity, which compares the angle between two vectors. Retrieval returns the top-k nearest chunks, where k is a small number like 3 to 8.

The question and the documents must be embedded with the same model, since vectors from different models are not comparable.

## Chunking strategy matters

How you split documents has a large effect on quality.

- Chunks that are too large dilute relevance and waste context tokens.
- Chunks that are too small lose the surrounding context needed to make sense.
- A common starting point is a few hundred tokens per chunk with some overlap between neighbors so a sentence split across a boundary is not lost.

Respect document structure where possible. Splitting on headings, paragraphs, or code blocks usually beats splitting on a fixed character count.

## Improving retrieval quality

Plain vector search is a baseline, not a ceiling. Several techniques routinely help:

- Hybrid search combines vector similarity with keyword search, which catches exact terms, product codes, and names that embeddings sometimes miss.
- Reranking runs a second, more accurate model over the top candidates to reorder them before they enter the prompt.
- Metadata filtering restricts search to the right subset, such as a single customer, product version, or date range.
- Query rewriting expands or clarifies a terse question before retrieval.

## Keep the model honest

RAG reduces hallucination but does not eliminate it. Two habits help:

- Instruct the model to answer only from the provided context and to admit when the answer is absent.
- Return citations by tracking which chunk each answer came from, so users can verify and so you can debug bad answers.

Grounding also fails when retrieval fails. If the right chunk never makes it into the prompt, the model cannot use it, and a confident wrong answer may follow. Many RAG problems are retrieval problems wearing a generation costume.

## Evaluating a RAG system

Measure the two stages separately.

1. Retrieval: for a set of test questions, does the correct chunk appear in the top-k results? Metrics like recall at k quantify this.
2. Generation: given the right context, is the final answer faithful to it and complete? This is often scored by a human or by another model acting as a judge.

Separating the metrics tells you where to invest. If retrieval recall is low, better chunking or hybrid search helps. If retrieval is good but answers are wrong, the prompt or the generation model is the problem.

## When RAG is the right tool

RAG fits when answers must come from a specific, changing, or private corpus, such as internal docs, support articles, or product catalogs. It is cheaper and faster to update than retraining a model, since adding knowledge means adding documents to the index. For teaching a model a new skill or style rather than new facts, other approaches fit better, which the next article compares directly.$q$, array[$q$RAG$q$, $q$Embeddings$q$, $q$Vector Search$q$, $q$Retrieval$q$, $q$LLM$q$, $q$Chunking$q$], true, 3, now() - interval '14 hours')
on conflict (slug) do update set title=excluded.title, category=excluded.category, level=excluded.level, summary=excluded.summary, body=excluded.body, tags=excluded.tags, published=true, sort=excluded.sort, updated_at=now();

insert into public.learn_articles (title, slug, category, level, summary, body, tags, published, sort, created_at)
values ($q$Prompting vs RAG vs Fine-Tuning: How to Choose$q$, $q$ai-ml-prompting-vs-rag-vs-fine-tuning$q$, $q$AI / ML$q$, $q$Intermediate$q$, $q$A decision guide for the three main ways to adapt an LLM to your needs, with the trade-offs in cost, freshness, and effort that decide between them.$q$, $q$When an off-the-shelf model does not do quite what you want, there are three levers to pull: better prompting, retrieval-augmented generation (RAG), and fine-tuning. They are often framed as competitors, but they solve different problems and are frequently combined. Choosing well saves weeks of effort and avoids paying for a heavy solution when a light one would do.

## What each approach actually changes

- Prompting changes the instructions you send. The model weights are untouched. You are steering behavior at request time.
- RAG changes the information in the prompt by retrieving relevant documents at query time. It adds knowledge without changing the model.
- Fine-tuning changes the model weights by training on example input-output pairs. It bakes in behavior, format, or style.

A useful mental model: prompting and RAG act at inference time and are easy to change; fine-tuning acts at training time and is slower to change but can shift the model's default behavior more deeply.

## Match the approach to the problem

Different problems point to different tools.

- Need the model to follow instructions or produce a format: start with prompting, including few-shot examples.
- Need answers grounded in specific, private, or frequently changing facts: use RAG.
- Need a consistent style, tone, or structure that is hard to get with prompting, or need to reduce latency and token cost by removing long instructions: consider fine-tuning.
- Need a narrow, high-volume task where a smaller, cheaper model could work if specialized: fine-tuning a small model can beat prompting a large one on cost.

A blunt but effective heuristic: if the problem is the model does not know something, reach for RAG; if the problem is the model does not behave a certain way, reach for prompting first and fine-tuning if that is not enough.

## Trade-offs at a glance

| Dimension | Prompting | RAG | Fine-tuning |
| --- | --- | --- | --- |
| Setup effort | Low | Medium | High |
| Keeps facts current | Manual | Easy, update the index | Hard, requires retraining |
| Per-request token cost | Higher if long | Higher, context added | Lower, shorter prompts |
| Changes model knowledge | No | Adds at query time | Partially, risk of drift |
| Best for | Behavior, format | Grounded answers | Style, specialization |

## Cost and maintenance realities

Fine-tuning has costs beyond the training run. You need a curated dataset of high-quality examples, a process to evaluate the result, and a plan to retrain when requirements change. A fine-tuned model is also tied to a base version; when the provider releases a better base model, your tuned variant does not automatically benefit.

RAG shifts cost to infrastructure: a vector store, an indexing pipeline, and larger prompts because retrieved context consumes tokens on every call. Its big advantage is freshness, since updating knowledge means updating documents, not retraining.

Prompting is the cheapest to start and change but can become expensive per request if prompts grow long, and it cannot add knowledge the model never had.

## A practical order of operations

Most teams get the best results by escalating only as needed:

1. Start with a clear, well-structured prompt and a few examples.
2. If the model lacks facts, add RAG to ground it.
3. If behavior or format is still inconsistent, or prompts have grown long and costly, fine-tune on examples collected from the earlier stages.

This order is deliberate. The logs from prompting and RAG become the training data for fine-tuning, so earlier stages make later ones cheaper and more accurate.

## They combine

The approaches are not mutually exclusive, and strong systems often use all three. A fine-tuned model can reliably produce a required JSON shape, RAG can feed it current facts, and a concise prompt can set the task. Fine-tuning for format plus RAG for knowledge is a particularly common pairing, because each handles the job the other is weak at.

## The takeaway

Reach for the lightest tool that solves the actual problem. Ask whether the gap is knowledge or behavior, how often the underlying information changes, and how much per-request cost matters at your volume. Those three questions resolve most decisions, and when one tool is not enough, layering them is usually better than forcing a single approach to do everything.$q$, array[$q$Fine-Tuning$q$, $q$RAG$q$, $q$Prompt Engineering$q$, $q$LLM$q$, $q$Architecture$q$, $q$Trade-Offs$q$], true, 4, now() - interval '17 hours')
on conflict (slug) do update set title=excluded.title, category=excluded.category, level=excluded.level, summary=excluded.summary, body=excluded.body, tags=excluded.tags, published=true, sort=excluded.sort, updated_at=now();

insert into public.learn_articles (title, slug, category, level, summary, body, tags, published, sort, created_at)
values ($q$Building AI Agents: Tool Use, Planning, and Guardrails$q$, $q$ai-ml-building-ai-agents-tools-planning-guardrails$q$, $q$AI / ML$q$, $q$Advanced$q$, $q$How to move from a single LLM call to an agent that calls tools, plans multi-step tasks, and operates safely. Covers the tool-use loop, planning patterns, and the guardrails that keep it reliable.$q$, $q$An agent is an LLM that does more than answer in one shot. It decides which actions to take, calls tools to take them, observes the results, and repeats until a goal is met. This unlocks tasks a single prompt cannot do, such as looking up live data, running code, or updating records. It also introduces new failure modes, so the engineering is as much about control as capability.

## The tool-use loop

Tool use (also called function calling) is the foundation. You describe available tools to the model as structured definitions with names, descriptions, and parameter schemas. The model does not run the tools; it emits a request to call one, your code executes it, and you return the result.

```text
loop:
  response = model(messages, tools)
  if response.wants_tool_call:
      result = run_tool(response.tool, response.args)
      messages.append(tool_result(result))
  else:
      return response.text   # final answer
```

Clear tool descriptions matter as much as prompts. The model chooses tools based on their names and descriptions, so vague definitions lead to wrong or missing calls. Keep each tool focused, document parameters, and return concise, structured results the model can reason over.

## Planning patterns

Beyond a single tool call, agents need a way to sequence steps. A few patterns recur:

- ReAct style interleaves reasoning and acting: the model thinks, calls a tool, observes, and thinks again. It is simple and works for many tasks.
- Plan-then-execute asks the model to draft a full plan first, then carry out each step. This helps on complex tasks and makes the plan inspectable before anything runs.
- Decomposition breaks a large goal into subtasks, sometimes handled by separate specialized agents. This adds power but also coordination overhead and cost.

Start with the simplest pattern that works. Multi-agent systems are harder to debug, and a single well-equipped agent handles most tasks.

## Managing context and memory

Each loop iteration adds the tool call and its result to the conversation, so context grows quickly. Long-running agents need a strategy:

- Summarize older steps once they are no longer needed in full.
- Store large results externally and keep only a reference or a short digest in the prompt.
- Return compact tool outputs rather than dumping raw payloads.

Without this, agents hit the context limit, slow down, and lose track of the original goal.

## Guardrails that keep agents reliable

Autonomy is the risk. An agent that can act can act wrongly, and small errors compound over steps. Build controls in from the start.

- Limit the loop. Cap the number of iterations and set a timeout so a confused agent cannot run forever or burn unbounded cost.
- Scope tool permissions. Give each tool the minimum access it needs. A read tool should not be able to write or delete.
- Require confirmation for risky actions. Sending money, deleting data, or emailing customers should pass through a human or a strict check.
- Validate tool inputs. The model may produce malformed or unsafe arguments, so validate against the schema and sanitize before executing.
- Guard against prompt injection. Tool results and fetched content are untrusted. Text from a web page or document may try to hijack the agent, so never let raw external content trigger privileged actions directly.

## Handling errors and dead ends

Tools fail: APIs time out, inputs are rejected, searches return nothing. A robust agent treats errors as observations. Return a clear error message as the tool result and let the model decide whether to retry, try another tool, or stop and report. Build in explicit stopping conditions so the agent gives up gracefully instead of looping on an impossible task.

## Observability

Because agents take many steps, you cannot debug them from the final answer alone. Log every step: the model's reasoning, the tool it chose, the arguments, and the result. Tracing the full trajectory is the only practical way to understand why an agent did something, and it is essential once agents run in production.

## Where to start

A sensible progression is to add one reliable tool, confirm the model calls it correctly, then expand. Keep the loop short, the permissions tight, and the logs complete. Evaluate on realistic tasks and watch not just whether the agent succeeds but how many steps and how many tokens it spends getting there. Capability is easy to demo; the engineering work is making an agent that is reliable, bounded, and safe enough to trust with real actions.$q$, array[$q$Agents$q$, $q$Tool Use$q$, $q$Function Calling$q$, $q$Guardrails$q$, $q$Planning$q$, $q$LLM$q$], true, 5, now() - interval '20 hours')
on conflict (slug) do update set title=excluded.title, category=excluded.category, level=excluded.level, summary=excluded.summary, body=excluded.body, tags=excluded.tags, published=true, sort=excluded.sort, updated_at=now();

