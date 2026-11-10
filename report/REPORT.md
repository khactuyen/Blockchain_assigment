# Smart Contract Report

## 01 Storage
- What it does: Stores and updates one unsigned integer.
- Key concept: State, constructor, view calls and indexed ValueSet events.
- Tested: Deployed with 42; get returned 42; B set 100; get returned 100; ValueSet logged.
- Ganache proof: [Task 1](../screenshots/Task_1/).

## 02 Greeting
- What it does: Stores a message that only the deployer can update or reset.
- Key concept: A reusable owner modifier and events on each change.
- Tested: Owner set GM Ganache; GreetingChanged logged; non-owner reset rejected during gas estimation; owner reset returned Hello, World!.
- Ganache proof: [Task 2](../screenshots/Task_2/).

## 03 Counter
- What it does: Increments/decrements between 0 and 100; supports explicit reset.
- Key concept: Boundary checks with clear revert messages and change events.
- Tested: Incremented event recorded count 30; decrement rejected during gas estimation. Remaining checks pending.
- Ganache proof: [Task 3](../screenshots/Task_3/).

## 04 Ownable / ProtectedVault
- What it does: Reuses ownership logic in a vault that accepts deposits and allows owner withdrawals.
- Key concept: Inheritance and onlyOwner avoid duplicating the same authorization check in each protected function.
- Tested: 1 ETH deposit and ownership transfer to B recorded. Withdrawal and remaining checks pending.
- Ganache proof: [Task 4](../screenshots/Task_4/).

## 05 SimpleBank
- What it does: Maintains separate user deposit balances and sends withdrawals with call, checking success.
- Key concept: Checks-Effects-Interactions deducts the user's balance before external calls; a callback cannot spend it twice.
- Tested: A deposited 2 ETH; B deposited 3 ETH; bankTotal returned 5 ETH. Withdrawal checks pending.
- Ganache proof: [Task 5](../screenshots/Task_5/).

## 06 Voting
- What it does: Lets the chairperson authorize voters; each authorized address votes once.
- Key concept: Structs, arrays, mappings and a loop to find the highest vote count; ties select the earliest candidate.
- Planned tests: Alice/Bob/Carol, three authorized voters; verify totals/winner; reject double vote, unauthorized voter and invalid index.
- Actual results / Ganache proof: **Pending**.

## 07 MyToken
- What it does: Implements core fungible-token transfers, approvals and delegated transfers without imports.
- Key concept: Constructor supply is whole tokens; transfer amounts use 18-decimal base units; transferFrom consumes allowance.
- Planned tests: Mint 1,000,000, transfer 500, approve/spend 200; reject second spend, excess balance and zero recipient.
- Actual results / Ganache proof: **Pending**.

## 08 Crowdfunding
- What it does: Accepts contributions before a deadline; owner claims a successful campaign or users refund a failed one.
- Key concept: Mutually exclusive deadline/goal paths, one-shot payout state, and CEI. raised is a historical total.
- Planned tests: Run success and failure campaigns; reject early claims, duplicate claims/refunds and contributions after deadline.
- Actual results / Ganache proof: **Pending**.

## 09 Lottery
- What it does: Collects exact-fee entries, selects a winner and pays the whole pot before starting a fresh round.
- Key concept: blockhash-based randomness is predictable/manipulable, including by block producers and a manager timing a draw; a better production alternative is Chainlink VRF.
- Planned tests: Five 0.01 ETH entries; wrong fee/manager entry/unauthorized draw fail; payout 0.05 ETH; verify round reset.
- Actual results / Ganache proof: **Pending**.

## 10 TimeLockVault
- What it does: Accepts deposits and permits the beneficiary to withdraw only after the deadline.
- Key concept: Timestamp checks plus role checks; deposits do not extend time, while beneficiary extensions add to the deadline.
- Planned tests: 120-second lock, deposit 1 ETH, reject early/non-beneficiary withdrawal, extend lock, withdraw after new deadline.
- Actual results / Ganache proof: **Pending**. Include a block-timestamp screenshot.

## 11 Escrow
- What it does: Holds buyer payment and releases it to seller or buyer under role and state restrictions.
- Key concept: Enums/stateCheck enforce valid transitions. Positive deployment payment starts at AwaitingDelivery.
- Planned tests: Four separate deployments for delivery, seller refund, dispute-to-seller and dispute-to-buyer; reject wrong roles/states.
- Actual results / Ganache proof: **Pending**.

## 12 SimpleNFT
- What it does: Mints sequential IDs up to 100, tracks ownership, supports direct/delegated transfers and collects mint revenue.
- Key concept: Unique ownership and per-token approvals; clear approval on every transfer to prevent reuse by an old spender.
- Planned tests: Two 0.01 ETH mints; reject wrong price; transfer token 0; current owner approves token 1 transfer; withdraw 0.02 ETH; test cap.
- Actual results / Ganache proof: **Pending**. This is an ERC-721-style subset, not full ERC-721.

## 13 EnglishAuction
- What it does: Accepts bids with at least a 5% increase, records refunds, and pays the seller after expiry.
- Key concept: Pull-payment keeps external callbacks out of bid(). Like SimpleBank, refund withdrawal zeros the liability before call.
- Planned tests: B bids 0.11, C bids 0.12; reject 0.121; B pulls 0.11; expiry pays 0.12; reject repeats/late bids; end an empty auction.
- Actual results / Ganache proof: **Pending**.

## 14 MultisigWallet
- What it does: Holds ETH and executes a proposed transfer once enough distinct owners confirm it.
- Key concept: Owner membership, per-owner confirmations, threshold checks and an executed flag before external call.
- Planned tests: Owners A/B/C, required 2, fund wallet; A submits (first confirmation), B confirms and auto-executes; reject repeats/non-owner.
- Actual results / Ganache proof: **Pending**. Failed execution rolls back the triggering confirmation too.

## 15 StakingRewards
- What it does: Tracks ETH principal separately from a prefunded reward pool; supports top-ups, claims, full exits and owner rate changes.
- Key concept: Per-user checkpoints preserve past rewards at past rates; CEI plus a reentrancy guard protect transfers; rewardDebt holds settled unpaid wei.
- Planned tests: Rate 1000, 5 ETH pool; stake 1/2 ETH; after 60 seconds rewards 60,000/120,000 wei; claim/top-up/rate change/exit; reject duplicate exit and insufficient pool.
- Actual results / Ganache proof: **Pending**. At a constant rate, reward = amountInWei * rate * elapsedSeconds / 1e18, matching the PDF example.
