import { describe, it } from "vitest";
import { disp, INITIAL_MINT_STREET, FEE, TAX, STREET_URI } from "./vitestconfig"
import { getBalance, getTotalSupply, getContractOwner, getDecimals, getName, getSymbol, getTokenUri } from "./functions/shared-read-only-helper-functions";
import { getBlocks, getMarketInfo } from "./functions/street-market-helper-functions";

const accounts = simnet.getAccounts();
const deployer = accounts.get("deployer")!;

describe("=== SHARED READ ONLY FUNCTION TESTS ===", () => {
    it("=== GET BALANCE PRINCIPAL ===", () => {
        getBalance(INITIAL_MINT_STREET, 'street-token', deployer, deployer, disp);
    });

    it('=== GET BLOCKS PASS ===', () => {
        getBlocks(deployer, disp);
    });

    it("=== GETMARKETINFO ===", () => {
        const availAExpected = 0;
        const availBExpected = 0;
        const feeExpected = FEE;
        const lockedAExpected = 0;
        const lockedBExpected = 0;
        const reserveAExpected = 0;
        const reserveBExpected = 0;
        const taxExpected = TAX;
        getMarketInfo(
            availAExpected,
            availBExpected,
            feeExpected,
            lockedAExpected,
            lockedBExpected,
            reserveAExpected,
            reserveBExpected,
            taxExpected,
            deployer,
            disp
        );
    })

    it("=== GET TOTAL SUPPLY ===", () => {
        getTotalSupply(INITIAL_MINT_STREET, 'street-token', deployer, disp);
    });

    it("=== GET CONTRACT OWNER ===", () => {
        const contractOwnerExpected = deployer;
        getContractOwner(contractOwnerExpected, 'street-token', deployer, disp);
    });

    it("=== GET DECIMALS ===", () => {
        const decimalsExpected = 6;
        getDecimals(decimalsExpected, 'street-token', deployer, disp);
    });

    it("=== GET NAME ===", () => {
        const nameExpected = "Welsh Street Token";
        getName(nameExpected, 'street-token', deployer, disp);
    });

    it("=== GET SYMBOL ===", () => {
        const symbolExpected = "STREET";
        getSymbol(symbolExpected, 'street-token', deployer, disp);
    });

    it("=== GET NAME ===", () => {
        const nameExpected = "Welsh Street Credit";
        getName(nameExpected, 'credit-token', deployer, disp);
    });

    it("=== GET SYMBOL ===", () => {
        const symbolExpected = "CREDIT";
        getSymbol(symbolExpected, 'credit-token', deployer, disp);
    });

    it("=== GET TOKEN URI ===", () => {
        const tokenUriExpected = STREET_URI;
        getTokenUri(tokenUriExpected, 'street-token', deployer, disp);
    });
});