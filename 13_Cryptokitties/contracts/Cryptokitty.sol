// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.6.0;
pragma experimental ABIEncoderV2;

import './ERC721Token.sol';

contract Cryptokitty is ERC721Token {

    uint public nextId;
    address public admin;

    struct Kitty { uint id; uint generation; uint geneA; uint geneB;
    }

    mapping(uint => Kitty) public kitties;
       
    constructor(string memory _tokenURIBase) ERC721Token( _tokenURIBase) public {
        admin = msg.sender;
    }

    function _random(uint max) internal view returns(uint) {
        return uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % max;
    }

    function mint() external {
        require(msg.sender == admin, 'only admin');
        kitties[nextId] = Kitty(nextId, 1, _random(10), _random(10));
        _mint(msg.sender, nextId);
        nextId++;
    } 

    function breed(uint kitty1Id, uint kitty2Id) external {
        require(kitty1Id < nextId && kitty2Id < nextId, 'The 2 kitties must exist');
        Kitty storage kitty1 = kitties[kitty1Id];
        Kitty storage kitty2 = kitties[kitty2Id];
        require(ownerOf(kitty1Id) == msg.sender && ownerOf(kitty2Id) == msg.sender, 'msg.sender must own the 2 kitties');
        uint baseGen = kitty1.generation > kitty2.generation ? kitty1.generation : kitty2.generation;
        uint geneA = _random(4) > 1 ? kitty1.geneA : kitty2.geneA;
        uint geneB = _random(4) > 1 ? kitty1.geneB : kitty2.geneB;
        kitties[nextId] = Kitty(nextId, baseGen + 1, geneA ,geneB) ;
        _mint(msg.sender, nextId);
        nextId++;
    }

    function getAllKitties() external view returns(Kitty[] memory) {

      Kitty[] memory _kitties = new Kitty[](nextId);

      for(uint i = 0; i < _kitties.length; i++) {
        _kitties[i] = kitties[i];
      }

      return _kitties;
    }

    function getAllKittiesOf(address owner) external view returns(Kitty[] memory) {

      uint length;

      for(uint i = 0; i < nextId; i++) {
        if(ownerOf(i) == owner) {
          length++;
        }
      }

      Kitty[] memory _kitties = new Kitty[](length);

      for(uint i = 0; i < _kitties.length; i++) {
        if(ownerOf(i) == owner) {
          _kitties[i] = kitties[i];
        }
      }

      return _kitties;
    }

}
