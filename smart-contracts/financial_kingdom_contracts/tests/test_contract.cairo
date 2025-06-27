use starknet::ContractAddress;
use starknet::contract_address_const;

use snforge_std::{declare, ContractClassTrait, DeclareResultTrait};

use financial_kingdom_contracts::achievement_nft::{IAchievementNFTDispatcher, IAchievementNFTDispatcherTrait};
use financial_kingdom_contracts::kingdom_state::{IKingdomStateDispatcher, IKingdomStateDispatcherTrait};
use financial_kingdom_contracts::leaderboard::{ILeaderboardDispatcher, ILeaderboardDispatcherTrait};
use financial_kingdom_contracts::paymaster::{IPaymasterDispatcher, IPaymasterDispatcherTrait};

fn deploy_achievement_nft() -> ContractAddress {
    let contract = declare("AchievementNFT").unwrap().contract_class();
    let owner = contract_address_const::<0x123>();
    let minter = contract_address_const::<0x456>();
    let mut calldata = array![owner.into(), minter.into()];
    let (contract_address, _) = contract.deploy(@calldata).unwrap();
    contract_address
}

fn deploy_kingdom_state() -> ContractAddress {
    let contract = declare("KingdomState").unwrap().contract_class();
    let owner = contract_address_const::<0x123>();
    let mut calldata = array![owner.into()];
    let (contract_address, _) = contract.deploy(@calldata).unwrap();
    contract_address
}

fn deploy_leaderboard() -> ContractAddress {
    let contract = declare("Leaderboard").unwrap().contract_class();
    let owner = contract_address_const::<0x123>();
    let mut calldata = array![owner.into()];
    let (contract_address, _) = contract.deploy(@calldata).unwrap();
    contract_address
}

fn deploy_paymaster() -> ContractAddress {
    let contract = declare("Paymaster").unwrap().contract_class();
    let owner = contract_address_const::<0x123>();
    let default_daily_limit: u256 = 1000000;
    let default_tx_limit: u256 = 100000;
    let minimum_balance: u256 = 50000;
    let mut calldata = array![
        owner.into(), 
        default_daily_limit.low.into(), 
        default_daily_limit.high.into(),
        default_tx_limit.low.into(),
        default_tx_limit.high.into(),
        minimum_balance.low.into(),
        minimum_balance.high.into()
    ];
    let (contract_address, _) = contract.deploy(@calldata).unwrap();
    contract_address
}

#[test]
fn test_achievement_nft_deployment() {
    let contract_address = deploy_achievement_nft();
    let dispatcher = IAchievementNFTDispatcher { contract_address };
    
    let owner = dispatcher.get_owner();
    assert(owner == contract_address_const::<0x123>(), 'Invalid owner');
}

#[test]
fn test_kingdom_state_deployment() {
    let contract_address = deploy_kingdom_state();
    let dispatcher = IKingdomStateDispatcher { contract_address };
    
    let owner = dispatcher.get_owner();
    assert(owner == contract_address_const::<0x123>(), 'Invalid owner');
}

#[test]
fn test_leaderboard_deployment() {
    let contract_address = deploy_leaderboard();
    let dispatcher = ILeaderboardDispatcher { contract_address };
    
    let owner = dispatcher.get_owner();
    assert(owner == contract_address_const::<0x123>(), 'Invalid owner');
}

#[test]
fn test_paymaster_deployment() {
    let contract_address = deploy_paymaster();
    let dispatcher = IPaymasterDispatcher { contract_address };
    
    let owner = dispatcher.get_owner();
    assert(owner == contract_address_const::<0x123>(), 'Invalid owner');
    
    let balance = dispatcher.get_balance();
    assert(balance == 0, 'Initial balance should be 0');
}
