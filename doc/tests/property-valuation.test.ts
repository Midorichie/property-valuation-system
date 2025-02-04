import { describe, it, expect } from 'vitest';
import { Tx, Chain, Account, types } from '@clarigen/test';

// Initialize test environment
const chain = new Chain();
const deployer = new Account('deployer');
const wallet_1 = new Account('wallet_1');

// Sample contract call test
describe('Sample Contract Tests', () => {
  it('should execute a contract function', () => {
    const block = chain.mineBlock([
      Tx.contractCall('contract-name', 'function-name', [types.uint(100)], wallet_1.address),
    ]);
    
    expect(block.receipts.length).toBe(1);
    expect(block.height).toBeGreaterThan(0);
    expect(block.receipts[0].result).toBe('(ok true)');
  });
});
