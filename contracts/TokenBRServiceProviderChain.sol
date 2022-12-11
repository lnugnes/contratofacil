// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

contract TokenBRServiceProviderChain {
    
    struct Government {
        address payable walletAddress; 
        string cnpj;
    }

    Government contractOwner;

    constructor(Government memory contractOwner_) {
        contractOwner = contractOwner_;  // The government who deploys the contract will be the owner
    }

    struct ServiceContract {
        address payable walletAddress;
        string status;
        string name;
        string cnpjProvider;
        uint start;
        uint end;
        address payable bankEscrowAccount; 
        string bankEscrowAccountCnpj;
        string bankEscrowAccountName;
        uint bankEscrowAccountBalance;
    }

    mapping (address => ServiceContract) public serviceContracts; 

    struct ServiceProvider {
        address payable walletAddress; 
        uint balance;
        string cnpj;
        string companyName;
        string status;
        uint start;                    
        uint end;
    }

    mapping (address => ServiceProvider) public serviceProviders; 

    function addContract( // add funds to contract owner (government) - at the same time it adds funds to service contract
        address payable walletAddress, 
        string memory name, 
        string memory cnpjProvider, 
        uint start,                         
        uint end, 
        address payable bankEscrowAccount,
        string memory bankEscrowAccountCnpj,
        string memory bankEscrowAccountName
    ) 
        payable public 
    {
        serviceContracts[walletAddress] = 
            ServiceContract(
                walletAddress, 
                'ativo', 
                name, 
                cnpjProvider, 
                start, 
                end,
                bankEscrowAccount,
                bankEscrowAccountCnpj,
                bankEscrowAccountName,
                msg.value
            ); 
    }

    // It adds the service provider, which is the company that is providing services to the government in Brazil
    function addServiceProvider(address payable walletAddress, string memory cnpj, string memory companyName) public {
        serviceProviders[walletAddress] = ServiceProvider(walletAddress, 0, cnpj, companyName, 'pending', 0, 0);
    }

    function getServiceProvider(address walletAddress) public view returns(string memory cnpj, uint balance,string memory companyName, string memory status, uint start, uint end) {
        cnpj = serviceProviders[walletAddress].cnpj;
        balance = serviceProviders[walletAddress].balance;
        companyName = serviceProviders[walletAddress].companyName;
        status = serviceProviders[walletAddress].status;
        start = serviceProviders[walletAddress].start;
        end = serviceProviders[walletAddress].end;
    }

    function initiateService(address serviceProviderAddress, uint estimatedEndDate) public {
        serviceProviders[serviceProviderAddress].status = 'iniciado';
        serviceProviders[serviceProviderAddress].start = block.timestamp;
        serviceProviders[serviceProviderAddress].end = estimatedEndDate; // Unix timestamp format
    }

    // Three status avaialable for a service contract: Pendente, Iniciado, Finalizado. The smart contract must transfer 
    // the funds from the contract bank escrow account to the service provider account
    function finishService(address payable contractWalletAddress, address payable serviceProviderAddress) public {
        serviceProviders[serviceProviderAddress].status = 'finalizado';
        serviceProviders[serviceProviderAddress].end = block.timestamp;
        serviceProviders[serviceProviderAddress].balance = serviceContracts[contractWalletAddress].bankEscrowAccountBalance;
        serviceProviderAddress.transfer(serviceContracts[contractWalletAddress].bankEscrowAccountBalance);
        serviceContracts[contractWalletAddress].bankEscrowAccountBalance = 0;
        serviceContracts[contractWalletAddress].status = 'executado';
    }

    function isExpired(address walletAddress) public view {
        require(keccak256(abi.encodePacked(serviceContracts[walletAddress].status)) == keccak256(abi.encodePacked("ativo")), 
            "O contrato se encontra expirado.");
        require(keccak256(abi.encodePacked(serviceContracts[walletAddress].status)) == keccak256(abi.encodePacked("inativo")), 
            "O contrato se encontra ativo.");
    }

    function getServiceContractStatus(address walletAddress) public view returns(string memory status) {
        status = serviceContracts[walletAddress].status;
    }

    function getServiceProviderStatus(address walletAddress) public view returns(string memory status) {
        status = serviceProviders[walletAddress].status;
    }

    function setServiceContractStatus(address walletAddress, string memory status, uint start, uint end) public {
        serviceContracts[walletAddress].status = status;
        serviceContracts[walletAddress].start = start;
        serviceContracts[walletAddress].end = end;
    }

    function getDueAmount(address walletAddress) public view returns(uint) {
        return serviceContracts[walletAddress].bankEscrowAccountBalance;
    }

    function balanceOf() view public returns(uint) {
        return address(this).balance; 
    }
}