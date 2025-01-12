// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

contract Granny {
    // число внуков
    uint256 public counter;
    // сколько денег у бабаушки
    uint256 public bank;
    // адресс бабаушки
    address public owner;

    // структура для внука
    struct Grandchild {
        // имя внука
        string name;
        // день рожденья в секукнах 
        uint256 birthdate;
        bool alreadyGotMoney;
        bool exist;
    }

    address[] public arrGrandchilds;
    mapping(address => Grandchild) public grandchilds;

    constructor() {
        owner = msg.sender;
        counter = 0;
    }

    // кастомный модификатор
    modifier onlyOwner() {
        require(msg.sender == owner, "You are not a owner!");
        _;
    }

    // Функция добавления внука в контракт
    function addGrandchild(
        address walletAddress,
        string memory name,
        uint256 birthdate
    ) public onlyOwner {
        require(
            birthdate > 0, 
            "Something is wrong, incorrect Birtdate of child"
        );
        // чтобы такого внука еще не существовала в контакте
        require(
            grandchilds[walletAddress].exist == false,
            "Already exist this adress in contract!"
        );
        grandchilds[walletAddress] = (
            Grandchild(name, birthdate, false, true)
        );
        arrGrandchilds.push(walletAddress);
        counter++;
        emit NewGrandChild(walletAddress, name, birthdate);
    }

    // Функция получения подарков от бабушки
    function withdraw() public {
        address payable walletAddress = payable(msg.sender);

        require(
            // проверяем есть ли внук в списках бабушки
            grandchilds[walletAddress].exist == true,
            "This address dos not exists in GrandMaster List!"
        );
        require(
            // check that child Birtdate begins
            block.timestamp > grandchilds[walletAddress].birthdate,
            "Birtdate is not already begins!"
        );
        require(
            // check to child who already got this money
            grandchilds[walletAddress].alreadyGotMoney == false, 
            "you already got you modey!"
        );

        uint256 amount = bank / counter;
        grandchilds[walletAddress].alreadyGotMoney = true;

        (bool success, ) = walletAddress.call{value: amount}("");
        require(success);

        emit GotMoney(walletAddress);
    }

    function readGrandChildsArray(uint cursor, uint length) public view returns (address[] memory) {
        address[] memory array = new address[](length);
        uint counter2 = 0;
        for (uint i = cursor; i < cursor + length; i++) {
            array[counter2] = arrGrandchilds[i];
            counter2++;
        }
        return array;
    }

    function balance0f() public view returns(uint256){
        return address(this).balance;
    }
        
    // receive: только зарегистрированные внуки могут отправлять средства
    receive() external payable {
        require(
            grandchilds[msg.sender].exist || msg.sender == owner,
            "Only registered grandchildren can send Ether or Owner!"
        );
        bank += msg.value;
    }

    // fallback: запрет для всех остальных вызовов
    fallback() external payable {
        revert("Fallback function called: action not allowed");
    }

    // события
    event NewGrandChild(address indexed walletAddress, string name, uint256 birthdate);
    event GotMoney(address indexed walletAddress);
}