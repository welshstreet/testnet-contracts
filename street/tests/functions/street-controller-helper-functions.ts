import { Cl } from "@stacks/transactions";
import { expect } from "vitest";

export function streetMint(
    amountAExpected: number,
    amountBExpected: number,
    blockExpected: number,
    countExpected: number,
    caller: any,
    disp: boolean = false
) {
    if (disp) {
        console.log(`\n=== streetMint ===`);
        console.log(`Caller: ${caller}`);
    }
    
    const test = simnet.callPublicFn(
        "street-controller",
        "mint",
        [],
        caller
    );
    
    if (disp) {
        console.log(`Result type: ${test.result.type}`);
    }
    
    // Check for errors
    if (test.result.type === 'err') {
        const errorCode = Number((test.result as any).value.value);
        
        if (disp) {
            let errorMsg = '';
            switch(errorCode) {
                case 2:
                    errorMsg = 'ERR_YOU_POOR';
                    break;
                case 982:
                    errorMsg = 'ERR_ALREADY_MINTED';
                    break;
                case 983:
                    errorMsg = 'ERR_MINT_CAP_EXCEEDED';
                    break;
                case 984:
                    errorMsg = 'ERR_NO_LIQUIDITY';
                    break;
                default:
                    errorMsg = `Unknown error: ${errorCode}`;
            }
            console.error(`☑️ Mint failed: ${errorMsg}`);
        }
        
        expect(test.result).toEqual(Cl.error(Cl.uint(errorCode)));
        return false;
    }
    
    // Success case - expect (ok { amount-a: uint, amount-b: uint, block: uint, count: uint })
    expect(test.result).toEqual(
        Cl.ok(
            Cl.tuple({
                "amount-a": Cl.uint(amountAExpected),
                "amount-b": Cl.uint(amountBExpected),
                "block": Cl.uint(blockExpected),
                "count": Cl.uint(countExpected),
            })
        )
    );
    
    if (disp && test.result.type === 'ok') {
        console.log(`✅ Street mint successful: Block ${blockExpected}, Count ${countExpected}`);
        console.log(`   Amount A (WELSH donated): ${amountAExpected}, Amount B (STREET minted): ${amountBExpected}`);
        const resultTuple = (test.result as any).value;
        console.log("street-mint result:", resultTuple);
    }
    
    return { amountA: amountAExpected, amountB: amountBExpected, block: blockExpected, count: countExpected };
}

export function getContractOwner(
    disp: boolean = false
) {
    if (disp) {
        console.log(`\n=== getContractOwner ===`);
    }
    
    const test = simnet.callReadOnlyFn(
        "street-controller",
        "get-contract-owner",
        [],
        simnet.deployer
    );
    
    if (disp) {
        console.log(`Result type: ${test.result.type}`);
    }
    
    // Success case - expect (ok principal)
    expect(test.result.type).toEqual('ok');
    
    const owner = (test.result as any).value.value;
    
    if (disp) {
        console.log(`✅ Contract owner: ${owner}`);
    }
    
    return owner;
}

export function setContractOwner(
    newOwner: string,
    caller: any,
    disp: boolean = false
) {
    if (disp) {
        console.log(`\n=== setContractOwner ===`);
        console.log(`New owner: ${newOwner}`);
        console.log(`Caller: ${caller}`);
    }
    
    const test = simnet.callPublicFn(
        "street-controller",
        "set-contract-owner",
        [Cl.principal(newOwner)],
        caller
    );
    
    if (disp) {
        console.log(`Result type: ${test.result.type}`);
    }
    
    // Check for errors
    if (test.result.type === 'err') {
        const errorCode = Number((test.result as any).value.value);
        
        if (disp) {
            let errorMsg = '';
            switch(errorCode) {
                case 981:
                    errorMsg = 'ERR_NOT_CONTRACT_OWNER';
                    break;
                default:
                    errorMsg = `Unknown error: ${errorCode}`;
            }
            console.log(`☑️ Set contract owner failed: ${errorMsg}`);
        }
        
        expect(test.result).toEqual(Cl.error(Cl.uint(errorCode)));
        return false;
    }
    
    // Success case - expect (ok true)
    expect(test.result).toEqual(Cl.ok(Cl.bool(true)));
    
    if (disp && test.result.type === 'ok') {
        console.log(`✅ Contract owner set to: ${newOwner}`);
    }
    
    return true;
}

export function getMintCount(
    disp: boolean = false
) {
    if (disp) {
        console.log(`\n=== getStreetMinted ===`);
    }
    
    const test = simnet.callReadOnlyFn(
        "street-controller",
        "get-mint-count",
        [],
        simnet.deployer
    );
    
    if (disp) {
        console.log(`Result type: ${test.result.type}`);
    }
    
    // Success case - expect (ok uint)
    expect(test.result.type).toEqual('ok');
    
    const minted = Number((test.result as any).value.value);
    
    if (disp) {
        console.log(`✅ Street minted: ${minted}`);
    }
    
    return minted;
}
