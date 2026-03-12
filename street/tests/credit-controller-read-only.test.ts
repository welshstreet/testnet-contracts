import { describe, it } from "vitest";
import { disp } from "./vitestconfig";
import { getContractOwner } from "./functions/credit-controller-helper-functions";

describe("=== CREDIT CONTROLLER READ ONLY TESTS ===", () => {
    it("=== GET CONTRACT OWNER ===", () => {
        // Deployer is set as contract owner at deployment
        getContractOwner(disp);
    });
});
