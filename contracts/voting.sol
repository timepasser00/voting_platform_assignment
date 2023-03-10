// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract Voting {
    event PollCreated(uint256 id);
    event VotingRightsChanged(address user, uint256 indexed topicId, string indexed status , uint256 expirationTime);

    struct Topic {
        string name;
        address creator;
        uint256 expirationTime;
        mapping(address => bool) requested;
        mapping(address => bool) allowedVoters;
        mapping(address => bool) voted;
        // mapping(uint256 => uint256) voteCounts;
        string[] options;
        // address[] votingRequests;
        uint256[] voteCounts;
    }

    // mapping (string => Topic) public topics;
    Topic[] public topics;

    modifier onlyCreator(uint256 _id) {
        require(topics[_id].creator == msg.sender, "not the creator");
        _;
    }

    // user creates any topic with name, options and expiry date
    function createTopic(
        string memory name,
        uint256 expirationPeriod,
        string[] memory _options
    ) public {
        // name can't be a empty string
        bytes memory nameEmptyStringTest = bytes(name);
        require(nameEmptyStringTest.length > 0, "empty string passed");
        require(expirationPeriod > 0, "invalid duration");
        Topic storage newTopic = topics.push();
        newTopic.name = name;
        newTopic.creator = msg.sender;
        newTopic.expirationTime = block.timestamp + expirationPeriod;
        newTopic.options = _options;
        newTopic.voteCounts = new uint[](_options.length);
        emit PollCreated(topics.length);
    }

    // user adds option
    function addOption(uint256 _id, string memory option)
        public
        onlyCreator(_id)
    {
        require(
            topics[_id].expirationTime > block.timestamp,
            "Voting has already expired"
        );
        topics[_id].options.push(option);
        topics[_id].voteCounts.push(0);
    }

    // returns all the options for any poll topic
    function getOptions(uint256 _topicIndex)
        public
        view
        returns (string[] memory)
    {
        return topics[_topicIndex].options;
    }

    // user requests to vote for any topic using topicId
    function requestVotingRights(uint256 _id) public {
        require(
            topics[_id].expirationTime > block.timestamp,
            "Voting has already expired"
        );
        require(
            topics[_id].allowedVoters[msg.sender] == false,
            "You already have voting rights"
        );
        // topics[_id].votingRequests.push(msg.sender);
        topics[_id].requested[msg.sender] = true;
        emit VotingRightsChanged(msg.sender, _id , "PENDING", topics[_id].expirationTime);
    }

    // creator of topic gets the all the voting requests
    // function getVotingRequests(uint256 _topicIndex)
    //     public
    //     view
    //     onlyCreator(_topicIndex)
    //     returns (address[] memory)
    // {
    //     return topics[_topicIndex].votingRequests;
    // }

    // creator of the poll topic approves or rejects the voting requests
    function processVotingRequest(uint256 _id, uint256 _status, address requestingAddress)
        public
        onlyCreator(_id)
    {
        // require(topics[_id].votingRequests.length > 0, "no pending request");
        // address _address = topics[_id].votingRequests[0];
        require(
            topics[_id].allowedVoters[requestingAddress] == false,
            "Voting rights already approved"
        );
        // status = 1 : approved
        // else rejected
        if (_status == 1) {
            topics[_id].allowedVoters[requestingAddress] = true;
            emit VotingRightsChanged( requestingAddress , _id , "APPROVED" , topics[_id].expirationTime);
        }else{
            emit VotingRightsChanged( requestingAddress , _id , "REJECTED" , topics[_id].expirationTime);
        }
    }

    // approved user who has voted can vote before the expiry time
    function vote(uint256 _id, uint256 optionIndex) public {
        require(
            topics[_id].expirationTime > block.timestamp,
            "Voting has already expired"
        );
        require(
            topics[_id].allowedVoters[msg.sender],
            "You don't have voting rights"
        );
        require(!topics[_id].voted[msg.sender], "You have already voted");
        topics[_id].voteCounts[optionIndex]++;
        topics[_id].voted[msg.sender] = true;
    }

    // at the end of voting , user can see the voting count
    function getVoteCounts(uint256 _id)
        public
        view
        returns (uint256[] memory)
    {
        // require(
        //     block.timestamp > topics[_id].expirationTime,
        //     "voting time not over yet"
        // );
        return topics[_id].voteCounts;
    }

    // check if a user allowed to vote for a given topic
    function isAllowedVoter(uint256 _topicIndex, address _user)
        public
        view
        returns (bool)
    {
        return topics[_topicIndex].allowedVoters[_user];
    }

    // chekc if a user has already voted
    function hasAlreadyVoted(uint256 _topicIndex, address _user)
        public
        view
        returns (bool)
    {
        return topics[_topicIndex].voted[_user];
    }

    // check if user has request for voting
    function requestedVoting(uint256 _topicIndex, address _user)
        public
        view
        returns (bool)
    {
        return topics[_topicIndex].requested[_user];
    }
}
