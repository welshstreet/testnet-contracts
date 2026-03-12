import { describe, it } from "vitest";
import { Cl } from "@stacks/transactions";
import { disp } from './vitestconfig';

const accounts = simnet.getAccounts();
const deployer = accounts.get("deployer")!;

describe("=== AS-CONTRACT? DEBUG TESTS ===", () => {
    it("=== TEST CREDIT TOKEN TRANSFER ===", () => {
        if (disp) {
            console.log("\n=== Testing credit-token transfer function ===");
        }
        
        // Try to call transfer directly on credit-token
        // This should fail because only .street-market and .credit-controller are authorized
        const result = simnet.callPublicFn(
            "credit-token",
            "transfer",
            [
                Cl.uint(100),
                Cl.principal(deployer),
                Cl.principal(deployer),
                Cl.none()
            ],
            deployer
        );
        
        if (disp) {
            console.log("Result type:", result.result.type);
            console.log("Result:", result.result);
        }
        
        if (result.result.type === "err") {
            const errorCode = Number((result.result as any).value.value);
            if (disp) {
                console.log("Error code:", errorCode);
            }
        } else if (result.result.type === "ok") {
            if (disp) {
                console.log("Success value:", (result.result as any).value);
            }
        }
    });

    it("=== TEST GET-BALANCE READ-ONLY ===", () => {
        if (disp) {
            console.log("\n=== Testing get-balance read-only ===");
        }
        
        // Call get-balance on credit-token
        const result = simnet.callReadOnlyFn(
            "credit-token",
            "get-balance",
            [Cl.principal(deployer)],
            deployer
        );
        
        if (disp) {
            console.log("Result type:", result.result.type);
            console.log("Result:", result.result);
        }
        
        if (result.result.type === "ok") {
            const balance = Number((result.result as any).value.value);
            if (disp) {
                console.log("Balance:", balance);
            }
        }
    });

    it("=== TEST GET-TOTAL-SUPPLY ===", () => {
        if (disp) {
            console.log("\n=== Testing get-total-supply ===");
        }
        
        const result = simnet.callReadOnlyFn(
            "credit-token",
            "get-total-supply",
            [],
            deployer
        );
        
        if (disp) {
            console.log("Result type:", result.result.type);
            console.log("Result:", result.result);
        }
        
        if (result.result.type === "ok") {
            const supply = Number((result.result as any).value.value);
            if (disp) {
                console.log("Total supply:", supply);
                console.log("Expected: 0 (no liquidity added yet)");
            }
        }
    });

    it("=== TEST WELSH-FAUCET GET-BALANCE ===", () => {
        if (disp) {
            console.log("\n=== Testing welsh-faucet get-balance (uses as-contract?) ===");
        }
        
        const result = simnet.callReadOnlyFn(
            "welsh-faucet",
            "get-balance",
            [],
            deployer
        );
        
        if (disp) {
            console.log("Result type:", result.result.type);
            console.log("Result:", result.result);
            console.log("Raw result:", JSON.stringify(result.result, null, 2));
        }
        
        if (result.result.type === "ok") {
            if (disp) {
                console.log("Outer OK - checking inner value...");
            }
            const innerValue = (result.result as any).value;
            if (disp) {
                console.log("Inner value type:", innerValue.type);
            }
            
            if (innerValue.type === "ok") {
                if (disp) {
                    console.log("Inner OK - double wrapped!");
                }
                const actualBalance = Number(innerValue.value.value);
                if (disp) {
                    console.log("Actual balance:", actualBalance);
                }
            } else {
                const actualBalance = Number(innerValue.value);
                if (disp) {
                    console.log("Actual balance:", actualBalance);
                }
            }
        } else if (result.result.type === "err") {
            const errorCode = Number((result.result as any).value.value);
            if (disp) {
                console.log("Error code:", errorCode);
            }
        }
    });
});
