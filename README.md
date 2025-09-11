# Goodnight

A Ruby on Rails API for user management, following relationships, and sleep tracking, with JWT authentication and strategies for handling large datasets.

## Features
- User authentication (JWT)
- Follow/unfollow users
- Track sleep records (clock in/out)
- View own and followings' sleep records
- Pagination and search for users
- Error handling and JSON responses

## Setup Instructions

### 1. Prerequisites
- Ruby (3.x recommended)
- Rails (7.x recommended)
- PostgreSQL
- Bundler

### 2. Clone the Repository
```sh
git clone https://github.com/Christyan39/goodnight
cd goodnight
```

### 3. Install Dependencies
```sh
bundle install
```

### 4. Database Setup
```sh
rails db:create
rails db:migrate
rails db:seed # if you have seed data
```

### 5. Credentials Setup (for JWT secret)
Edit your credentials to set the secret key base:
```sh
EDITOR="vim" bin/rails credentials:edit
```
Ensure you have: config/credentials.yml.enc

### 6. Run the Server
```sh
rails server
```

### 7. Run Tests
```sh
rails test
```

## API Endpoints (Examples)
- `POST /login` — Authenticate and get JWT
- `GET /users` — List users (with search & pagination)
- `GET /users/:id` — Show user
- `GET /self/profile` — Show current user (JWT required)
- `POST /self/clock_in` — Clock in sleep
- `POST /self/clock_out` — Clock out sleep
- `POST /self/follow` — Follow a user
- `POST /self/unfollow` — Unfollow a user
- `GET /self/sleep_records` — List own sleep records
- `GET /self/followings/sleep_records` — List followings' sleep records (last 7 days)

## Strategy for Handling Big Data

1. **Database Indexing**
	- Add indexes to foreign keys (e.g., `user_id`, `following_user_id`) for fast lookups.

2. **Pagination**
	- All list endpoints support pagination (`limit`, `page` params) to avoid loading too much data at once.

3. **Batch Operations**
	- Use bulk inserts/updates where possible (e.g., `insert_all` for large data loads).

4. **Query Optimization**
	- Use `select`, `joins`, and `includes` to avoid N+1 queries and reduce data transfer.

5. **Scale The Database**
	- Set up your database to run on multiple servers (nodes) that work together as a single system. This can include replication (copying data across nodes for high availability), sharding (splitting data across nodes for scalability), and load balancing (distributing requests for better performance). For PostgreSQL, consider tools like Patroni, Citus, or built-in streaming replication. Clustering ensures your application can handle large data volumes, high traffic, and provides fault tolerance as your system grows.


