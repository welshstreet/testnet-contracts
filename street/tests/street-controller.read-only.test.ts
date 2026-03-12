import { describe, it } from "vitest";
import { disp } from "./vitestconfig";
import { getContractOwner, getMintCount } from "./functions/street-controller-helper-functions";

describe("=== STREET CONTROLLER READ ONLY TESTS ===", () => {
    it("=== GET CONTRACT OWNER ===", () => {
        getContractOwner(disp);
    });

    it("=== GET STREET MINTED ===", () => {
        getMintCount(disp);
    });
});
