// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CatsAndMice {
    enum Role { None, Cat, Mouse }
    enum GameState { WaitingForPlayers, InProgress, Finished }

    struct Player {
        address addr;
        Role role;
        uint8 x;
        uint8 y;
    }

    GameState public gameState;
    Player public cat;
    Player public mouse;
    uint8 public boardSize = 5;
    uint8 public cheeseX;
    uint8 public cheeseY;
    address public winner;
    address public turn; // whose turn is it

    constructor() {
        gameState = GameState.WaitingForPlayers;
    }

    function joinAsCat() external {
        require(cat.addr == address(0), "Cat already joined");
        cat = Player(msg.sender, Role.Cat, 0, 0);
        updateGameStart();
    }

    function joinAsMouse() external {
        require(mouse.addr == address(0), "Mouse already joined");
        mouse = Player(msg.sender, Role.Mouse, boardSize - 1, boardSize - 1);
        updateGameStart();
    }

    function updateGameStart() internal {
        if (cat.addr != address(0) && mouse.addr != address(0)) {
            gameState = GameState.InProgress;
            turn = mouse.addr; // Mouse moves first
            placeCheese();
        }
    }

    function placeCheese() internal {
        // Place cheese randomly, but not on starting positions
        cheeseX = 2;
        cheeseY = 2;
    }

    function move(uint8 newX, uint8 newY) external {
        require(gameState == GameState.InProgress, "Game is not in progress");
        require(msg.sender == turn, "Not your turn");
        require(newX < boardSize && newY < boardSize, "Move out of bounds");

        if (msg.sender == mouse.addr) {
            require(isValidMove(mouse.x, mouse.y, newX, newY), "Invalid move for mouse");
            mouse.x = newX;
            mouse.y = newY;
            checkVictory();
            turn = cat.addr;
        } else if (msg.sender == cat.addr) {
            require(isValidMove(cat.x, cat.y, newX, newY), "Invalid move for cat");
            cat.x = newX;
            cat.y = newY;
            checkVictory();
            turn = mouse.addr;
        }
    }

    function isValidMove(uint8 fromX, uint8 fromY, uint8 toX, uint8 toY) internal pure returns (bool) {
        uint8 dx = fromX > toX ? fromX - toX : toX - fromX;
        uint8 dy = fromY > toY ? fromY - fromY : toY - fromY;
        return (dx + dy == 1); // Only move to adjacent cell (no diagonals)
    }

    function checkVictory() internal {
        if (mouse.x == cheeseX && mouse.y == cheeseY) {
            gameState = GameState.Finished;
            winner = mouse.addr;
        } else if (mouse.x == cat.x && mouse.y == cat.y) {
            gameState = GameState.Finished;
            winner = cat.addr;
        }
    }

    function getPositions() external view returns (uint8 catX, uint8 catY, uint8 mouseX, uint8 mouseY, uint8 cheesePosX, uint8 cheesePosY) {
        return (cat.x, cat.y, mouse.x, mouse.y, cheeseX, cheeseY);
    }
}
