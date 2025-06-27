use starknet::ContractAddress;

#[derive(Drop, Copy, Serde, starknet::Store)]
pub struct TierRequirements {
    pub virtual_trades_count: u32,
    pub real_trades_count: u32,
    pub education_modules_completed: u32,
    pub trading_streak_days: u32,
    pub capital_preservation_pct: u8,
    pub risk_management_score: u8,
}

#[derive(Drop, Copy, Serde, starknet::Store)]
pub struct UserProgress {
    pub virtual_trades_count: u32,
    pub real_trades_count: u32,
    pub education_modules_completed: u32,
    pub trading_streak_days: u32,
    pub current_streak: u32,
    pub capital_preservation_pct: u8,
    pub risk_management_score: u8,
    pub total_xp: u256,
    pub last_activity_timestamp: u64,
}

#[derive(Drop, Copy, Serde, starknet::Store)]
pub struct KingdomTier {
    pub tier: u8,
    pub name: felt252,
    pub unlocked_at: u64,
    pub requirements_met: bool,
}

#[starknet::interface]
pub trait IKingdomState<TContractState> {
    fn initialize_user(ref self: TContractState, user: ContractAddress);
    fn update_user_progress(
        ref self: TContractState,
        user: ContractAddress,
        virtual_trades: u32,
        real_trades: u32,
        education_modules: u32,
        trading_streak: u32,
        capital_preservation: u8,
        risk_score: u8,
        xp_gained: u256
    );
    fn check_tier_advancement(ref self: TContractState, user: ContractAddress) -> bool;
    fn advance_user_tier(ref self: TContractState, user: ContractAddress) -> u8;
    fn get_user_tier(self: @TContractState, user: ContractAddress) -> KingdomTier;
    fn get_user_progress(self: @TContractState, user: ContractAddress) -> UserProgress;
    fn get_tier_requirements(self: @TContractState, tier: u8) -> TierRequirements;
    fn set_tier_requirements(ref self: TContractState, tier: u8, requirements: TierRequirements);
    fn set_progress_updater(ref self: TContractState, updater: ContractAddress, allowed: bool);
    fn is_progress_updater(self: @TContractState, updater: ContractAddress) -> bool;
    fn get_owner(self: @TContractState) -> ContractAddress;
}

#[starknet::contract]
pub mod KingdomState {
    use starknet::ContractAddress;
    use starknet::storage::{
        Map, StoragePointerReadAccess, StoragePointerWriteAccess, 
        StorageMapReadAccess, StorageMapWriteAccess
    };
    use starknet::{get_caller_address, get_block_timestamp};
    use super::{TierRequirements, UserProgress, KingdomTier};

    #[storage]
    pub struct Storage {
        owner: ContractAddress,
        user_tiers: Map<ContractAddress, KingdomTier>,
        user_progress: Map<ContractAddress, UserProgress>,
        tier_requirements: Map<u8, TierRequirements>,
        progress_updaters: Map<ContractAddress, bool>,
        total_users_count: u32,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        UserInitialized: UserInitialized,
        ProgressUpdated: ProgressUpdated,
        TierAdvanced: TierAdvanced,
        TierRequirementsSet: TierRequirementsSet,
        ProgressUpdaterSet: ProgressUpdaterSet,
    }

    #[derive(Drop, starknet::Event)]
    pub struct UserInitialized {
        pub user: ContractAddress,
        pub timestamp: u64,
    }

    #[derive(Drop, starknet::Event)]
    pub struct ProgressUpdated {
        pub user: ContractAddress,
        pub timestamp: u64,
    }

    #[derive(Drop, starknet::Event)]
    pub struct TierAdvanced {
        pub user: ContractAddress,
        pub old_tier: u8,
        pub new_tier: u8,
        pub tier_name: felt252,
        pub timestamp: u64,
    }

    #[derive(Drop, starknet::Event)]
    pub struct TierRequirementsSet {
        pub tier: u8,
    }

    #[derive(Drop, starknet::Event)]
    pub struct ProgressUpdaterSet {
        pub updater: ContractAddress,
        pub allowed: bool,
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        self.owner.write(owner);
        self._initialize_tier_requirements();
    }

    #[abi(embed_v0)]
    impl KingdomStateImpl of super::IKingdomState<ContractState> {
        fn initialize_user(ref self: ContractState, user: ContractAddress) {
            let current_tier = self.user_tiers.read(user);
            if current_tier.tier > 0 {
                return;
            }

            let initial_tier = KingdomTier {
                tier: 1,
                name: 'Village',
                unlocked_at: get_block_timestamp(),
                requirements_met: true,
            };

            let initial_progress = UserProgress {
                virtual_trades_count: 0,
                real_trades_count: 0,
                education_modules_completed: 0,
                trading_streak_days: 0,
                current_streak: 0,
                capital_preservation_pct: 100,
                risk_management_score: 0,
                total_xp: 0,
                last_activity_timestamp: get_block_timestamp(),
            };

            self.user_tiers.write(user, initial_tier);
            self.user_progress.write(user, initial_progress);
            
            let new_count = self.total_users_count.read() + 1;
            self.total_users_count.write(new_count);

            self.emit(Event::UserInitialized(UserInitialized {
                user,
                timestamp: get_block_timestamp(),
            }));
        }

        fn update_user_progress(
            ref self: ContractState,
            user: ContractAddress,
            virtual_trades: u32,
            real_trades: u32,
            education_modules: u32,
            trading_streak: u32,
            capital_preservation: u8,
            risk_score: u8,
            xp_gained: u256
        ) {
            self._assert_only_progress_updater();
            
            let old_progress = self.user_progress.read(user);
            let timestamp = get_block_timestamp();
            
            let new_progress = UserProgress {
                virtual_trades_count: if virtual_trades > old_progress.virtual_trades_count {
                    virtual_trades
                } else {
                    old_progress.virtual_trades_count
                },
                real_trades_count: if real_trades > old_progress.real_trades_count {
                    real_trades
                } else {
                    old_progress.real_trades_count
                },
                education_modules_completed: if education_modules > old_progress.education_modules_completed {
                    education_modules
                } else {
                    old_progress.education_modules_completed
                },
                trading_streak_days: if trading_streak > old_progress.trading_streak_days {
                    trading_streak
                } else {
                    old_progress.trading_streak_days
                },
                current_streak: trading_streak,
                capital_preservation_pct: capital_preservation,
                risk_management_score: risk_score,
                total_xp: old_progress.total_xp + xp_gained,
                last_activity_timestamp: timestamp,
            };

            self.user_progress.write(user, new_progress);

            self.emit(Event::ProgressUpdated(ProgressUpdated {
                user,
                timestamp,
            }));
        }

        fn check_tier_advancement(ref self: ContractState, user: ContractAddress) -> bool {
            let current_tier = self.user_tiers.read(user);
            let progress = self.user_progress.read(user);
            
            if current_tier.tier >= 4 {
                return false;
            }
            
            let next_tier = current_tier.tier + 1;
            let requirements = self.tier_requirements.read(next_tier);
            
            self._check_requirements_met(progress, requirements)
        }

        fn advance_user_tier(ref self: ContractState, user: ContractAddress) -> u8 {
            self._assert_only_progress_updater();
            
            if !self.check_tier_advancement(user) {
                return 0;
            }
            
            let old_tier = self.user_tiers.read(user);
            let new_tier_number = old_tier.tier + 1;
            let tier_name = self._get_tier_name(new_tier_number);
            
            let new_tier = KingdomTier {
                tier: new_tier_number,
                name: tier_name,
                unlocked_at: get_block_timestamp(),
                requirements_met: true,
            };
            
            self.user_tiers.write(user, new_tier);
            
            self.emit(Event::TierAdvanced(TierAdvanced {
                user,
                old_tier: old_tier.tier,
                new_tier: new_tier_number,
                tier_name,
                timestamp: get_block_timestamp(),
            }));
            
            new_tier_number
        }

        fn get_user_tier(self: @ContractState, user: ContractAddress) -> KingdomTier {
            self.user_tiers.read(user)
        }

        fn get_user_progress(self: @ContractState, user: ContractAddress) -> UserProgress {
            self.user_progress.read(user)
        }

        fn get_tier_requirements(self: @ContractState, tier: u8) -> TierRequirements {
            self.tier_requirements.read(tier)
        }

        fn set_tier_requirements(ref self: ContractState, tier: u8, requirements: TierRequirements) {
            self._assert_only_owner();
            self.tier_requirements.write(tier, requirements);
            
            self.emit(Event::TierRequirementsSet(TierRequirementsSet {
                tier,
            }));
        }

        fn set_progress_updater(ref self: ContractState, updater: ContractAddress, allowed: bool) {
            self._assert_only_owner();
            self.progress_updaters.write(updater, allowed);
            
            self.emit(Event::ProgressUpdaterSet(ProgressUpdaterSet {
                updater,
                allowed,
            }));
        }

        fn is_progress_updater(self: @ContractState, updater: ContractAddress) -> bool {
            self.progress_updaters.read(updater)
        }

        fn get_owner(self: @ContractState) -> ContractAddress {
            self.owner.read()
        }
    }

    #[generate_trait]
    pub impl InternalImpl of InternalTrait {
        fn _assert_only_progress_updater(self: @ContractState) {
            let caller = get_caller_address();
            assert(
                self.progress_updaters.read(caller) || caller == self.owner.read(),
                'Not authorized'
            );
        }

        fn _assert_only_owner(self: @ContractState) {
            let caller = get_caller_address();
            assert(caller == self.owner.read(), 'Only owner can call this');
        }

        fn _initialize_tier_requirements(ref self: ContractState) {
            let tier_2_req = TierRequirements {
                virtual_trades_count: 5,
                real_trades_count: 0,
                education_modules_completed: 3,
                trading_streak_days: 7,
                capital_preservation_pct: 90,
                risk_management_score: 50,
            };
            self.tier_requirements.write(2, tier_2_req);

            let tier_3_req = TierRequirements {
                virtual_trades_count: 15,
                real_trades_count: 10,
                education_modules_completed: 8,
                trading_streak_days: 30,
                capital_preservation_pct: 85,
                risk_management_score: 70,
            };
            self.tier_requirements.write(3, tier_3_req);

            let tier_4_req = TierRequirements {
                virtual_trades_count: 50,
                real_trades_count: 30,
                education_modules_completed: 15,
                trading_streak_days: 90,
                capital_preservation_pct: 80,
                risk_management_score: 85,
            };
            self.tier_requirements.write(4, tier_4_req);
        }

        fn _check_requirements_met(
            self: @ContractState,
            progress: UserProgress,
            requirements: TierRequirements
        ) -> bool {
            progress.virtual_trades_count >= requirements.virtual_trades_count &&
            progress.real_trades_count >= requirements.real_trades_count &&
            progress.education_modules_completed >= requirements.education_modules_completed &&
            progress.trading_streak_days >= requirements.trading_streak_days &&
            progress.capital_preservation_pct >= requirements.capital_preservation_pct &&
            progress.risk_management_score >= requirements.risk_management_score
        }

        fn _get_tier_name(self: @ContractState, tier: u8) -> felt252 {
            if tier == 1 {
                'Village'
            } else if tier == 2 {
                'Town'
            } else if tier == 3 {
                'City'
            } else if tier == 4 {
                'Kingdom'
            } else {
                'Unknown'
            }
        }
    }
}