// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "ds-test/test.sol";
import "../contracts/Bridger.sol";
import './mocks/MockERC20.sol';
import './utils/Cheats.sol';

contract BridgerTest is DSTest {
    CheatCodes internal constant vm = CheatCodes(HEVM_ADDRESS);
    Bridger public bridger;
    MockERC20 public mockERC20;

    uint16 ethId = 1;
    uint16 polyId = 9;
    uint16 avaxId = 6;
    uint16 ftmId = 12;

    address polyRouter = 0x45A01E4e04F14f7A4a6702c74187c5F6222033cd;
    address avaxRouter = 0x45A01E4e04F14f7A4a6702c74187c5F6222033cd;
    address router = polyRouter;

    address[] toVault;

    address _address = 0xdAD97F7713Ae9437fa9249920eC8507e5FbB23d3;
    address usdc = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;
    address usdt = 0xc2132D05D31c914a87C6611C10748AEb04B58e8F;

    function setUp() public {
        mockERC20 = new MockERC20();
        bridger = new Bridger(router, usdc, usdt);
    }

    function testConstructor() public {
        address _stargateRouter = bridger.stargateRouter();    
        assertTrue(_stargateRouter == router);
        assertEq(bridger.pids(usdc), 1);
        assertEq(bridger.pids(usdt), 2);
    }

    function testChangeRouter() public {
        bridger._changeStargateRouter(_address);
        address _stargateRouter = bridger.stargateRouter();
        assertTrue(_stargateRouter == _address);

        vm.expectRevert(bytes("Must be validly address"));
        bridger._changeStargateRouter(address(0));

    }

    function testOwner() public {
        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        vm.prank(address(0));
        
        bridger._changeStargateRouter(_address);
        address _stargateRouter = bridger.stargateRouter();
        assertTrue(_stargateRouter == router);
    }

    function testAddAsset() public {
        bridger.addAsset(_address, 3);
        bridger.addAsset(usdc, 10);

        assertEq(bridger.pids(_address), 3);
        assertEq(bridger.pids(usdc), 10);
    }

    function testGasFee() public {
        
        uint256 gasFee = bridger.getSwapFee(avaxId, toVault);

        assertTrue(gasFee > 0);
    }

    function testSwap() public {
        uint256 tokenAmount = 100000000;
        address tokenHolder = 0x21Cb017B40abE17B6DFb9Ba64A3Ab0f24A7e60EA;

        vm.prank(tokenHolder);
        IERC20(usdc).transfer(address(bridger), tokenAmount);

        assertEq(IERC20(usdc).balanceOf(address(bridger)), tokenAmount);

        uint256 gasFee = bridger.getSwapFee(avaxId, toVault);
        
        bool success = bridger._swap{ value: (gasFee + gasFee) }(
            avaxId, 
            usdc, 
            tokenAmount, 
            toVault
        );

        assertTrue(success);
        assertEq(IERC20(usdc).balanceOf(address(bridger)), 0);
        //tests if the address was refunded the extra gas
        assertEq(address(bridger).balance, gasFee);
    }
 
}
