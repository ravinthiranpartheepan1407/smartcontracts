//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

contract ArkhammSocial {
  string public name;
  uint public imageId = 0;
  mapping (uint => Image) public images;

  struct Image {
    uint id;
    string hashes;
    string description;
    uint donateAmount;
    address payable author;
  }

  event ImageCreated(
    uint id,
    string hashes,
    string description,
    uint donateAmount,
    address payable author
  );

  event ImageDonated(
    uint id,
    string hashes,
    string description,
    uint donateAmount,
    address payable author
  );

  constructor() public{
    name = "Arkhammsocial";
  }

  function uploadImage(string memory _imgHash, string memory _description) public {
    require(bytes(_imgHash).length > 0);
    require(bytes(_description).length > 0);
    require(msg.sender!=address(0));
    imageId ++;
    images[imageId] = Image(imageId, _imgHash, _description, 0, msg.sender);
    emit ImageCreated(imageId, _imgHash, _description, 0, msg.sender);
  }

  function donateImageOwner(uint _id) public payable {
    require(_id > 0 && _id <= imageId);
    Image memory _image = images[_id];
    address payable _author = _image.author;
    address(_author).transfer(msg.value);
    _image.donateAmount = _image.donateAmount + msg.value;
    images[_id] = _image;
    emit ImageDonated(_id, _image.hashes, _image.description, _image.donateAmount, _author);
  }
}
