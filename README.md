📖 README – Poetry NFT Smart Contract

Overview

The Poetry NFT Smart Contract is a collaborative creative-writing platform built on the Stacks blockchain. It allows users to collectively write poems, line by line, and mint completed poems as NFTs. This contract blends art, community engagement, and blockchain immutability by making collaborative poetry verifiable, tradable, and permanent.

✨ Features

Poem Creation: Any user can start a new poem with a title.

Collaborative Line Submission: Contributors can submit poetry lines (up to 280 characters) to any open poem.

Validation Rules:

Lines must be non-empty.

Maximum line length is capped at 280 characters.

Submissions are blocked once a poem is completed.

Completion & NFT Minting: Only the poem’s creator can complete a poem. When completed, an NFT is minted representing the poem.

Ownership Tracking: NFTs can be transferred between users. The contract also tracks how many poems each user has minted.

On-chain Metadata: Each poem stores title, creator, line count, status, and creation height. Each line stores its text, author, and timestamp.

📚 Data Structures

Poems Map: Stores metadata for each poem (title, creator, completion status, etc.).

Poem Lines Map: Stores each submitted line with its poem association, author, and content.

User Poem Count Map: Tracks how many NFTs each user has minted.

🛠️ Functions
Read-only

get-poem (poem-id) → Returns poem metadata.

get-poem-line (line-id) → Returns line metadata.

get-user-poem-count (user) → Returns number of NFTs minted by a user.

get-next-poem-id / get-next-line-id → Returns the next available IDs.

Public

create-poem (title) → Starts a new poem.

submit-line (poem-id, content) → Adds a new line to a poem.

complete-poem (poem-id) → Marks poem as complete and mints NFT to creator.

transfer-poem (poem-id, recipient) → Transfers ownership of a poem NFT.

🚨 Error Codes

u100: Caller not authorized (owner-only functions).

u101: Poem not found.

u102: Submitted line too long.

u103: Submitted line empty.

u104: Poem already complete.

u105: Cannot complete a poem with zero lines.

🌐 Use Cases

Community-driven poetry anthologies on-chain.

Collaborative creative NFT projects.

Educational or literary experiments combining blockchain with literature.

Tradable cultural assets where value comes from both art and collaboration.

🔑 Deployment Notes

Contract owner is set at deployment (contract-owner).

NFT is identified by poem ID.

Titles use ASCII (100 chars max), lines use UTF-8 (280 chars max).