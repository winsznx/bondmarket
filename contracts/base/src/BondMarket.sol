// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BondMarket {
    struct Bond {
        address issuer;
        uint256 principal;
        uint256 interestRate;
        uint256 maturityDate;
        address holder;
        bool repaid;
    }

    mapping(uint256 => Bond) public bonds;
    uint256 public bondCount;

    event BondIssued(uint256 indexed bondId, address indexed issuer, uint256 principal, uint256 interestRate);
    event BondTransferred(uint256 indexed bondId, address indexed from, address indexed to);
    event BondRepaid(uint256 indexed bondId);

    error NotBondHolder();
    error NotMatured();

    function issueBond(uint256 principal, uint256 interestRate, uint256 duration) external returns (uint256) {
        uint256 bondId = bondCount++;
        bonds[bondId] = Bond({
            issuer: msg.sender,
            principal: principal,
            interestRate: interestRate,
            maturityDate: block.timestamp + duration,
            holder: msg.sender,
            repaid: false
        });
        emit BondIssued(bondId, msg.sender, principal, interestRate);
        return bondId;
    }

    function transferBond(uint256 bondId, address to) external {
        if (bonds[bondId].holder != msg.sender) revert NotBondHolder();
        bonds[bondId].holder = to;
        emit BondTransferred(bondId, msg.sender, to);
    }

    function repayBond(uint256 bondId) external {
        Bond storage bond = bonds[bondId];
        if (block.timestamp < bond.maturityDate) revert NotMatured();
        bond.repaid = true;
        emit BondRepaid(bondId);
    }
}
