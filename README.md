# OpenGradient Smart Contract Deployment Guide

- This guide works on VPS,  
- Github Codespace/ Gitpod / Linux based Terminal (Ubuntu, WSL)

In this guide, we're using Linux based Terminal (Ubuntu, WSL) <br/>
<br/>
**Let's get started :)** 

- Ensure you claim faucet from this [link](http://18.218.115.248:8080/) to your evm  address before you proceed
  
  - If you've done that, Paste this in your terminal:
    
```bash
mkdir opengradient && cd opengradient && wget -q https://raw.githubusercontent.com/WillzyDollarrzz/OpenGradient-DevNet/refs/heads/main/opengradient.sh && chmod +x opengradient.sh && ./opengradient.sh
```
When creating a hardhat project, which you'll see,
- press `enter` then `enter` again, then type `y`
<br/>

- To view your private key, paste

```bash
 grep "PRIVATE_KEY" .env | cut -d '=' -f2

```

NOTE : If you get an error in the last part, unlikely though...

- Paste this
 ```bash
 npx hardhat run scripts/deploy.js --network opengradient
```
- You might have to repeat it twice or thrice before it'll deploy successfully 
- i also noticed despite the error it still deploys and shows on the [explorer](http://3.145.62.2/)
- if you also want to deploy more, the code does that i.e `npx har...`
 
If you encounter further errors or want to reach out to me about other projects, you can do so [here](https://x.com/willzydollarrzz)

