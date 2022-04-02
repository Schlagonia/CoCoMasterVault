// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "ds-test/test.sol";
import "../StakeContract.sol";
import './mocks/MockERC20.sol';
import './utils/Cheats.sol';

contract ContractTest is DSTest {
    CheatCodes internal constant cheatCodes = CheatCodes(HEVM_ADDRESS);
    StakeContract public stakeContract;
    MockERC20 public mockERC20;

    function setUp() public {
        stakeContract = new StakeContract();
        mockERC20 = new MockERC20();
    }

    function testExample(uint8 _amount) public {
        //uint256 _amount = 10e18;
        mockERC20.approve(address(stakeContract), _amount);
        cheatCodes.roll(55);
        bool passed = stakeContract.stake(_amount, address(mockERC20));
        assertTrue(passed);
    }
}
