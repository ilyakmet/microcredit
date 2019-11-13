const Microcredit = artifacts.require("Microcredit");
const ProxyMicrocredit = artifacts.require("ProxyMicrocredit");

contract('ProxyMicrocredit', (accounts) => {
  let microcreditInstance;
  let proxyMicrocreditInstance;

  const ethAmount = web3.utils.toWei('3', 'ether');
  const userBalanceTarget = 102.90;
  const ownerBalanceTarget = 99.80;
  const approveAmount = ethAmount;
  const user = accounts[1];
  const amount = ethAmount;
  const expires = 1000000;
  const nonce = 100;
  let sig;
  let hash;

  const signRequest = async (contractAddress, amount, expires, nonce, account) => {
    const hash = web3.utils.soliditySha3(contractAddress, amount, expires, nonce);
    let sig = await web3.eth.sign(hash, account);
    sig = sig.substr(0, 130) + (sig.substr(130) == "00" ? "1b" : "1c");
    return {hash, sig, account};
  }

  before('setup contract for test', async () => {
    microcreditInstance = await Microcredit.new();
    proxyMicrocreditInstance = await ProxyMicrocredit.new();

    hash = web3.utils.soliditySha3(microcreditInstance.address, amount, expires, nonce);

    const sigRes = await signRequest(microcreditInstance.address, amount, expires, nonce, user);
    sig = sigRes.sig;

    await microcreditInstance.transferOwnership(
      proxyMicrocreditInstance.address,  
      {from: accounts[0]}
    );

    await proxyMicrocreditInstance.registerName(
      'Microcredit', 
      microcreditInstance.address, 
      1, 
      {from: accounts[0]}
    );

    await proxyMicrocreditInstance.setInstance(
      'Microcredit',  
      {from: accounts[0]}
    );
  });

  it('should be with Microcredit address in NameRegistry', async () => {
    const contractAddress = await proxyMicrocreditInstance.contractAddress.call();
    assert.equal(contractAddress, microcreditInstance.address);
  });

  it('created request', async () => {
    await proxyMicrocreditInstance.request(
      amount,
      expires,
      nonce,  
      sig,
      {from: user}
    );

    const requestIsExist = await microcreditInstance.requests.call(user, hash);

    assert(requestIsExist);
  });

  it('can execute only owner', async () => {
    try {
      await proxyMicrocreditInstance.approve(
        user,
        amount,
        expires,
        nonce,  
        sig,
        { 
          value: approveAmount,
          from: user
        }
      );
  
      assert(false);
    } catch (error) {
        assert(error);
    }
  });

  it('created approve', async () => {
    await proxyMicrocreditInstance.approve(
      user,
      amount,
      expires,
      nonce,  
      sig,
      { 
        value: approveAmount,
        from: accounts[0]
      }
    );


    let balance = await web3.eth.getBalance(user);
    balance = web3.utils.fromWei(balance, 'ether');
    balance = parseFloat(balance);

    let debt = await microcreditInstance.debts.call(user, hash);
    debt = web3.utils.fromWei(debt, 'ether');
    debt = parseFloat(debt);

    assert(balance > userBalanceTarget && debt > 0);
  });

  it('can`t cancel request while debt > 0', async () => {
    try {
      await proxyMicrocreditInstance.cancel(
        user,
        amount,
        expires,
        nonce,  
        sig,
        { 
          from: user
        }
      );
      assert(false);
    } catch (err) {
        assert(err);
    }
  });

  it('return credit funds', async () => {
    let debtBefore = await microcreditInstance.debts.call(user, hash);

    await proxyMicrocreditInstance.refund(
      user,
      amount,
      expires,
      nonce,  
      { 
        value: approveAmount,
        from: user
      }
    );

    let debtAfter = await microcreditInstance.debts.call(user, hash);

    debtBefore = web3.utils.fromWei(debtBefore, 'ether');
    debtBefore = parseFloat(debtBefore);

    debtAfter = web3.utils.fromWei(debtAfter, 'ether');
    debtAfter = parseFloat(debtAfter);

    assert(debtBefore > debtAfter, 'No change in debt!');
  });

  it('can`t cancel by not owner', async () => {
    try {
      await proxyMicrocreditInstance.cancel(
        amount,
        expires,
        nonce,  
        sig,
        { 
          from: accounts[0]
        }
      );
      assert(false);
      } catch (err) {
        assert(err);
      }
  });

  it('can cancel request if debt == 0', async () => {
    await proxyMicrocreditInstance.cancel(
      amount,
      expires,
      nonce,  
      sig,
      { 
        from: user
      }
    );
    assert(true);
  });

  it('can withdraw funds', async () => {
    await proxyMicrocreditInstance.withdraw({ from: accounts[0] });

    let balance = await web3.eth.getBalance(accounts[0]);
    balance = web3.utils.fromWei(balance, 'ether');
    balance = parseFloat(balance);

    assert(balance > ownerBalanceTarget);
  });
});