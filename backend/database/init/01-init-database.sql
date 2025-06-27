-- PostgreSQL Database Initialization Script
-- Financial Kingdom Builder - User Profiles Schema

-- Enable TimescaleDB extension
CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;

-- Create users table for authentication and basic profile info
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    date_of_birth DATE,
    country_code VARCHAR(2),
    phone_number VARCHAR(20),
    profile_picture_url TEXT,
    bio TEXT,
    is_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    last_login_at TIMESTAMPTZ,
    email_verified_at TIMESTAMPTZ,
    phone_verified_at TIMESTAMPTZ
);

-- Create user_sessions table for session management
CREATE TABLE IF NOT EXISTS user_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    session_token VARCHAR(255) UNIQUE NOT NULL,
    refresh_token VARCHAR(255) UNIQUE NOT NULL,
    device_id VARCHAR(255),
    device_type VARCHAR(50),
    ip_address INET,
    user_agent TEXT,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    last_used_at TIMESTAMPTZ DEFAULT NOW(),
    is_active BOOLEAN DEFAULT TRUE
);

-- Create kingdom_state table for user progression
CREATE TABLE IF NOT EXISTS kingdom_state (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    current_tier INTEGER DEFAULT 1 CHECK (current_tier >= 1 AND current_tier <= 4),
    kingdom_level INTEGER DEFAULT 1 CHECK (kingdom_level >= 1),
    total_xp BIGINT DEFAULT 0 CHECK (total_xp >= 0),
    current_streak INTEGER DEFAULT 0 CHECK (current_streak >= 0),
    longest_streak INTEGER DEFAULT 0 CHECK (longest_streak >= 0),
    gems_count INTEGER DEFAULT 0 CHECK (gems_count >= 0),
    hearts_count INTEGER DEFAULT 5 CHECK (hearts_count >= 0),
    gold_balance DECIMAL(15,2) DEFAULT 0.00 CHECK (gold_balance >= 0),
    virtual_balance DECIMAL(15,2) DEFAULT 10000.00 CHECK (virtual_balance >= 0),
    real_trading_enabled BOOLEAN DEFAULT FALSE,
    risk_tolerance VARCHAR(20) DEFAULT 'conservative' CHECK (risk_tolerance IN ('conservative', 'moderate', 'aggressive')),
    kingdom_name VARCHAR(100),
    kingdom_theme VARCHAR(50) DEFAULT 'medieval',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id)
);

-- Create educational_progress table
CREATE TABLE IF NOT EXISTS educational_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    module_id VARCHAR(100) NOT NULL,
    module_category VARCHAR(50) NOT NULL,
    completion_percentage INTEGER DEFAULT 0 CHECK (completion_percentage >= 0 AND completion_percentage <= 100),
    is_completed BOOLEAN DEFAULT FALSE,
    quiz_score INTEGER CHECK (quiz_score >= 0 AND quiz_score <= 100),
    attempts_count INTEGER DEFAULT 0 CHECK (attempts_count >= 0),
    time_spent_minutes INTEGER DEFAULT 0 CHECK (time_spent_minutes >= 0),
    started_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    last_accessed_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, module_id)
);

-- Create achievements table
CREATE TABLE IF NOT EXISTS achievements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(100) UNIQUE NOT NULL,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    category VARCHAR(50) NOT NULL,
    tier_requirement INTEGER DEFAULT 1 CHECK (tier_requirement >= 1 AND tier_requirement <= 4),
    xp_reward INTEGER DEFAULT 0 CHECK (xp_reward >= 0),
    gems_reward INTEGER DEFAULT 0 CHECK (gems_reward >= 0),
    icon_name VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create user_achievements table for tracking earned achievements
CREATE TABLE IF NOT EXISTS user_achievements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    achievement_id UUID NOT NULL REFERENCES achievements(id) ON DELETE CASCADE,
    earned_at TIMESTAMPTZ DEFAULT NOW(),
    progress_data JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, achievement_id)
);

-- Create trading_accounts table for real trading integration
CREATE TABLE IF NOT EXISTS trading_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    provider VARCHAR(50) NOT NULL,
    account_id VARCHAR(255) NOT NULL,
    account_type VARCHAR(50) DEFAULT 'live',
    is_active BOOLEAN DEFAULT TRUE,
    kyc_status VARCHAR(20) DEFAULT 'pending' CHECK (kyc_status IN ('pending', 'approved', 'rejected', 'expired')),
    kyc_completed_at TIMESTAMPTZ,
    api_key_encrypted TEXT,
    api_secret_encrypted TEXT,
    sandbox_mode BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, provider, account_id)
);

-- Create portfolio_snapshots table (TimescaleDB hypertable for time-series data)
CREATE TABLE IF NOT EXISTS portfolio_snapshots (
    id UUID DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    snapshot_time TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    total_value DECIMAL(15,2) NOT NULL,
    virtual_value DECIMAL(15,2) DEFAULT 0.00,
    real_value DECIMAL(15,2) DEFAULT 0.00,
    day_change DECIMAL(15,2) DEFAULT 0.00,
    day_change_percentage DECIMAL(8,4) DEFAULT 0.00,
    positions_data JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Convert portfolio_snapshots to hypertable for time-series optimization
SELECT create_hypertable('portfolio_snapshots', 'snapshot_time', if_not_exists => TRUE);

-- Create social_connections table for friend system
CREATE TABLE IF NOT EXISTS social_connections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    requester_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    addressee_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'blocked', 'declined')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(requester_id, addressee_id),
    CHECK (requester_id != addressee_id)
);

-- Create user_preferences table for app settings
CREATE TABLE IF NOT EXISTS user_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    notifications_enabled BOOLEAN DEFAULT TRUE,
    push_notifications BOOLEAN DEFAULT TRUE,
    email_notifications BOOLEAN DEFAULT TRUE,
    trading_alerts BOOLEAN DEFAULT TRUE,
    educational_reminders BOOLEAN DEFAULT TRUE,
    social_notifications BOOLEAN DEFAULT TRUE,
    theme VARCHAR(20) DEFAULT 'light' CHECK (theme IN ('light', 'dark', 'auto')),
    language VARCHAR(10) DEFAULT 'en',
    timezone VARCHAR(50) DEFAULT 'UTC',
    currency VARCHAR(3) DEFAULT 'USD',
    privacy_level VARCHAR(20) DEFAULT 'public' CHECK (privacy_level IN ('public', 'friends', 'private')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id)
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_active ON users(is_active) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_user_sessions_user_id ON user_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_user_sessions_token ON user_sessions(session_token);
CREATE INDEX IF NOT EXISTS idx_user_sessions_active ON user_sessions(is_active) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_kingdom_state_user_id ON kingdom_state(user_id);
CREATE INDEX IF NOT EXISTS idx_kingdom_state_tier ON kingdom_state(current_tier);
CREATE INDEX IF NOT EXISTS idx_educational_progress_user_id ON educational_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_educational_progress_module ON educational_progress(module_id);
CREATE INDEX IF NOT EXISTS idx_educational_progress_completed ON educational_progress(is_completed);
CREATE INDEX IF NOT EXISTS idx_user_achievements_user_id ON user_achievements(user_id);
CREATE INDEX IF NOT EXISTS idx_user_achievements_achievement_id ON user_achievements(achievement_id);
CREATE INDEX IF NOT EXISTS idx_trading_accounts_user_id ON trading_accounts(user_id);
CREATE INDEX IF NOT EXISTS idx_trading_accounts_active ON trading_accounts(is_active) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_portfolio_snapshots_user_time ON portfolio_snapshots(user_id, snapshot_time DESC);
CREATE INDEX IF NOT EXISTS idx_social_connections_requester ON social_connections(requester_id);
CREATE INDEX IF NOT EXISTS idx_social_connections_addressee ON social_connections(addressee_id);
CREATE INDEX IF NOT EXISTS idx_social_connections_status ON social_connections(status);

-- Create triggers for updating timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_kingdom_state_updated_at BEFORE UPDATE ON kingdom_state FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_educational_progress_updated_at BEFORE UPDATE ON educational_progress FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_achievements_updated_at BEFORE UPDATE ON achievements FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_trading_accounts_updated_at BEFORE UPDATE ON trading_accounts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_social_connections_updated_at BEFORE UPDATE ON social_connections FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_preferences_updated_at BEFORE UPDATE ON user_preferences FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert default achievements
INSERT INTO achievements (code, name, description, category, tier_requirement, xp_reward, gems_reward, icon_name) VALUES
('FIRST_LOGIN', 'Welcome Adventurer', 'Log in for the first time', 'onboarding', 1, 100, 10, 'welcome'),
('FIRST_LESSON', 'Scholar', 'Complete your first educational module', 'education', 1, 200, 20, 'book'),
('FIRST_TRADE', 'Trader', 'Execute your first virtual trade', 'trading', 1, 300, 30, 'trade'),
('WEEK_STREAK', 'Consistent Learner', 'Maintain a 7-day learning streak', 'engagement', 1, 500, 50, 'streak'),
('MONTH_STREAK', 'Dedicated Student', 'Maintain a 30-day learning streak', 'engagement', 2, 1500, 150, 'calendar'),
('TIER_2_UNLOCK', 'Town Builder', 'Advance to Tier 2 (Town Development)', 'progression', 2, 1000, 100, 'town'),
('TIER_3_UNLOCK', 'City Planner', 'Advance to Tier 3 (City Expansion)', 'progression', 3, 2000, 200, 'city'),
('TIER_4_UNLOCK', 'Kingdom Ruler', 'Advance to Tier 4 (Kingdom Mastery)', 'progression', 4, 5000, 500, 'crown'),
('RISK_MASTER', 'Risk Manager', 'Complete all risk management modules', 'education', 2, 1000, 100, 'shield'),
('SOCIAL_BUTTERFLY', 'Community Member', 'Connect with 10 fellow traders', 'social', 1, 500, 50, 'friends'),
('PERFECT_QUIZ', 'Quiz Master', 'Score 100% on 5 different quizzes', 'education', 2, 750, 75, 'star'),
('PORTFOLIO_PROTECTOR', 'Portfolio Guardian', 'Maintain 90%+ of capital for 30 days', 'trading', 2, 1200, 120, 'guard')
ON CONFLICT (code) DO NOTHING;

-- Create materialized view for leaderboards
CREATE MATERIALIZED VIEW IF NOT EXISTS leaderboard_view AS
SELECT 
    u.id,
    u.username,
    u.profile_picture_url,
    ks.total_xp,
    ks.current_tier,
    ks.kingdom_level,
    ks.current_streak,
    ks.longest_streak,
    COUNT(ua.id) as achievements_count,
    RANK() OVER (ORDER BY ks.total_xp DESC) as xp_rank,
    RANK() OVER (ORDER BY ks.current_streak DESC) as streak_rank
FROM users u
JOIN kingdom_state ks ON u.id = ks.user_id
LEFT JOIN user_achievements ua ON u.id = ua.user_id
WHERE u.is_active = TRUE
GROUP BY u.id, u.username, u.profile_picture_url, ks.total_xp, ks.current_tier, ks.kingdom_level, ks.current_streak, ks.longest_streak;

-- Create index on materialized view
CREATE UNIQUE INDEX IF NOT EXISTS idx_leaderboard_view_id ON leaderboard_view(id);
CREATE INDEX IF NOT EXISTS idx_leaderboard_view_xp_rank ON leaderboard_view(xp_rank);
CREATE INDEX IF NOT EXISTS idx_leaderboard_view_streak_rank ON leaderboard_view(streak_rank);

-- Create function to refresh leaderboard
CREATE OR REPLACE FUNCTION refresh_leaderboard()
RETURNS void AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY leaderboard_view;
END;
$$ LANGUAGE plpgsql;

-- Grant permissions to application user
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO financial_kingdom;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO financial_kingdom;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO financial_kingdom;

-- Create read-only user for analytics
CREATE USER financial_kingdom_readonly WITH PASSWORD 'financial_kingdom_readonly_password';
GRANT CONNECT ON DATABASE financial_kingdom TO financial_kingdom_readonly;
GRANT USAGE ON SCHEMA public TO financial_kingdom_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO financial_kingdom_readonly;

COMMIT;