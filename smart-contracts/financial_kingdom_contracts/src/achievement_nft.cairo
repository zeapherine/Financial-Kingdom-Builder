use starknet::ContractAddress;

#[derive(Drop, Serde, starknet::Store)]
pub struct AchievementMetadata {
    pub achievement_type: felt252,
    pub timestamp: u64,
    pub progress_data: felt252,
    pub tier: u8,
}

#[starknet::interface]
pub trait IAchievementNFT<TContractState> {
    fn mint_achievement(
        ref self: TContractState,
        to: ContractAddress,
        achievement_type: felt252,
        progress_data: felt252,
        tier: u8
    ) -> u256;
    fn get_achievement_metadata(self: @TContractState, token_id: u256) -> AchievementMetadata;
    fn get_user_achievements_count(self: @TContractState, user: ContractAddress) -> u256;
    fn set_minter(ref self: TContractState, minter: ContractAddress);
    fn get_minter(self: @TContractState) -> ContractAddress;
    fn get_owner(self: @TContractState) -> ContractAddress;
    fn owner_of(self: @TContractState, token_id: u256) -> ContractAddress;
    fn balance_of(self: @TContractState, owner: ContractAddress) -> u256;
}

#[starknet::contract]
pub mod AchievementNFT {
    use starknet::ContractAddress;
    use starknet::{get_caller_address, get_block_timestamp};
    use starknet::storage::{
        Map, StoragePointerReadAccess, StoragePointerWriteAccess, 
        StorageMapReadAccess, StorageMapWriteAccess
    };
    use super::AchievementMetadata;

    #[storage]
    struct Storage {
        achievement_metadata: Map<u256, AchievementMetadata>,
        token_owners: Map<u256, ContractAddress>,
        user_balances: Map<ContractAddress, u256>,
        next_token_id: u256,
        authorized_minter: ContractAddress,
        owner: ContractAddress,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        AchievementMinted: AchievementMinted,
        MinterSet: MinterSet,
    }

    #[derive(Drop, starknet::Event)]
    struct AchievementMinted {
        to: ContractAddress,
        token_id: u256,
        achievement_type: felt252,
        tier: u8,
        timestamp: u64,
    }

    #[derive(Drop, starknet::Event)]
    struct MinterSet {
        old_minter: ContractAddress,
        new_minter: ContractAddress,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        owner: ContractAddress,
        minter: ContractAddress
    ) {
        self.owner.write(owner);
        self.next_token_id.write(1);
        self.authorized_minter.write(minter);
    }

    #[abi(embed_v0)]
    impl AchievementNFTImpl of super::IAchievementNFT<ContractState> {
        fn mint_achievement(
            ref self: ContractState,
            to: ContractAddress,
            achievement_type: felt252,
            progress_data: felt252,
            tier: u8
        ) -> u256 {
            self._assert_only_minter();
            
            let token_id = self.next_token_id.read();
            let timestamp = get_block_timestamp();
            
            let metadata = AchievementMetadata {
                achievement_type,
                timestamp,
                progress_data,
                tier,
            };
            
            self.token_owners.write(token_id, to);
            self.achievement_metadata.write(token_id, metadata);
            
            let current_balance = self.user_balances.read(to);
            self.user_balances.write(to, current_balance + 1);
            
            self.next_token_id.write(token_id + 1);
            
            self.emit(Event::AchievementMinted(AchievementMinted {
                to,
                token_id,
                achievement_type,
                tier,
                timestamp,
            }));
            
            token_id
        }

        fn get_achievement_metadata(self: @ContractState, token_id: u256) -> AchievementMetadata {
            self.achievement_metadata.read(token_id)
        }

        fn get_user_achievements_count(self: @ContractState, user: ContractAddress) -> u256 {
            self.user_balances.read(user)
        }

        fn set_minter(ref self: ContractState, minter: ContractAddress) {
            self._assert_only_owner();
            let old_minter = self.authorized_minter.read();
            self.authorized_minter.write(minter);
            
            self.emit(Event::MinterSet(MinterSet {
                old_minter,
                new_minter: minter,
            }));
        }

        fn get_minter(self: @ContractState) -> ContractAddress {
            self.authorized_minter.read()
        }

        fn get_owner(self: @ContractState) -> ContractAddress {
            self.owner.read()
        }

        fn owner_of(self: @ContractState, token_id: u256) -> ContractAddress {
            self.token_owners.read(token_id)
        }

        fn balance_of(self: @ContractState, owner: ContractAddress) -> u256 {
            self.user_balances.read(owner)
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn _assert_only_minter(self: @ContractState) {
            let caller = get_caller_address();
            let minter = self.authorized_minter.read();
            assert(caller == minter, 'Only minter can mint');
        }

        fn _assert_only_owner(self: @ContractState) {
            let caller = get_caller_address();
            let owner = self.owner.read();
            assert(caller == owner, 'Only owner can call this');
        }
    }
}