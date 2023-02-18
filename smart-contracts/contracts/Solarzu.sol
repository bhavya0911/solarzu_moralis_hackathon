// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./IWETHGateway.sol";

contract Solarzu is Ownable, ReentrancyGuard {

    struct OpenseaTrades {
        uint256 value;
        bytes tradeData;
    }

    address public AaveWethGateway = 0x3bd3a20Ac9Ff1dda1D99C0dFCE6D65C4960B3627;
    address public AavePool = 0x4bd5643ac6f66a5237E18bfA7d47cF22f1c9F210;
    address public openseaAddress = 0x7Be8076f4EA4A4AD08075C2508e481d6C946D12b;

    IWETHGateway internal TrustedWethGateway = IWETHGateway(AaveWethGateway);

    function purchaseFromOpensea(
        OpenseaTrades[] memory openseaTrades,
        uint256 totalValue
    ) external payable nonReentrant {
        uint256 requireAmount = (totalValue * 120)/100;
        require(msg.value >= requireAmount, "Required Amount Not Sent");

        TrustedWethGateway.depositETH(address(AavePool), address(this), 0);
        TrustedWethGateway.withdrawETH(address(AavePool), totalValue, address(this));

        for(uint256 i; i < openseaTrades.length; i++) {
            openseaAddress.call{value: openseaTrades[i].value}(openseaTrades[i].tradeData);
        }
        assembly {
            if gt(selfbalance(), 0) {
                let callStatus := call(
                    gas(),
                    caller(),
                    selfbalance(),
                    0,
                    0,
                    0,
                    0
                 )
            }
        }
    }
}
