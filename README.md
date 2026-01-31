# Provably Fair Decentralized Lottery

## 👤 Author

**Mohd Shariq**

- GitHub: [@Shariq103](https://github.com/Shariq103)

##

This is a **Provably Fair Smart Contract Lottery** built using **Solidity** and **Foundry**. It leverages **Chainlink VRF** for verifiable randomness and **Chainlink Automation** for time-based triggers, ensuring a completely decentralized and automated gaming experience.

## Key Features

- **Truly Random:** Uses Chainlink VRF (Verifiable Random Function) to select a winner. No one (not even the developer) can manipulate the result.
- **Automated:** Uses Chainlink Automation (Keepers) to automatically trigger the winner selection after a set interval.
- **Decentralized:** The logic lives entirely on the blockchain (Sepolia/Ethereum).
- **Gas Efficient:** Optimized code structure following best practices.
- **Robust Testing:** Includes comprehensive Unit and Integration tests using Foundry.

## Technology Stack

- **Language:** Solidity ^0.8.19
- **Framework:** Foundry (Forge, Cast, Anvil)
- **Oracle Services:** Chainlink VRF v2.5 & Chainlink Automation
- **Network:** Sepolia Testnet

## Architecture

1.  **Enter:** Players join by paying an entrance fee (ETH).
2.  **Wait:** The lottery runs for a specific time interval.
3.  **Trigger:** Chainlink Automation checks if the time is up.
4.  **Request:** The contract requests a random number from Chainlink VRF.
5.  **Fulfill:** Chainlink VRF returns a random number, and the contract calculates the winner.
6.  **Payout:** The winner automatically receives the entire pot balance.

## Getting Started

### Prerequisites

- [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- [Foundry](https://getfoundry.sh/)
- [Make](https://www.gnu.org/software/make/) (Optional, for using Makefiles)

### Installation

1.  **Clone the repository:**

    ```bash
    git clone [https://github.com/](https://github.com/)[YOUR_USERNAME]/foundry-smart-contract-lottery.git
    cd foundry-smart-contract-lottery
    ```

2.  **Install Dependencies:**

    ```bash
    make install
    # or
    forge install
    ```

3.  **Compile the contracts:**
    ```bash
    forge build
    ```

## 🧪 Testing

This project includes both Unit and Integration tests to ensure reliability.

**Run Unit Tests:**

```bash
forge test
```

# foundry-Lottery-Raffle
