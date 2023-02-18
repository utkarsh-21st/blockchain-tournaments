// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-4/proxy/utils/Initializable.sol";

contract Tournaments is Initializable {
    struct Game {
        uint256 size;
        string name;
    }

    struct PlayerGameState {
        string gameName;
        uint256 gameSize;
        uint256 currNPlayer;
        uint256 playerNum;
        bool gameOn;
        address winner;
    }

    /// game data
    Game[] public games;
    /// current number of players waiting in lobby/playing for each game
    uint256[] public currNPlayer;
    /// whether the game being played
    mapping(uint256 => bool) public gameOn;
    /// For each game, array of addresses of all players
    address[][] public currPlayers;
    /// a unique number assigned to each player, not necessarily in any particular order
    mapping(uint256 => mapping(address => uint256)) public playerNum;
    /// winner for each game; gets updated after each game completed
    address[] public winner;

    function __Tournaments_init(Game[] memory _games) public initializer {
        __Tournaments_init_unchained(_games);
    }

    function __Tournaments_init_unchained(Game[] memory _games)
        internal
        initializer
    {
        for (uint256 i = 0; i < _games.length; ) {
            Game memory game = _games[i];
            games.push(game);
            currNPlayer.push(0);
            address[] memory _player = new address[](game.size);
            currPlayers.push(_player);
            winner.push(address(0));
            unchecked {
                i++;
            }
        }
    }

    /// @notice number of active games
    function nActive() external view returns (uint256) {
        return games.length;
    }

    /// @dev returns variables used in frontend
    function getPlayerGameState()
        external
        view
        returns (PlayerGameState[] memory)
    {
        PlayerGameState[] memory _playerGameState = new PlayerGameState[](
            games.length
        );
        for (uint256 i = 0; i < _playerGameState.length; ) {
            _playerGameState[i] = PlayerGameState({
                gameName: games[i].name,
                gameSize: games[i].size,
                currNPlayer: currNPlayer[i],
                playerNum: playerNum[i][msg.sender],
                gameOn: gameOn[i],
                winner: winner[i]
            });

            unchecked {
                i++;
            }
        }
        return _playerGameState;
    }

    /// @notice to join ith game
    function joinGame(uint256 i) external {
        if (gameOn[i] || playerNum[i][msg.sender] != 0) return;

        currPlayers[i][currNPlayer[i]++] = msg.sender;
        playerNum[i][msg.sender] = currNPlayer[i];
        if (currNPlayer[i] == games[i].size) _startGame(i);
    }

    /// @notice to exit ith game
    function exitGame(uint256 i) external {
        if (gameOn[i] || playerNum[i][msg.sender] == 0) return;

        /// removes msg.sender from the array by replacing it with the last elm and setting the last elm to null
        currPlayers[i][playerNum[i][msg.sender] - 1] = currPlayers[i][
            currNPlayer[i] - 1
        ];
        playerNum[i][currPlayers[i][currNPlayer[i] - 1]] = playerNum[i][
            msg.sender
        ];
        delete currPlayers[i][currNPlayer[i] - 1];

        playerNum[i][msg.sender] = 0;
    }

    /// @notice to end ith game
    function endGame(uint256 i) external {
        if (!gameOn[i] || playerNum[i][msg.sender] == 0) return;

        gameOn[i] = false;
        for (uint256 j = 0; j < games[i].size; ) {
            playerNum[i][currPlayers[i][j]] = 0;
            unchecked {
                j++;
            }
        }
        winner[i] = currPlayers[i][block.number % games[i].size];
        address[] memory _player = new address[](games[i].size);
        currPlayers[i] = _player;
        currNPlayer[i] = 0;
    }

    function _startGame(uint256 i) internal {
        gameOn[i] = true;
    }
}
