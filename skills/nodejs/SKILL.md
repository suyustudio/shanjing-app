---
name: Node.js
description: Build scalable server-side applications with Node.js, Express/NestJS, and modern JavaScript/TypeScript practices.
metadata: {"clawdbot":{"emoji":"🟢","os":["linux","darwin","win32"]}}
---

# Node.js Skill

## Project Setup

- Use `npm init` or `npm create` for new projects
- Prefer TypeScript for large projects—catches bugs at compile time
- Use `tsconfig.json` with strict mode—enables more type checking
- Keep `package.json` scripts organized (build, test, start, dev)
- Lock dependencies with `package-lock.json` or `yarn.lock`

## Async Patterns

- Prefer async/await over callbacks—readable, easier to debug
- Use Promise.all for parallel operations—don't await sequentially
- Handle rejections everywhere—unhandled rejections crash the process
- Use try/catch with async—errors don't bubble automatically
- Avoid callback hell—promisify legacy APIs

## Error Handling

- Create custom error classes—distinguish error types
- Always handle errors in async code—silent failures are worst
- Use process.on('unhandledRejection') as safety net—log and crash
- Validate inputs early—fail fast, clear error messages
- Don't leak internal errors to clients—sanitize error responses

## TypeScript Best Practices

- Use strict mode—catches more bugs at compile time
- Define interfaces for all data structures—self-documenting
- Avoid any—defeats the purpose of TypeScript
- Use unknown for truly unknown values—force type checking
- Generate types from schemas—Prisma, OpenAPI, etc.

## Performance

- Use clustering for CPU-intensive work—utilize all cores
- Stream large data—don't buffer everything in memory
- Use connection pooling—database, HTTP agents
- Profile with clinic.js—find actual bottlenecks
- Avoid blocking the event loop—use worker threads for heavy tasks

## Security

- Validate all inputs—never trust client data
- Use helmet for security headers—XSS, CSRF protection
- Rate limiting on all endpoints—prevent abuse
- Keep dependencies updated—automated with Dependabot
- Secrets in environment variables—never commit to git

## Testing

- Unit tests for business logic—fast, isolated
- Integration tests for API endpoints—real database
- Use supertest for HTTP assertions—clean API
- Mock external services—tests should be deterministic
- Coverage > 80%—focus on critical paths

## Database

- Use ORM (Prisma/TypeORM) for type safety
- Connection pooling for performance
- Transactions for data integrity
- Migrations for schema changes
- Index frequently queried fields

## Common Commands

```bash
npm init -y             # Initialize new project
npm install <pkg>       # Install dependency
npm install -D <pkg>    # Install dev dependency
npm run build           # Build TypeScript
npm run test            # Run tests
npm run dev             # Start dev server
npm start               # Start production server
node --inspect          # Debug mode
```