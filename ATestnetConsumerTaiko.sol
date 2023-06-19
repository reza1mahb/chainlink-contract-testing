// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

contract ATestnetConsumerTaiko is ChainlinkClient {

    using Chainlink for Chainlink.Request;

    address constant oracleTaiko = 0x7053af6475b2a11Bff65E697E349d66e6580d371;
    string constant jobIdTaiko = "00000000000000000000000000000000";
    uint256 public constant ORACLE_PAYMENT = (1 * LINK_DIVISIBILITY) / 10; // 0.1 * 10**18 (0.1 LINK)
    uint256 public currentPrice;

    event RequestEthereumPriceFulfilled(
        bytes32 indexed requestId,
        uint256 indexed price
    );

    constructor() {
        setChainlinkToken(0x326C977E6efc84E512bB9C30f76E30c160eD06FB);
    }

    function requestEthereumPrice() public {
        Chainlink.Request memory req = buildChainlinkRequest(
            stringToBytes32(jobIdTaiko),
            address(this),
            this.fulfillEthereumPrice.selector
        );
        req.add(
            "get",
            "https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=USD"
        );
        req.add("path", "USD");
        req.addInt("times", 100);
        sendChainlinkRequestTo(oracleTaiko, req, ORACLE_PAYMENT);
    }

    function fulfillEthereumPrice(
        bytes32 _requestId,
        uint256 _price
    ) public recordChainlinkFulfillment(_requestId) {
        emit RequestEthereumPriceFulfilled(_requestId, _price);
        currentPrice = _price;
    }

    function stringToBytes32(
        string memory source
    ) private pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            // solhint-disable-line no-inline-assembly
            result := mload(add(source, 32))
        }
    }
}