// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "./CommitReveal.sol";

contract Lottery is CommitReveal{
    struct Player {
        uint choice;
        address addr;
        uint joinTime;
        bool withdrawn;
    }

    address owner;
    uint public poolSize;
    uint public T1;
    uint public T2;
    uint public T3;
    mapping (uint => address) public takenNumber;
    mapping (uint => bool) public numberIsTaken;

    uint public numPlayer = 0;
    uint public reward = 0;
    uint public numRevealed = 0;
    uint public poolStartTime = 0;
    bool public isPayed = false;

    uint winnerNumber;

    constructor(uint number, string memory salt, uint _T1, uint _T2, uint _T3) payable {
        require(msg.value == 3 ether);
        require(number >= 0 && number <= 4);

        poolSize = 5;
        T1 = _T1;
        T2 = _T2;
        T3 = _T3;        

        reward += msg.value;
        owner = msg.sender;
        poolStartTime = block.timestamp;

        bytes32 saltHash = keccak256(abi.encodePacked(salt));
        commit(getSaltedHash(bytes32(number), saltHash));

        numPlayer++;
    }


    mapping (uint => Player) public player;
    mapping (address => uint) public playerId;
    mapping (uint => address) public confirmedPool;


    function joinPool(uint choice) public payable {
        require(numPlayer <= poolSize);
        require(numberIsTaken[choice] == false);
        require(msg.value == 1 ether);
        // require(poolStartTime + T1 <= block.timestamp);

        numberIsTaken[choice] = true;
        takenNumber[choice] = msg.sender;
        player[numPlayer].addr = msg.sender;
        player[numPlayer].withdrawn = false;
        playerId[msg.sender] = numPlayer;

        numPlayer++;
    }

    function revealMyChoice(uint choice, string memory salt) public {
        //reveal the answer with the given salt
        require(msg.sender == owner);
        // require(block.timestamp - poolStartTime > T1);

        bytes32 saltHash = keccak256(abi.encodePacked(salt));
        revealAnswer(bytes32(choice), saltHash);
        
        winnerNumber = choice;
        address payable winner = payable(takenNumber[winnerNumber]);
        winner.transfer(reward);
        isPayed = true;
    }

    function withdraw() public {
        // require(block.timestamp - poolStartTime > T3);
        require(player[playerId[msg.sender]].withdrawn == false);
        require(isPayed = false);

        player[playerId[msg.sender]].withdrawn == true;
        address payable account = payable(player[playerId[msg.sender]].addr);
        account.transfer(1 ether);
    }
}