// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;
pragma abicoder v2;

import {ISwapRouter} from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import {IERC20} from "./Helper.sol";

/**
 * @title Swap Contract
 * @author 3illBaby
 * @notice This implements the uniswap v3
* todo: Hardcode the contract address
// //  * todo: implement an ERC20 interface to approve token swap
 *
 */

contract SingleSwap {
    ISwapRouter public immutable swapRouter =
        ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
    uint24 public constant feeTier = 3000;

    /**
     * ! this function perforns the swap from token A to B
     * ? This is an ExactInput. meaning that the output will be exactly dependent on the input and the output can't be specified manually
     *
     */
    function executeSwapExactInput(
        address _tokenAddress,
        address _tokenOut,
        uint256 _amountIn
    ) external returns (uint256 _amountOut) {
        //? This is an ERC20 interface
        IERC20 helper = IERC20(_tokenAddress);

        //? This approves the uniswap router to make the swap with the specified amount of tokens
        helper.approve(address(swapRouter), _amountIn);

        uint256 minOut = 0;
        uint160 priceLimit = 0;

        //? required parameters for the swap
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: _tokenAddress,
                tokenOut: _tokenOut,
                fee: feeTier,
                recipient: address(this),
                deadline: block.timestamp,
                amountIn: _amountIn,
                amountOutMinimum: minOut,
                sqrtPriceLimitX96: priceLimit
            });

        _amountOut = swapRouter.exactInputSingle(params);
    }

    /**
     * ! This function perfroms a swap from B to A
     * ? The required amount you want to get is specified manually and the amount required to swap is specified automaticaaly
     * @param _tokenAddressIn This is the token you want to swap
     * @param _tokenAddressOut This is the token you want to receive after the swap
     * @param _amountOut This is the amount you want to receive after the swap
     * @param _amountInMax This is the maximum amount you are willing to pay for the swap
     */
    function executeSwapExactOutput(
        address _tokenAddressIn,
        address _tokenAddressOut,
        uint256 _amountOut,
        uint256 _amountInMax
    ) external returns (uint256 _amountIn) {
        IERC20 helper = IERC20(_tokenAddressIn);
        helper.approve(address(swapRouter), _amountInMax);

        //? This are the parameters requireed for the swap to take place
        ISwapRouter.ExactOutputSingleParams memory params = ISwapRouter
            .ExactOutputSingleParams({
                tokenIn: _tokenAddressIn,
                tokenOut: _tokenAddressOut,
                fee: feeTier,
                recipient: address(this),
                deadline: block.timestamp,
                amountOut: _amountOut,
                amountInMaximum: _amountInMax,
                sqrtPriceLimitX96: 0
            });

        _amountIn = swapRouter.exactOutputSingle(params);

        /**
         * ! This is a check to ensure that if there any tokens remaining after the swap, it gets sent back to the sender
         */
        if (_amountIn < _amountInMax) {
            helper.approve(address(swapRouter), 0);
            helper.transfer(address(this), _amountInMax - _amountIn);
        }
    }
}
