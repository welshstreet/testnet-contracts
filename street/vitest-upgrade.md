Vitest / Clarinet upgrade log

- [x] Step 1: Align config with latest Clarinet docs (environment=node, setupFiles, globals).
- [x] Step 2: Remove vitest-environment-clarinet from package.json (no custom environment plugin).
- [x] Step 3: Fix simnet initialization by calling initSimnet() and setting globalThis.simnet.
- [x] Step 4: Fix Clarity 4 type errors by replacing try! with unwrap-panic for read-only functions.

Attempts log:
1. ❌ Tried importing `{ simnet }` from SDK → SDK doesn't export simnet, only Simnet type
2. ❌ Added global.options.clarinet only → SDK's vitest.setup.ts couldn't find simnet
3. ✅ Called `initSimnet()` in clarinet-options-setup.ts → assigns to globalThis.simnet + sets up coverage/costs arrays
4. ❌ Used try! for read-only functions → Clarity 4 rejects try! on (response T never) types
5. ✅ Replaced try! with unwrap-panic for read-only functions → contracts compile and tests pass

**Status: COMPLETE** ✅

Vitest environment + Clarity 4 working:
- Simnet properly initialized globally
- All contracts pass Clarity 4 type checking
- Test suite operational (setup-initial-liquidity.test.ts passing)

Key changes made:
- [clarinet.config.ts](clarinet.config.ts): Initialize global.simnet via initSimnet() + includes TypeScript global declaration
- All contracts: Replaced `try!` with `unwrap-panic` for get-balance and get-total-supply calls
- [contracts/credit-controller.clar](contracts/credit-controller.clar): Wrapped match statement to avoid consecutive unchecked responses
- [vitest.config.ts](vitest.config.ts): References clarinet.config.ts as first setup file

Clarity 4 pattern: Use `unwrap-panic` for read-only functions that return `(response T never)` since try! requires determinate error types.
