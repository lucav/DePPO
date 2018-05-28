# DePPO
## Decentralized Political Party Organization
A proposal for a new kind of Political Party organization.

## Features 
 - A new member can pay a fee for enter in the political party (like a subscription) [0.1]
 - Set/Get the fee amount (in Finney, milli Ether) for a new member [0.1]
 - Anyone can send donation (if him is already a member or if send more then the fee amount) [0.1]
 - A new member can be added manually by the smart contract's owner without pay the fee [0.1]
 - Fund withdraw by the smart contract's owner [0.1]
 - A member can be assigned as a counselor by the smart contract's owner [0.1]
 - A member can be removed (expelled) by the smart contract's owner [0.1]
 - A new Motion can be created by a councelor (with an optional secret key) [0.1]
 - The Motion can be executed after the minimum debates time by a councelor (that know the secret key) [0.1]
 - Voting rules: 
   - minimum minutes for debate [0.1]
   - quorum need for execute a motion [0.1]
   - yes, no, abstention as vote options (the abstention vote will be count for the quorum) [0.1]   
   - each member vote with their own vote weight (that can be more then 1, like the President for example) [0.1]
   - any valid member can vote (should not was expelled and vote weight > 0) [0.1]
 - A councelor can modify the voting rules about:
   - the minutes for debate [0.1]
   - the quorum needed for execute a motion [0.1]

## To-Do List
 
 #### General
 - [ ] Improve: Reduce the power of the smart contract's owner
 - [ ] Improve: vote weight managements (should be modified on need)
 - [ ] Improve: quorum could be managed also as percentage
 - [ ] New: Create a motion where only the Council (councelors) can vote 
 
 #### Development
 - [ ] Improve: Make better abstraction (smart contracts)
 - [ ] New: Create tests
 - [ ] New: Create an automatic deletion for Mist db/chain folder on truffle migration reset task (as a separate task)

*Any suggestions are welcome!*

## Tech
[![Solidity](https://raw.githubusercontent.com/lucav/Resources/master/solidity-logo.png)](https://solidity.readthedocs.io/en/v0.4.24/index.html)

[![Truffle](https://raw.githubusercontent.com/lucav/Resources/master/truffle-logo.png)](http://truffleframework.com/)

[![OpenZeppelin](https://raw.githubusercontent.com/lucav/Resources/master/openzeppelin-logo.png)](https://openzeppelin.org/)

Developed in the following Windows environment:
 - Visual Studio Code (with plugin for Solidity)
 - Truffle 
 - Ganache
 - Mist (for easy smart contract use)

Solidity frameworks:
 - OpenZeppelin

## Versions

[0.1] - First Commit

### License
GNU GENERAL PUBLIC LICENSE Version 3

*If you wish to fork or use this code in some other way, please refeer to the authors in your code, thanks!*

#### Disclaimer
*No warranty provided. All product names, logos, and brands are property of their respective owners.*
