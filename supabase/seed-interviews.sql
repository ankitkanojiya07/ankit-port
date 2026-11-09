-- Seed: interview experiences (generated). Run in the Supabase SQL editor after schema.sql.
-- Re-runnable: existing slugs are updated.

insert into public.interview_experiences (company, role, slug, outcome, rounds, summary, body, tags, published, created_at)
values ($q$Accenture$q$, $q$Associate Software Engineer (ASE)$q$, $q$accenture-associate-software-engineer-interview-experience$q$, 'Unknown', $q$Cognitive & Technical Assessment, Coding, Communication Assessment, Technical + HR$q$, $q$Accenture ASE hiring has 4 rounds: a 90-question cognitive and technical test, a coding round, a communication assessment and a technical + HR interview focused on your major project.$q$, $q$Accenture's Associate Software Engineer (ASE) hiring process has **4 rounds**:

- Cognitive & Technical Assessment
- Coding Round
- Communication Assessment
- Technical + HR Interview

## Round 1: Cognitive & Technical Assessment

**90 questions in 90 minutes**, covering:

- English ability
- Critical reasoning
- Pseudocode
- MS Office
- Networking
- Cloud fundamentals

This is an **elimination round**, so managing time across all sections matters as much as getting individual questions right.

## Round 2: Coding

- 1 easy coding problem
- 1 medium coding problem

Solutions are evaluated with both **visible and hidden test cases**, so handling edge cases is important.

## Round 3: Communication Assessment

- Reading
- Listening
- Speaking

Everything is done under time pressure. This round doesn't eliminate candidates outright, but your performance counts toward the overall evaluation.

## Round 4: Technical + HR

The final interview has a technical panelist and an HR panelist. The biggest focus is your **major project**. Expect detailed questions on:

- Why a particular technology was chosen
- How the project was designed
- Your individual contributions
- Technical challenges
- Trade-offs and decisions
- Cross-questions based on your previous answers

## What stood out

The process tests a broad range of skills, not just coding: time management, communication, core technical knowledge and, above all, the ability to explain your own project in depth.

## Key takeaway

Don't prepare only for the coding round. For Accenture ASE, be ready for **aptitude, pseudocode, networking, cloud, communication** and deep project-based questioning.$q$, array[$q$Accenture$q$, $q$ASE$q$, $q$Freshers$q$, $q$Aptitude$q$, $q$Pseudocode$q$, $q$Networking$q$, $q$Cloud$q$, $q$Project Questions$q$], true, now() - interval '0 hours')
on conflict (slug) do update set company=excluded.company, role=excluded.role, outcome=excluded.outcome, rounds=excluded.rounds, summary=excluded.summary, body=excluded.body, tags=excluded.tags, published=true, updated_at=now();

insert into public.interview_experiences (company, role, slug, outcome, rounds, summary, body, tags, published, created_at)
values ($q$Myntra$q$, $q$SDE-2 (3+ Years Experience)$q$, $q$myntra-sde-2-interview-experience$q$, 'Unknown', $q$Online Assessment (HackerEarth), Technical Problem Solving, Behavioral$q$, $q$Myntra SDE-2 (referral) interview experience: a 3-problem DSA assessment on HackerEarth, a structured brute-force-to-optimized problem-solving round and a behavioral round.$q$, $q$Myntra's SDE-2 hiring process, through a referral, started with an online assessment on HackerEarth.

## Online Assessment: DSA

**3 DSA problems** at different difficulty levels:

- Easy
- Medium
- Hard

## Technical Round: Problem Solving

The technical round was refreshingly structured. The interviewer explained the problem with clear examples and specifically asked for the **brute-force approach** before moving toward optimization.

The discussion progressed step by step:

**Brute force → Analysis → Optimization**

Rather than expecting a perfect solution immediately, the interviewer worked through the optimization process together.

## Behavioral Round

Real-world situations were covered:

- What are your strengths and weaknesses?
- How do you handle conflict with a manager or teammate?
- How do you approach mentoring junior developers?
- What does work-life balance mean to you in day-to-day work?
- Do you have competing offers?
- Why Myntra specifically?

## What stood out

The process was well paced, and the interviewers cared more about **how you think** than whether your first answer was flawless. Communicating your reasoning, spotting limitations and improving your approach was clearly important.

## Key takeaway

Don't jump straight to the optimal solution. Start with the simplest approach, explain its complexity, identify the bottleneck, then improve it. Showing the **process of problem-solving** can matter as much as the final solution.$q$, array[$q$Myntra$q$, $q$SDE-2$q$, $q$DSA$q$, $q$Problem Solving$q$, $q$Behavioral Interview$q$, $q$Referral$q$], true, now() - interval '1 hours')
on conflict (slug) do update set company=excluded.company, role=excluded.role, outcome=excluded.outcome, rounds=excluded.rounds, summary=excluded.summary, body=excluded.body, tags=excluded.tags, published=true, updated_at=now();

insert into public.interview_experiences (company, role, slug, outcome, rounds, summary, body, tags, published, created_at)
values ($q$Ola$q$, $q$SDE-1$q$, $q$ola-sde-1-interview-experience$q$, 'Unknown', $q$HackerRank (DSA + SQL + REST API), Technical Coding, Director Round$q$, $q$Ola SDE-1 (Bangalore) interview experience: a HackerRank test mixing DSA, SQL and a REST API script, a codepad technical round and a director round with live binary tree spiral traversal.$q$, $q$Ola's Bangalore hiring process started with a HackerRank assessment that tested more than just DSA.

## Round 1: DSA + SQL + REST API

- A data structures problem
- A SQL query
- A short script to consume a RESTful API

The combination made the round more practical than a typical algorithm-only assessment.

## Round 2: Technical Coding

A technical coding interview on a shared codepad. The interviewer was approachable and encouraged a **two-way discussion**, including questions about the role and team.

## Round 3: Director Round

The final round was with the **Director of Engineering**. Topics:

- Current technologies and trends
- Ongoing projects
- Technical experience and problem-solving

**Live coding question: spiral traversal of a binary tree.** The solution had to be written and explained on a whiteboard, with attention to **edge cases** and the reasoning behind the approach.

## What stood out

The people side of the process stood out more than the difficulty of the questions. Every interviewer left room for genuine conversation instead of a rigid Q&A script.

## Key takeaway

Don't limit preparation to DSA. Be comfortable with **SQL, REST APIs**, practical coding and explaining your thought process clearly.$q$, array[$q$Ola$q$, $q$SDE-1$q$, $q$DSA$q$, $q$SQL$q$, $q$REST API$q$, $q$Binary Tree$q$, $q$Bangalore$q$], true, now() - interval '2 hours')
on conflict (slug) do update set company=excluded.company, role=excluded.role, outcome=excluded.outcome, rounds=excluded.rounds, summary=excluded.summary, body=excluded.body, tags=excluded.tags, published=true, updated_at=now();

insert into public.interview_experiences (company, role, slug, outcome, rounds, summary, body, tags, published, created_at)
values ($q$PhonePe$q$, $q$SDE (2-5 Years Experience)$q$, $q$phonepe-sde-interview-experience$q$, 'Unknown', $q$Machine Coding, Low-Level Design, System Design$q$, $q$PhonePe mid-level SDE interview experience: a multi-level cache machine coding round and a flight aggregator system design round with deep scaling follow-ups.$q$, $q$PhonePe's interview process for a mid-level SDE role focused on **machine coding, LLD and system design** rather than pure DSA.

## Machine Coding: Multi-Level Cache

Build a **multi-level cache** with three levels:

- L1 Cache
- L2 Cache
- L3 Cache

Each level had a configurable capacity, with standard **get / set** operations. The interesting part was how requests should **cascade across cache levels** when data isn't available at the current level.

## System Design: Flight Aggregator

Design a **flight aggregator** that can:

- Fetch flight data from multiple airlines
- Support flight search
- Handle bookings
- Split functionality into appropriate microservices
- Support connecting flights when no direct route is available

## The toughest part: scaling search

One of the deepest discussions was scaling the search API under heavy traffic. MySQL with **read replicas** was a reasonable starting point, but the interviewer pushed further:

**What happens when a new replica needs to be spun up while traffic keeps increasing?**

That follow-up exposed the importance of **horizontal scaling, failure handling and traffic spikes**.

## What stood out

This was a systems-heavy process. The focus wasn't on solving DSA problems quickly but on designing systems that handle real-world scale, failures and growing traffic.

## Key takeaway

For mid-level SDE roles, the first architecture that comes to mind isn't enough. Be ready for the interviewer to keep asking **"Why?"**, **"What happens if traffic grows?"** and **"What happens if this component fails?"**$q$, array[$q$PhonePe$q$, $q$SDE$q$, $q$Machine Coding$q$, $q$LLD$q$, $q$System Design$q$, $q$Microservices$q$, $q$Caching$q$], true, now() - interval '3 hours')
on conflict (slug) do update set company=excluded.company, role=excluded.role, outcome=excluded.outcome, rounds=excluded.rounds, summary=excluded.summary, body=excluded.body, tags=excluded.tags, published=true, updated_at=now();

insert into public.interview_experiences (company, role, slug, outcome, rounds, summary, body, tags, published, created_at)
values ($q$Paytm$q$, $q$SDE-1 (On-Campus)$q$, $q$paytm-sde-1-on-campus-interview-experience$q$, 'Unknown', $q$Coding (CoCubes), Technical Interview 1, Technical Interview 2, HR$q$, $q$Paytm SDE-1 on-campus interview experience: a 3-problem CoCubes coding round, two technical interviews on trees, BSTs and linked lists, and an HR round.$q$, $q$Paytm's campus hiring process had **4 rounds**:

- Coding Round (CoCubes)
- Technical Interview 1
- Technical Interview 2
- HR Round

## Coding Round: CoCubes

**3 problems in 70 minutes**, focused on core data structures:

- Trees
- Binary Search Trees
- Linked Lists

These were solid DSA fundamentals rather than unusually tricky questions.

## Technical Rounds

Both technical interviews continued from the same topics as the coding round and went deeper into:

- Implementation details
- Edge cases
- Tree and BST operations
- Linked-list manipulation
- Choosing the right approach and explaining its complexity

The interviewers didn't introduce completely new topics. They focused on how well the fundamentals were understood.

## What stood out

A fairly traditional process, heavily focused on **DSA fundamentals**. Candidates with strong practice in trees, BSTs and linked lists would find it much more comfortable.

## Key takeaway

For Paytm SDE-1, don't overlook the basics. Strong command of **trees, BSTs, linked lists**, implementation details and edge cases goes a long way.$q$, array[$q$Paytm$q$, $q$SDE-1$q$, $q$On-Campus$q$, $q$DSA$q$, $q$Trees$q$, $q$Binary Search Tree$q$, $q$Linked List$q$], true, now() - interval '4 hours')
on conflict (slug) do update set company=excluded.company, role=excluded.role, outcome=excluded.outcome, rounds=excluded.rounds, summary=excluded.summary, body=excluded.body, tags=excluded.tags, published=true, updated_at=now();

insert into public.interview_experiences (company, role, slug, outcome, rounds, summary, body, tags, published, created_at)
values ($q$Zomato$q$, $q$SDE-1$q$, $q$zomato-sde-1-interview-experience$q$, 'Unknown', $q$Online Round (Coding + DBMS MCQs), Project + DSA, HR + Technical$q$, $q$Zomato SDE-1 interview experience: an online coding round with DBMS MCQs, a project deep dive plus DSA complexity questions, and an HR + technical round.$q$, $q$Zomato's SDE-1 process started with an **online round** covering coding and DBMS-based MCQs, followed by **2 main technical rounds**.

## Round 1: Project + DSA

The round began with a deep dive into an internship project built with **Django**. It then moved into core data structures:

- Arrays
- Trees
- Hash Maps
- Graphs
- Queues
- Stacks

The interviewer cared about understanding the underlying complexity, not only knowing the structures. For a linked list, for example, explain the time and space complexity of:

- Insert
- Delete
- Search

The expectation was to explain **why** the complexity is what it is, not just state Big-O values.

## Round 2: HR + Technical

A short HR-style discussion first:

- Favorite subjects
- Previous internship experience
- Projects and responsibilities

It then moved into technical follow-ups based on the candidate's background and earlier answers.

## What stood out

The feedback throughout was direct but supportive. One interviewer highlighted **staying calm and confident** as an area to improve. Constructive, human feedback like that isn't something every process offers.

## Key takeaway

Don't just memorize DSA complexities. Be ready to explain the reasoning behind them, and know your project well enough to handle deeper follow-up questions.$q$, array[$q$Zomato$q$, $q$SDE-1$q$, $q$DSA$q$, $q$Data Structures$q$, $q$DBMS$q$, $q$Django$q$, $q$Project Questions$q$], true, now() - interval '5 hours')
on conflict (slug) do update set company=excluded.company, role=excluded.role, outcome=excluded.outcome, rounds=excluded.rounds, summary=excluded.summary, body=excluded.body, tags=excluded.tags, published=true, updated_at=now();

