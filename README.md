# Solidity Smart Contract Assignment

**Name:** Võ Khắc TUyên 
**Student ID:** 30219042961
**Email:** vokhactuyen2006@gmail.com

15 standalone Solidity source files, written for Solidity **0.8.19**.
`04_Ownable.sol` contains both `Ownable` and the deployable child `ProtectedVault`.
No OpenZeppelin imports are used.

## Status

Source code and supplemental automated test cases are prepared. Compilation and
test execution have **not been verified** in the authoring environment: dependency
installation was blocked with `EACCES` while accessing the npm registry.
No Remix/Ganache GUI deployment or screenshots have been completed.
Change the table only after performing the corresponding manual tests.

| # | Contract | Level | Tested via Remix on Ganache | Screenshots |
|---|---|---|---|---|
| 01 | Storage | Basic | Pending | Pending |
| 02 | Greeting | Basic | Pending | Pending |
| 03 | Counter | Basic | Pending | Pending |
| 04 | Ownable / ProtectedVault | Medium | Pending | Pending |
| 05 | SimpleBank | Medium | Pending | Pending |
| 06 | Voting | Medium | Pending | Pending |
| 07 | MyToken | Medium | Pending | Pending |
| 08 | Crowdfunding | Advanced | Pending | Pending |
| 09 | Lottery | Advanced | Pending | Pending |
| 10 | TimeLockVault | Advanced | Pending | Pending |
| 11 | Escrow | Advanced | Pending | Pending |
| 12 | SimpleNFT | Advanced | Pending | Pending |
| 13 | EnglishAuction | Expert | Pending | Pending |
| 14 | MultisigWallet | Expert | Pending | Pending |
| 15 | StakingRewards | Expert | Pending | Pending |

## How to run

1. Open https://remix.ethereum.org and create workspace `Assignment15`.
2. Upload the `.sol` files in `contracts/` into the workspace.
3. Select compiler **0.8.19**, optimizer enabled / 200 runs, EVM **Paris**.
4. Start Ganache with RPC `http://127.0.0.1:7545`.
5. In Remix's Deploy & Run tab, select **External HTTP Provider** (sometimes
   labelled **Custom - External Http Provider**) and enter that RPC URL.
6. Select the correct contract, enter its constructor arguments, and deploy.
7. Follow [HUONG_DAN.md](HUONG_DAN.md) for the per-contract test checklist.
8. Save genuine screenshots and complete [report/REPORT.md](report/REPORT.md).

## Supplemental local checks

Node.js and npm are needed for these commands. In PowerShell, use `npm.cmd` if
execution policy prevents `npm.ps1` from running.

```powershell
npm.cmd install
npm.cmd run compile
npm.cmd test
```

Compilation writes ABI and bytecode to ignored `artifacts/`.
The tests create a fresh, in-process Ganache chain; they do not connect to, change,
or capture screenshots of your Ganache GUI workspace. They use a fixed timestamp
increment and advance virtual time to check reward arithmetic exactly.
They supplement the mandatory manual Remix testing; they do not replace it.
Commit the generated `package-lock.json` after successful installation.

## Clarifications for inconsistencies in the assignment

- **Staking units:** the PDF's literal formula multiplies a stake in wei by a
  rate of 1000, but its example expects only 60,000 wei after staking 1 ETH for
  60 seconds. This implementation follows the numerical example:
  `reward = amountInWei * rate * elapsedSeconds / 1e18` for a constant rate.
  Thus the rate means **wei of reward per 1 ETH staked per second**. Confirm this
  interpretation with the instructor before final submission.
- **Rate changes:** a cumulative rate integral snapshots each user's accrual.
  Old time earns at the old rate; new time earns at the new rate, without looping
  over users. `startTime` records the user's latest settlement time; `paidRate`
  identifies the user's individual rate checkpoint. Top-ups snapshot rewards
  before adding principal; claims reset earned whole wei while retaining
  sub-wei remainder. Full exit discards sub-wei dust.
- **Insufficient rewards:** claims and full unstaking revert if `rewardPool`
  cannot cover the reward, as required by the PDF. The owner must top up the pool
  before that user can fully exit. Principal is never counted as reward funding.
- **Multisig:** submission includes the submitter's confirmation. Therefore A
  submits and B confirms a 2-of-3 transaction, matching the PDF's test sequence.
  When execution fails, the entire triggering call (including its new
  confirmation) reverts. Fund the wallet before the final confirmation.
- **NFT test:** after B mints token 0 and C mints token 1, **C** must approve a
  spender for token 1. A different account cannot approve someone else's token.
- **Token units:** constructor `_supply` takes whole tokens. Public amounts for
  `transfer`, `approve`, and `transferFrom` take smallest units (18 decimals).
- **Escrow:** the constructor requires positive payment, so it starts directly
  in `AwaitingDelivery`. `AwaitingPayment` remains in the requested enum but no
  separate funding function was specified. The three parties must be distinct.
- **Voting:** ties, including zero votes, select the earliest input candidate.
- **Auction:** the start price seeds `highestBid`; the first bid also needs the
  specified 5% increment. Required increments round upward to whole wei.
- **Lottery:** blockhash-based winner selection is intentionally educational and
  manipulable; it must not be used for a real-money lottery. Verifiable
  randomness such as Chainlink VRF is a better production design.
- **NFT scope:** this is the requested ERC-721-style subset. It omits full
  ERC-721 compatibility features such as safe receiver checks and ERC-165.
- **Storage testing:** Storage has no required `require` guard, so there is no
  meaningful contract-level require-revert test for this file.
- **Time-lock extension:** `extendLock` adds seconds to the existing deadline.
  After expiry, a small extension may still leave the deadline in the past.

## Submission

Create a public repository named `solidity-smart-contracts-assignment`.
Fill in student details, test all functions and failure cases on Ganache through
Remix, capture at least 30 screenshots, and update the report with actual results
and transaction hashes. Use meaningful commits as you complete and verify work.
Submit the repository URL. Be prepared to explain every line during the viva.

Language/security references:
[Solidity units](https://docs.soliditylang.org/en/v0.8.18/units-and-global-variables.html),
[Solidity security considerations](https://docs.soliditylang.org/en/latest/security-considerations.html),
[Remix deploy and run](https://remix-ide.readthedocs.io/en/latest/run.html).
