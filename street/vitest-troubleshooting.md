# Vitest Troubleshooting

## Issue: TypeScript Module Resolution Errors

**Date:** March 11, 2026

### Errors Encountered

```
Cannot find module 'vitest/config' or its corresponding type declarations.
Cannot find module '@stacks/clarinet-sdk/vitest' or its corresponding type declarations.
```

### Root Cause

The `node_modules` directory was missing - npm dependencies had not been installed.

### Investigation Steps

1. **Checked package.json**: Confirmed dependencies were properly declared:
   - `vitest: ^4.0.7`
   - `@stacks/clarinet-sdk: ^3.9.0`
   - `vitest-environment-clarinet: ^3.0.0`

2. **Verified directory structure**: Found no `node_modules/` directory

3. **Checked for lock files**: No `package-lock.json`, `yarn.lock`, or `pnpm-lock.yaml` found

### Resolution

**Solution:** Run `npm install`

```bash
npm install
```

**Result:**
- ✅ 120 packages installed successfully
- ✅ TypeScript module resolution errors resolved
- ✅ 0 vulnerabilities found

### Project Dependencies

#### Test Framework
- **vitest** (^4.0.7): Fast unit test framework
- **vitest-environment-clarinet** (^3.0.0): Custom Vitest environment for Clarinet

#### Stacks/Clarinet SDK
- **@stacks/clarinet-sdk** (^3.9.0): Clarinet SDK for testing
- **@stacks/transactions** (^7.2.0): Stacks transaction library

#### Development Tools
- **@types/node** (^24.4.0): TypeScript type definitions for Node.js
- **chokidar-cli** (^3.0.0): File watcher for test automation

### Test Scripts Available

```json
{
  "test": "vitest run",
  "test:report": "vitest run -- --coverage --costs",
  "test:watch": "chokidar \"tests/**/*.ts\" \"contracts/**/*.clar\" -c \"npm run test:report\""
}
```

- `npm run test` - Run all tests once
- `npm run test:report` - Run tests with coverage and cost reports
- `npm run test:watch` - Watch mode: re-run tests on file changes

### Configuration Notes

The `vitest.config.ts` uses:
- **Environment**: `clarinet` - Custom environment provided by `vitest-environment-clarinet`
- **Pool**: `forks` - Run tests in separate processes
- **Isolation**: `false` - Clarinet handles test isolation via simnet resets
- **Max Workers**: `1` - Single worker for deterministic test execution

### Future Prevention

Before running tests or encountering TypeScript errors:
1. Always run `npm install` after cloning or when package.json changes
2. Check for `node_modules/` directory existence
3. Verify `package-lock.json` is committed to track exact dependency versions

### Related Files

- [vitest.config.ts](vitest.config.ts) - Vitest configuration
- [package.json](package.json) - Project dependencies and scripts
- [tsconfig.json](tsconfig.json) - TypeScript configuration
- [Clarinet.toml](Clarinet.toml) - Clarinet contract definitions

### Status

✅ **RESOLVED** - Dependencies installed, TypeScript errors cleared
