-- Education Content Management System Schema
-- Migration 004: Comprehensive educational content, versioning, and analytics

-- Educational Categories
CREATE TABLE education_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    icon VARCHAR(50),
    color VARCHAR(7), -- Hex color code
    order_index INTEGER NOT NULL DEFAULT 0,
    parent_id UUID REFERENCES education_categories(id),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Education Modules with versioning and analytics
CREATE TABLE education_modules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    tier INTEGER NOT NULL CHECK (tier BETWEEN 1 AND 4),
    category VARCHAR(50) NOT NULL CHECK (category IN ('financial-literacy', 'risk-management', 'technical-analysis', 'trading-psychology')),
    difficulty VARCHAR(20) NOT NULL CHECK (difficulty IN ('beginner', 'intermediate', 'advanced')),
    estimated_duration INTEGER NOT NULL, -- minutes
    xp_reward INTEGER NOT NULL DEFAULT 0,
    prerequisites JSONB DEFAULT '[]', -- Array of module IDs
    version INTEGER NOT NULL DEFAULT 1,
    status VARCHAR(20) NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published', 'archived')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID NOT NULL REFERENCES users(id),
    published_at TIMESTAMP WITH TIME ZONE,
    scheduled_at TIMESTAMP WITH TIME ZONE,
    tags JSONB DEFAULT '[]', -- Array of tag strings
    
    -- Denormalized analytics for performance
    total_views INTEGER DEFAULT 0,
    completion_rate DECIMAL(5,2) DEFAULT 0.00,
    average_score DECIMAL(5,2) DEFAULT 0.00,
    average_time_spent INTEGER DEFAULT 0, -- minutes
    retry_rate DECIMAL(5,2) DEFAULT 0.00,
    analytics_updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Module Content (text, video, quiz, interactive elements)
CREATE TABLE module_content (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    module_id UUID NOT NULL REFERENCES education_modules(id) ON DELETE CASCADE,
    type VARCHAR(20) NOT NULL CHECK (type IN ('text', 'video', 'quiz', 'interactive', 'image')),
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    duration INTEGER, -- minutes
    order_index INTEGER NOT NULL,
    
    -- Metadata stored as JSONB for flexibility
    metadata JSONB DEFAULT '{}', -- videoUrl, imageUrl, quizConfig, etc.
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Quiz Questions
CREATE TABLE quiz_questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    content_id UUID NOT NULL REFERENCES module_content(id) ON DELETE CASCADE,
    type VARCHAR(20) NOT NULL CHECK (type IN ('multiple-choice', 'true-false', 'fill-blank', 'drag-drop')),
    question TEXT NOT NULL,
    options JSONB, -- Array of option strings for multiple choice
    correct_answer JSONB NOT NULL, -- String or array of strings
    explanation TEXT,
    points INTEGER NOT NULL DEFAULT 1,
    order_index INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User Progress Tracking
CREATE TABLE user_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    module_id UUID NOT NULL REFERENCES education_modules(id),
    progress INTEGER NOT NULL DEFAULT 0 CHECK (progress BETWEEN 0 AND 100),
    completed BOOLEAN DEFAULT false,
    last_accessed TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    time_spent INTEGER DEFAULT 0, -- minutes
    
    UNIQUE(user_id, module_id)
);

-- Content-level progress tracking
CREATE TABLE content_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    content_id UUID NOT NULL REFERENCES module_content(id),
    completed BOOLEAN DEFAULT false,
    time_spent INTEGER DEFAULT 0, -- minutes
    last_accessed TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(user_id, content_id)
);

-- Quiz Attempts
CREATE TABLE quiz_attempts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    module_id UUID NOT NULL REFERENCES education_modules(id),
    content_id UUID NOT NULL REFERENCES module_content(id),
    attempt_number INTEGER NOT NULL DEFAULT 1,
    score INTEGER NOT NULL DEFAULT 0,
    max_score INTEGER NOT NULL,
    passed BOOLEAN NOT NULL DEFAULT false,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    time_spent INTEGER DEFAULT 0, -- seconds
    
    UNIQUE(user_id, content_id, attempt_number)
);

-- Quiz Answers
CREATE TABLE quiz_answers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    attempt_id UUID NOT NULL REFERENCES quiz_attempts(id) ON DELETE CASCADE,
    question_id UUID NOT NULL REFERENCES quiz_questions(id),
    answer JSONB NOT NULL, -- User's answer(s)
    is_correct BOOLEAN NOT NULL DEFAULT false,
    points INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Content Versioning for A/B Testing and Rollbacks
CREATE TABLE content_versions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    module_id UUID NOT NULL REFERENCES education_modules(id),
    version INTEGER NOT NULL,
    changes JSONB NOT NULL, -- Array of change descriptions
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    content_snapshot JSONB NOT NULL, -- Full content at this version
    
    UNIQUE(module_id, version)
);

-- A/B Testing Framework
CREATE TABLE ab_test_configs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(200) NOT NULL,
    description TEXT,
    module_id UUID NOT NULL REFERENCES education_modules(id),
    traffic_split INTEGER NOT NULL DEFAULT 50 CHECK (traffic_split BETWEEN 1 AND 100),
    start_date TIMESTAMP WITH TIME ZONE NOT NULL,
    end_date TIMESTAMP WITH TIME ZONE,
    status VARCHAR(20) NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'running', 'completed', 'paused')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Metrics stored as JSONB for flexibility
    metrics JSONB DEFAULT '{}'
);

-- A/B Test Variants
CREATE TABLE ab_test_variants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    test_id UUID NOT NULL REFERENCES ab_test_configs(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    content JSONB NOT NULL, -- Modified content for this variant
    traffic_percentage INTEGER NOT NULL CHECK (traffic_percentage BETWEEN 0 AND 100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- A/B Test Participation
CREATE TABLE ab_test_participation (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    test_id UUID NOT NULL REFERENCES ab_test_configs(id),
    variant_id UUID NOT NULL REFERENCES ab_test_variants(id),
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(user_id, test_id)
);

-- Analytics aggregation tables for performance
CREATE TABLE module_analytics_daily (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    module_id UUID NOT NULL REFERENCES education_modules(id),
    date DATE NOT NULL,
    total_views INTEGER DEFAULT 0,
    total_completions INTEGER DEFAULT 0,
    total_time_spent INTEGER DEFAULT 0, -- minutes
    average_score DECIMAL(5,2) DEFAULT 0.00,
    unique_users INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(module_id, date)
);

-- Content performance tracking
CREATE TABLE content_analytics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    content_id UUID NOT NULL REFERENCES module_content(id),
    drop_off_rate DECIMAL(5,2) DEFAULT 0.00,
    average_time_before_drop_off INTEGER DEFAULT 0, -- seconds
    total_interactions INTEGER DEFAULT 0,
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(content_id)
);

-- Indexes for performance
CREATE INDEX idx_education_modules_category ON education_modules(category);
CREATE INDEX idx_education_modules_tier ON education_modules(tier);
CREATE INDEX idx_education_modules_status ON education_modules(status);
CREATE INDEX idx_education_modules_published_at ON education_modules(published_at);

CREATE INDEX idx_module_content_module_id ON module_content(module_id);
CREATE INDEX idx_module_content_type ON module_content(type);
CREATE INDEX idx_module_content_order ON module_content(module_id, order_index);

CREATE INDEX idx_user_progress_user_id ON user_progress(user_id);
CREATE INDEX idx_user_progress_module_id ON user_progress(module_id);
CREATE INDEX idx_user_progress_completed ON user_progress(completed);

CREATE INDEX idx_content_progress_user_id ON content_progress(user_id);
CREATE INDEX idx_content_progress_content_id ON content_progress(content_id);

CREATE INDEX idx_quiz_attempts_user_id ON quiz_attempts(user_id);
CREATE INDEX idx_quiz_attempts_module_id ON quiz_attempts(module_id);

CREATE INDEX idx_ab_test_participation_user_id ON ab_test_participation(user_id);
CREATE INDEX idx_ab_test_participation_test_id ON ab_test_participation(test_id);

CREATE INDEX idx_module_analytics_daily_module_id ON module_analytics_daily(module_id);
CREATE INDEX idx_module_analytics_daily_date ON module_analytics_daily(date);

-- Function to update module analytics
CREATE OR REPLACE FUNCTION update_module_analytics(module_uuid UUID)
RETURNS void AS $$
BEGIN
    UPDATE education_modules SET
        total_views = (
            SELECT COUNT(*) FROM user_progress 
            WHERE module_id = module_uuid
        ),
        completion_rate = (
            SELECT COALESCE(
                (COUNT(*) FILTER (WHERE completed = true) * 100.0) / NULLIF(COUNT(*), 0),
                0
            ) FROM user_progress 
            WHERE module_id = module_uuid
        ),
        average_score = (
            SELECT COALESCE(AVG(score::decimal / max_score * 100), 0)
            FROM quiz_attempts 
            WHERE module_id = module_uuid AND passed = true
        ),
        average_time_spent = (
            SELECT COALESCE(AVG(time_spent), 0)
            FROM user_progress 
            WHERE module_id = module_uuid AND completed = true
        ),
        retry_rate = (
            SELECT COALESCE(
                (COUNT(*) FILTER (WHERE attempt_number > 1) * 100.0) / NULLIF(COUNT(DISTINCT user_id), 0),
                0
            ) FROM quiz_attempts 
            WHERE module_id = module_uuid
        ),
        analytics_updated_at = NOW()
    WHERE id = module_uuid;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update analytics when progress changes
CREATE OR REPLACE FUNCTION trigger_update_module_analytics()
RETURNS trigger AS $$
BEGIN
    PERFORM update_module_analytics(NEW.module_id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_analytics_on_progress
    AFTER INSERT OR UPDATE OF completed, time_spent ON user_progress
    FOR EACH ROW
    EXECUTE FUNCTION trigger_update_module_analytics();

CREATE TRIGGER update_analytics_on_quiz_completion
    AFTER INSERT OR UPDATE ON quiz_attempts
    FOR EACH ROW
    EXECUTE FUNCTION trigger_update_module_analytics();