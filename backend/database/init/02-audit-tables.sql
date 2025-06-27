-- Audit logging tables for Financial Kingdom Builder
-- This file creates tables for comprehensive audit logging

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Audit logs table for all system events
CREATE TABLE IF NOT EXISTS audit_logs (
    id VARCHAR(255) PRIMARY KEY,
    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    session_id VARCHAR(255),
    action VARCHAR(255) NOT NULL,
    resource VARCHAR(255) NOT NULL,
    resource_id VARCHAR(255),
    outcome VARCHAR(50) NOT NULL CHECK (outcome IN ('success', 'failure', 'error')),
    ip_address INET,
    user_agent TEXT,
    request_method VARCHAR(10),
    request_path VARCHAR(500),
    status_code INTEGER,
    error_message TEXT,
    metadata JSONB,
    severity VARCHAR(20) NOT NULL CHECK (severity IN ('low', 'medium', 'high', 'critical')),
    category VARCHAR(50) NOT NULL CHECK (category IN ('authentication', 'authorization', 'trading', 'data_access', 'system', 'security')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Security alerts table for real-time monitoring
CREATE TABLE IF NOT EXISTS security_alerts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    alert_type VARCHAR(100) NOT NULL,
    severity VARCHAR(20) NOT NULL CHECK (severity IN ('low', 'medium', 'high', 'critical')),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    source_ip INET,
    affected_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    alert_data JSONB,
    status VARCHAR(50) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'investigating', 'resolved', 'false_positive')),
    assigned_to VARCHAR(255),
    resolution_notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    resolved_at TIMESTAMPTZ
);

-- Failed login attempts tracking
CREATE TABLE IF NOT EXISTS failed_login_attempts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ip_address INET NOT NULL,
    email VARCHAR(255),
    user_agent TEXT,
    attempt_time TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    failure_reason VARCHAR(255),
    blocked_until TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Session audit table for detailed session tracking
CREATE TABLE IF NOT EXISTS session_audit (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id VARCHAR(255) NOT NULL,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    event_type VARCHAR(50) NOT NULL CHECK (event_type IN ('created', 'extended', 'invalidated', 'expired')),
    ip_address INET,
    user_agent TEXT,
    device_fingerprint VARCHAR(255),
    location_country VARCHAR(2),
    location_city VARCHAR(100),
    session_metadata JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Trading audit table for financial transaction tracking
CREATE TABLE IF NOT EXISTS trading_audit (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    order_id VARCHAR(255),
    trade_id VARCHAR(255),
    action VARCHAR(50) NOT NULL,
    symbol VARCHAR(20) NOT NULL,
    side VARCHAR(10) NOT NULL CHECK (side IN ('buy', 'sell')),
    quantity DECIMAL(20, 8) NOT NULL,
    price DECIMAL(20, 8),
    order_type VARCHAR(20) NOT NULL,
    status VARCHAR(50) NOT NULL,
    is_paper_trade BOOLEAN NOT NULL DEFAULT true,
    trade_value DECIMAL(20, 2),
    fees DECIMAL(20, 8),
    executed_at TIMESTAMPTZ,
    ip_address INET,
    user_agent TEXT,
    trade_metadata JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Data access audit for sensitive information tracking
CREATE TABLE IF NOT EXISTS data_access_audit (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    accessor_type VARCHAR(50) NOT NULL CHECK (accessor_type IN ('user', 'admin', 'system', 'api')),
    resource_type VARCHAR(100) NOT NULL,
    resource_id VARCHAR(255),
    action VARCHAR(50) NOT NULL,
    sensitive_fields TEXT[],
    access_reason VARCHAR(255),
    ip_address INET,
    user_agent TEXT,
    success BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Compliance audit table for regulatory tracking
CREATE TABLE IF NOT EXISTS compliance_audit (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    compliance_type VARCHAR(100) NOT NULL,
    requirement VARCHAR(255) NOT NULL,
    status VARCHAR(50) NOT NULL CHECK (status IN ('compliant', 'non_compliant', 'pending', 'exempt')),
    assessment_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    assessor VARCHAR(255),
    evidence_links TEXT[],
    remediation_notes TEXT,
    next_review_date TIMESTAMPTZ,
    metadata JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_audit_logs_timestamp ON audit_logs(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_category ON audit_logs(category);
CREATE INDEX IF NOT EXISTS idx_audit_logs_action ON audit_logs(action);
CREATE INDEX IF NOT EXISTS idx_audit_logs_ip_address ON audit_logs(ip_address);
CREATE INDEX IF NOT EXISTS idx_audit_logs_outcome ON audit_logs(outcome);
CREATE INDEX IF NOT EXISTS idx_audit_logs_severity ON audit_logs(severity);

-- Composite indexes for common queries
CREATE INDEX IF NOT EXISTS idx_audit_logs_user_category_time ON audit_logs(user_id, category, timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_audit_logs_ip_time ON audit_logs(ip_address, timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_audit_logs_action_outcome ON audit_logs(action, outcome);

-- Security alerts indexes
CREATE INDEX IF NOT EXISTS idx_security_alerts_type ON security_alerts(alert_type);
CREATE INDEX IF NOT EXISTS idx_security_alerts_severity ON security_alerts(severity);
CREATE INDEX IF NOT EXISTS idx_security_alerts_status ON security_alerts(status);
CREATE INDEX IF NOT EXISTS idx_security_alerts_created_at ON security_alerts(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_security_alerts_user_id ON security_alerts(affected_user_id);

-- Failed login attempts indexes
CREATE INDEX IF NOT EXISTS idx_failed_login_ip ON failed_login_attempts(ip_address, attempt_time DESC);
CREATE INDEX IF NOT EXISTS idx_failed_login_email ON failed_login_attempts(email, attempt_time DESC);
CREATE INDEX IF NOT EXISTS idx_failed_login_time ON failed_login_attempts(attempt_time DESC);

-- Session audit indexes
CREATE INDEX IF NOT EXISTS idx_session_audit_session_id ON session_audit(session_id);
CREATE INDEX IF NOT EXISTS idx_session_audit_user_id ON session_audit(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_session_audit_event_type ON session_audit(event_type);

-- Trading audit indexes
CREATE INDEX IF NOT EXISTS idx_trading_audit_user_id ON trading_audit(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_trading_audit_order_id ON trading_audit(order_id);
CREATE INDEX IF NOT EXISTS idx_trading_audit_symbol ON trading_audit(symbol, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_trading_audit_paper_trade ON trading_audit(is_paper_trade);
CREATE INDEX IF NOT EXISTS idx_trading_audit_executed_at ON trading_audit(executed_at DESC);

-- Data access audit indexes
CREATE INDEX IF NOT EXISTS idx_data_access_user_id ON data_access_audit(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_data_access_resource ON data_access_audit(resource_type, resource_id);
CREATE INDEX IF NOT EXISTS idx_data_access_action ON data_access_audit(action);

-- Compliance audit indexes
CREATE INDEX IF NOT EXISTS idx_compliance_audit_user_id ON compliance_audit(user_id);
CREATE INDEX IF NOT EXISTS idx_compliance_audit_type ON compliance_audit(compliance_type);
CREATE INDEX IF NOT EXISTS idx_compliance_audit_status ON compliance_audit(status);
CREATE INDEX IF NOT EXISTS idx_compliance_audit_review_date ON compliance_audit(next_review_date);

-- JSONB indexes for metadata searches
CREATE INDEX IF NOT EXISTS idx_audit_logs_metadata_gin ON audit_logs USING GIN (metadata);
CREATE INDEX IF NOT EXISTS idx_security_alerts_data_gin ON security_alerts USING GIN (alert_data);
CREATE INDEX IF NOT EXISTS idx_trading_audit_metadata_gin ON trading_audit USING GIN (trade_metadata);

-- Full text search indexes
CREATE INDEX IF NOT EXISTS idx_audit_logs_action_search ON audit_logs USING GIN (to_tsvector('english', action));
CREATE INDEX IF NOT EXISTS idx_security_alerts_description_search ON security_alerts USING GIN (to_tsvector('english', description));

-- Partitioning for audit_logs table (by month)
-- Note: This would typically be done in production for better performance with large datasets
-- CREATE TABLE audit_logs_y2024m01 PARTITION OF audit_logs
--     FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

-- Create triggers for automatic timestamp updates
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply trigger to tables with updated_at columns
CREATE TRIGGER update_security_alerts_updated_at BEFORE UPDATE ON security_alerts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_compliance_audit_updated_at BEFORE UPDATE ON compliance_audit
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create function for audit log cleanup
CREATE OR REPLACE FUNCTION cleanup_old_audit_logs(retention_days INTEGER DEFAULT 90)
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
    cutoff_date TIMESTAMPTZ;
BEGIN
    cutoff_date := NOW() - (retention_days || ' days')::INTERVAL;
    
    -- Delete old audit logs
    DELETE FROM audit_logs WHERE timestamp < cutoff_date;
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    
    -- Also cleanup related tables
    DELETE FROM failed_login_attempts WHERE attempt_time < cutoff_date;
    DELETE FROM session_audit WHERE created_at < cutoff_date;
    DELETE FROM data_access_audit WHERE created_at < cutoff_date;
    
    -- Keep trading audit and compliance audit longer (they might be needed for regulatory purposes)
    -- DELETE FROM trading_audit WHERE created_at < (NOW() - '7 years'::INTERVAL);
    
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- Create function for generating audit reports
CREATE OR REPLACE FUNCTION generate_audit_summary(
    start_date TIMESTAMPTZ,
    end_date TIMESTAMPTZ,
    user_id_filter UUID DEFAULT NULL
)
RETURNS TABLE (
    category VARCHAR(50),
    total_events BIGINT,
    success_events BIGINT,
    failure_events BIGINT,
    critical_events BIGINT,
    unique_users BIGINT,
    unique_ips BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        al.category,
        COUNT(*) as total_events,
        COUNT(*) FILTER (WHERE al.outcome = 'success') as success_events,
        COUNT(*) FILTER (WHERE al.outcome = 'failure') as failure_events,
        COUNT(*) FILTER (WHERE al.severity = 'critical') as critical_events,
        COUNT(DISTINCT al.user_id) as unique_users,
        COUNT(DISTINCT al.ip_address) as unique_ips
    FROM audit_logs al
    WHERE al.timestamp >= start_date 
        AND al.timestamp <= end_date
        AND (user_id_filter IS NULL OR al.user_id = user_id_filter)
    GROUP BY al.category
    ORDER BY total_events DESC;
END;
$$ LANGUAGE plpgsql;

-- Create security monitoring views
CREATE OR REPLACE VIEW security_dashboard AS
SELECT 
    DATE_TRUNC('hour', timestamp) as hour,
    category,
    COUNT(*) as event_count,
    COUNT(*) FILTER (WHERE outcome = 'failure') as failure_count,
    COUNT(DISTINCT user_id) as affected_users,
    COUNT(DISTINCT ip_address) as unique_ips
FROM audit_logs 
WHERE timestamp >= NOW() - INTERVAL '24 hours'
GROUP BY DATE_TRUNC('hour', timestamp), category
ORDER BY hour DESC, event_count DESC;

CREATE OR REPLACE VIEW failed_login_summary AS
SELECT 
    ip_address,
    COUNT(*) as attempt_count,
    COUNT(DISTINCT email) as unique_emails,
    MIN(attempt_time) as first_attempt,
    MAX(attempt_time) as last_attempt,
    CASE 
        WHEN COUNT(*) >= 10 THEN 'high_risk'
        WHEN COUNT(*) >= 5 THEN 'medium_risk'
        ELSE 'low_risk'
    END as risk_level
FROM failed_login_attempts 
WHERE attempt_time >= NOW() - INTERVAL '1 hour'
GROUP BY ip_address
HAVING COUNT(*) >= 3
ORDER BY attempt_count DESC;

-- Grant permissions (adjust as needed for your user roles)
-- GRANT SELECT, INSERT ON audit_logs TO financial_kingdom_app;
-- GRANT SELECT, INSERT ON security_alerts TO financial_kingdom_app;
-- GRANT SELECT, INSERT ON failed_login_attempts TO financial_kingdom_app;
-- GRANT SELECT, INSERT ON session_audit TO financial_kingdom_app;
-- GRANT SELECT, INSERT ON trading_audit TO financial_kingdom_app;
-- GRANT SELECT, INSERT ON data_access_audit TO financial_kingdom_app;
-- GRANT SELECT, INSERT, UPDATE ON compliance_audit TO financial_kingdom_app;

-- Insert some sample audit events for testing (optional)
-- This can be useful for development and testing
INSERT INTO audit_logs (
    id, user_id, action, resource, outcome, ip_address, severity, category, metadata
) VALUES 
(
    'audit_' || extract(epoch from now()) || '_sample1',
    (SELECT id FROM users LIMIT 1),
    'system_initialization',
    'audit_system',
    'success',
    '127.0.0.1',
    'low',
    'system',
    '{"message": "Audit system initialized successfully"}'
) ON CONFLICT (id) DO NOTHING;

-- Add comment for documentation
COMMENT ON TABLE audit_logs IS 'Comprehensive audit trail for all system events including authentication, trading, and data access';
COMMENT ON TABLE security_alerts IS 'Real-time security alerts for suspicious activities and threshold breaches';
COMMENT ON TABLE failed_login_attempts IS 'Tracking of failed authentication attempts for security monitoring';
COMMENT ON TABLE session_audit IS 'Detailed session lifecycle tracking for user activity monitoring';
COMMENT ON TABLE trading_audit IS 'Financial transaction audit trail for regulatory compliance';
COMMENT ON TABLE data_access_audit IS 'Sensitive data access tracking for privacy and security compliance';
COMMENT ON TABLE compliance_audit IS 'Regulatory compliance tracking and assessment records';