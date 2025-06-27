use starknet::ContractAddress;

#[derive(Drop, Copy, Serde, starknet::Store)]
pub struct UserLimits {
    pub daily_limit: u256,
    pub per_transaction_limit: u256,
    pub daily_spent: u256,
    pub last_reset_day: u64,
    pub is_whitelisted: bool,
}

#[derive(Drop, Copy, Serde, starknet::Store)]
pub struct PaymasterConfig {
    pub is_enabled: bool,
    pub default_daily_limit: u256,
    pub default_tx_limit: u256,
    pub minimum_balance: u256,
}

#[starknet::interface]
pub trait IPaymaster<TContractState> {
    fn deposit(ref self: TContractState, amount: u256);
    fn withdraw(ref self: TContractState, amount: u256);
    fn sponsor_transaction(
        ref self: TContractState,
        user: ContractAddress,
        gas_amount: u256
    ) -> bool;
    fn set_user_limits(
        ref self: TContractState,
        user: ContractAddress,
        daily_limit: u256,
        tx_limit: u256
    );
    fn add_to_whitelist(ref self: TContractState, user: ContractAddress);
    fn remove_from_whitelist(ref self: TContractState, user: ContractAddress);
    fn set_paymaster_enabled(ref self: TContractState, enabled: bool);
    fn update_config(
        ref self: TContractState,
        default_daily_limit: u256,
        default_tx_limit: u256,
        minimum_balance: u256
    );
    fn get_balance(self: @TContractState) -> u256;
    fn get_user_limits(self: @TContractState, user: ContractAddress) -> UserLimits;
    fn get_config(self: @TContractState) -> PaymasterConfig;
    fn is_transaction_sponsored(
        self: @TContractState,
        user: ContractAddress,
        gas_amount: u256
    ) -> bool;
    fn get_remaining_daily_limit(self: @TContractState, user: ContractAddress) -> u256;
    fn get_owner(self: @TContractState) -> ContractAddress;
}

#[starknet::contract]
pub mod Paymaster {
    use starknet::ContractAddress;
    use starknet::storage::{
        Map, StoragePointerReadAccess, StoragePointerWriteAccess, 
        StorageMapReadAccess, StorageMapWriteAccess
    };
    use starknet::{get_caller_address, get_block_timestamp};
    use super::{UserLimits, PaymasterConfig};

    #[storage]
    pub struct Storage {
        owner: ContractAddress,
        balance: u256,
        user_limits: Map<ContractAddress, UserLimits>,
        paymaster_config: PaymasterConfig,
        total_sponsored: u256,
        transaction_count: u256,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        Deposited: Deposited,
        Withdrawn: Withdrawn,
        TransactionSponsored: TransactionSponsored,
        UserLimitsSet: UserLimitsSet,
        UserWhitelisted: UserWhitelisted,
        UserRemovedFromWhitelist: UserRemovedFromWhitelist,
        PaymasterEnabled: PaymasterEnabled,
        PaymasterDisabled: PaymasterDisabled,
        ConfigUpdated: ConfigUpdated,
        SponsorshipDenied: SponsorshipDenied,
    }

    #[derive(Drop, starknet::Event)]
    pub struct Deposited {
        pub depositor: ContractAddress,
        pub amount: u256,
        pub new_balance: u256,
        pub timestamp: u64,
    }

    #[derive(Drop, starknet::Event)]
    pub struct Withdrawn {
        pub owner: ContractAddress,
        pub amount: u256,
        pub new_balance: u256,
        pub timestamp: u64,
    }

    #[derive(Drop, starknet::Event)]
    pub struct TransactionSponsored {
        pub user: ContractAddress,
        pub gas_amount: u256,
        pub remaining_balance: u256,
        pub remaining_daily_limit: u256,
        pub timestamp: u64,
    }

    #[derive(Drop, starknet::Event)]
    pub struct UserLimitsSet {
        pub user: ContractAddress,
        pub daily_limit: u256,
        pub tx_limit: u256,
    }

    #[derive(Drop, starknet::Event)]
    pub struct UserWhitelisted {
        pub user: ContractAddress,
        pub timestamp: u64,
    }

    #[derive(Drop, starknet::Event)]
    pub struct UserRemovedFromWhitelist {
        pub user: ContractAddress,
        pub timestamp: u64,
    }

    #[derive(Drop, starknet::Event)]
    pub struct PaymasterEnabled {
        pub timestamp: u64,
    }

    #[derive(Drop, starknet::Event)]
    pub struct PaymasterDisabled {
        pub timestamp: u64,
    }

    #[derive(Drop, starknet::Event)]
    pub struct ConfigUpdated {
        pub default_daily_limit: u256,
        pub default_tx_limit: u256,
        pub minimum_balance: u256,
    }

    #[derive(Drop, starknet::Event)]
    pub struct SponsorshipDenied {
        pub user: ContractAddress,
        pub gas_amount: u256,
        pub reason: felt252,
        pub timestamp: u64,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        owner: ContractAddress,
        default_daily_limit: u256,
        default_tx_limit: u256,
        minimum_balance: u256
    ) {
        self.owner.write(owner);
        
        let config = PaymasterConfig {
            is_enabled: true,
            default_daily_limit,
            default_tx_limit,
            minimum_balance,
        };
        
        self.paymaster_config.write(config);
        self.balance.write(0);
        self.total_sponsored.write(0);
        self.transaction_count.write(0);
    }

    #[abi(embed_v0)]
    impl PaymasterImpl of super::IPaymaster<ContractState> {
        fn deposit(ref self: ContractState, amount: u256) {
            let caller = get_caller_address();
            
            let new_balance = self.balance.read() + amount;
            self.balance.write(new_balance);
            
            self.emit(Event::Deposited(Deposited {
                depositor: caller,
                amount,
                new_balance,
                timestamp: get_block_timestamp(),
            }));
        }

        fn withdraw(ref self: ContractState, amount: u256) {
            self._assert_only_owner();
            
            let current_balance = self.balance.read();
            assert(current_balance >= amount, 'Insufficient balance');
            
            let new_balance = current_balance - amount;
            self.balance.write(new_balance);
            
            self.emit(Event::Withdrawn(Withdrawn {
                owner: get_caller_address(),
                amount,
                new_balance,
                timestamp: get_block_timestamp(),
            }));
        }

        fn sponsor_transaction(
            ref self: ContractState,
            user: ContractAddress,
            gas_amount: u256
        ) -> bool {
            let config = self.paymaster_config.read();
            
            if !config.is_enabled {
                self.emit(Event::SponsorshipDenied(SponsorshipDenied {
                    user,
                    gas_amount,
                    reason: 'Paymaster disabled',
                    timestamp: get_block_timestamp(),
                }));
                return false;
            }
            
            let current_balance = self.balance.read();
            if current_balance < gas_amount || current_balance < config.minimum_balance {
                self.emit(Event::SponsorshipDenied(SponsorshipDenied {
                    user,
                    gas_amount,
                    reason: 'Insufficient paymaster balance',
                    timestamp: get_block_timestamp(),
                }));
                return false;
            }
            
            let mut user_limits = self._get_or_create_user_limits(user);
            
            if !user_limits.is_whitelisted {
                self.emit(Event::SponsorshipDenied(SponsorshipDenied {
                    user,
                    gas_amount,
                    reason: 'User not whitelisted',
                    timestamp: get_block_timestamp(),
                }));
                return false;
            }
            
            self._reset_daily_limits_if_needed(ref user_limits);
            
            if gas_amount > user_limits.per_transaction_limit {
                self.emit(Event::SponsorshipDenied(SponsorshipDenied {
                    user,
                    gas_amount,
                    reason: 'Exceeds transaction limit',
                    timestamp: get_block_timestamp(),
                }));
                return false;
            }
            
            if user_limits.daily_spent + gas_amount > user_limits.daily_limit {
                self.emit(Event::SponsorshipDenied(SponsorshipDenied {
                    user,
                    gas_amount,
                    reason: 'Exceeds daily limit',
                    timestamp: get_block_timestamp(),
                }));
                return false;
            }
            
            user_limits.daily_spent += gas_amount;
            self.user_limits.write(user, user_limits);
            
            let new_balance = current_balance - gas_amount;
            self.balance.write(new_balance);
            
            let new_total = self.total_sponsored.read() + gas_amount;
            self.total_sponsored.write(new_total);
            
            let new_tx_count = self.transaction_count.read() + 1;
            self.transaction_count.write(new_tx_count);
            
            self.emit(Event::TransactionSponsored(TransactionSponsored {
                user,
                gas_amount,
                remaining_balance: new_balance,
                remaining_daily_limit: user_limits.daily_limit - user_limits.daily_spent,
                timestamp: get_block_timestamp(),
            }));
            
            true
        }

        fn set_user_limits(
            ref self: ContractState,
            user: ContractAddress,
            daily_limit: u256,
            tx_limit: u256
        ) {
            self._assert_only_owner();
            
            let mut user_limits = self._get_or_create_user_limits(user);
            user_limits.daily_limit = daily_limit;
            user_limits.per_transaction_limit = tx_limit;
            
            self.user_limits.write(user, user_limits);
            
            self.emit(Event::UserLimitsSet(UserLimitsSet {
                user,
                daily_limit,
                tx_limit,
            }));
        }

        fn add_to_whitelist(ref self: ContractState, user: ContractAddress) {
            self._assert_only_owner();
            
            let mut user_limits = self._get_or_create_user_limits(user);
            user_limits.is_whitelisted = true;
            
            self.user_limits.write(user, user_limits);
            
            self.emit(Event::UserWhitelisted(UserWhitelisted {
                user,
                timestamp: get_block_timestamp(),
            }));
        }

        fn remove_from_whitelist(ref self: ContractState, user: ContractAddress) {
            self._assert_only_owner();
            
            let mut user_limits = self._get_or_create_user_limits(user);
            user_limits.is_whitelisted = false;
            
            self.user_limits.write(user, user_limits);
            
            self.emit(Event::UserRemovedFromWhitelist(UserRemovedFromWhitelist {
                user,
                timestamp: get_block_timestamp(),
            }));
        }

        fn set_paymaster_enabled(ref self: ContractState, enabled: bool) {
            self._assert_only_owner();
            
            let mut config = self.paymaster_config.read();
            config.is_enabled = enabled;
            self.paymaster_config.write(config);
            
            if enabled {
                self.emit(Event::PaymasterEnabled(PaymasterEnabled {
                    timestamp: get_block_timestamp(),
                }));
            } else {
                self.emit(Event::PaymasterDisabled(PaymasterDisabled {
                    timestamp: get_block_timestamp(),
                }));
            }
        }

        fn update_config(
            ref self: ContractState,
            default_daily_limit: u256,
            default_tx_limit: u256,
            minimum_balance: u256
        ) {
            self._assert_only_owner();
            
            let mut config = self.paymaster_config.read();
            config.default_daily_limit = default_daily_limit;
            config.default_tx_limit = default_tx_limit;
            config.minimum_balance = minimum_balance;
            
            self.paymaster_config.write(config);
            
            self.emit(Event::ConfigUpdated(ConfigUpdated {
                default_daily_limit,
                default_tx_limit,
                minimum_balance,
            }));
        }

        fn get_balance(self: @ContractState) -> u256 {
            self.balance.read()
        }

        fn get_user_limits(self: @ContractState, user: ContractAddress) -> UserLimits {
            self.user_limits.read(user)
        }

        fn get_config(self: @ContractState) -> PaymasterConfig {
            self.paymaster_config.read()
        }

        fn is_transaction_sponsored(
            self: @ContractState,
            user: ContractAddress,
            gas_amount: u256
        ) -> bool {
            let config = self.paymaster_config.read();
            
            if !config.is_enabled {
                return false;
            }
            
            let current_balance = self.balance.read();
            if current_balance < gas_amount || current_balance < config.minimum_balance {
                return false;
            }
            
            let mut user_limits = self.user_limits.read(user);
            if user_limits.daily_limit == 0 {
                return false;
            }
            
            if !user_limits.is_whitelisted {
                return false;
            }
            
            let current_day = get_block_timestamp() / 86400;
            if user_limits.last_reset_day != current_day {
                return gas_amount <= user_limits.per_transaction_limit && gas_amount <= user_limits.daily_limit;
            }
            
            gas_amount <= user_limits.per_transaction_limit && 
            user_limits.daily_spent + gas_amount <= user_limits.daily_limit
        }

        fn get_remaining_daily_limit(self: @ContractState, user: ContractAddress) -> u256 {
            let mut user_limits = self.user_limits.read(user);
            let current_day = get_block_timestamp() / 86400;
            
            if user_limits.last_reset_day != current_day {
                return user_limits.daily_limit;
            }
            
            if user_limits.daily_spent >= user_limits.daily_limit {
                return 0;
            }
            
            user_limits.daily_limit - user_limits.daily_spent
        }

        fn get_owner(self: @ContractState) -> ContractAddress {
            self.owner.read()
        }
    }

    #[generate_trait]
    pub impl InternalImpl of InternalTrait {
        fn _assert_only_owner(self: @ContractState) {
            let caller = get_caller_address();
            let owner = self.owner.read();
            assert(caller == owner, 'Only owner can call this');
        }

        fn _get_or_create_user_limits(self: @ContractState, user: ContractAddress) -> UserLimits {
            let mut user_limits = self.user_limits.read(user);
            
            if user_limits.daily_limit == 0 {
                let config = self.paymaster_config.read();
                user_limits = UserLimits {
                    daily_limit: config.default_daily_limit,
                    per_transaction_limit: config.default_tx_limit,
                    daily_spent: 0,
                    last_reset_day: get_block_timestamp() / 86400,
                    is_whitelisted: false,
                };
            }
            
            user_limits
        }

        fn _reset_daily_limits_if_needed(self: @ContractState, ref user_limits: UserLimits) {
            let current_day = get_block_timestamp() / 86400;
            
            if user_limits.last_reset_day != current_day {
                user_limits.daily_spent = 0;
                user_limits.last_reset_day = current_day;
            }
        }
    }
}