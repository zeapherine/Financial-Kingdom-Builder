use starknet::ContractAddress;

#[derive(Drop, Copy, Serde, starknet::Store)]
pub struct LeaderboardEntry {
    pub user: ContractAddress,
    pub score: u256,
    pub timestamp: u64,
}

#[starknet::interface]
pub trait ILeaderboard<TContractState> {
    fn update_score(
        ref self: TContractState,
        user: ContractAddress,
        category: felt252,
        period_type: felt252,
        score: u256
    );
    fn get_user_rank(
        self: @TContractState,
        user: ContractAddress,
        category: felt252,
        period_type: felt252
    ) -> u32;
    fn get_user_score(
        self: @TContractState,
        user: ContractAddress,
        category: felt252,
        period_type: felt252
    ) -> u256;
    fn set_score_updater(ref self: TContractState, updater: ContractAddress, allowed: bool);
    fn is_score_updater(self: @TContractState, updater: ContractAddress) -> bool;
    fn get_owner(self: @TContractState) -> ContractAddress;
}

#[starknet::contract]
pub mod Leaderboard {
    use starknet::ContractAddress;
    use starknet::{get_caller_address, get_block_timestamp};
    use starknet::storage::{
        Map, StoragePointerReadAccess, StoragePointerWriteAccess, 
        StorageMapReadAccess, StorageMapWriteAccess
    };

    #[storage]
    struct Storage {
        owner: ContractAddress,
        leaderboard_scores: Map<(felt252, felt252, ContractAddress), u256>,
        score_updaters: Map<ContractAddress, bool>,
        user_positions: Map<(felt252, felt252, ContractAddress), u32>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        ScoreUpdated: ScoreUpdated,
        ScoreUpdaterSet: ScoreUpdaterSet,
    }

    #[derive(Drop, starknet::Event)]
    struct ScoreUpdated {
        user: ContractAddress,
        category: felt252,
        period_type: felt252,
        new_score: u256,
        old_score: u256,
        timestamp: u64,
    }

    #[derive(Drop, starknet::Event)]
    struct ScoreUpdaterSet {
        updater: ContractAddress,
        allowed: bool,
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        self.owner.write(owner);
    }

    #[abi(embed_v0)]
    impl LeaderboardImpl of super::ILeaderboard<ContractState> {
        fn update_score(
            ref self: ContractState,
            user: ContractAddress,
            category: felt252,
            period_type: felt252,
            score: u256
        ) {
            self._assert_only_score_updater();
            
            let key = (category, period_type, user);
            let old_score = self.leaderboard_scores.read(key);
            
            if score <= old_score {
                return;
            }
            
            self.leaderboard_scores.write(key, score);
            
            self.emit(Event::ScoreUpdated(ScoreUpdated {
                user,
                category,
                period_type,
                new_score: score,
                old_score,
                timestamp: get_block_timestamp(),
            }));
        }

        fn get_user_rank(
            self: @ContractState,
            user: ContractAddress,
            category: felt252,
            period_type: felt252
        ) -> u32 {
            self.user_positions.read((category, period_type, user))
        }

        fn get_user_score(
            self: @ContractState,
            user: ContractAddress,
            category: felt252,
            period_type: felt252
        ) -> u256 {
            self.leaderboard_scores.read((category, period_type, user))
        }

        fn set_score_updater(ref self: ContractState, updater: ContractAddress, allowed: bool) {
            self._assert_only_owner();
            self.score_updaters.write(updater, allowed);
            
            self.emit(Event::ScoreUpdaterSet(ScoreUpdaterSet {
                updater,
                allowed,
            }));
        }

        fn is_score_updater(self: @ContractState, updater: ContractAddress) -> bool {
            self.score_updaters.read(updater)
        }

        fn get_owner(self: @ContractState) -> ContractAddress {
            self.owner.read()
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn _assert_only_score_updater(self: @ContractState) {
            let caller = get_caller_address();
            assert(
                self.score_updaters.read(caller) || caller == self.owner.read(),
                'Not authorized to update scores'
            );
        }

        fn _assert_only_owner(self: @ContractState) {
            let caller = get_caller_address();
            assert(caller == self.owner.read(), 'Only owner can call this');
        }
    }
}