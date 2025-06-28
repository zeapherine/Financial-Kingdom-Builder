-- Education Content System Seed Data
-- Insert default categories and sample educational modules

-- Insert Education Categories
INSERT INTO education_categories (name, description, icon, color, order_index, is_active) VALUES
('financial-literacy', 'Learn the fundamentals of personal finance, budgeting, and money management', 'school', '#58CC02', 1, true),
('risk-management', 'Understand different types of financial risk and how to manage them effectively', 'shield', '#1CB0F6', 2, true),
('technical-analysis', 'Master chart reading, indicators, and technical trading strategies', 'trending_up', '#FF9600', 3, true),
('trading-psychology', 'Develop the mental skills and emotional control needed for successful trading', 'psychology', '#CE82FF', 4, true);

-- Insert Sample Educational Modules for Tier 1 (Village)
INSERT INTO education_modules (
    title, description, tier, category, difficulty, estimated_duration, xp_reward, 
    prerequisites, status, created_by, tags
) VALUES 
-- Financial Literacy Modules (Tier 1)
(
    'What is Money?', 
    'Understand the basic concept of money, its functions, and different forms of currency',
    1, 'financial-literacy', 'beginner', 10, 100,
    '[]'::jsonb, 'published', 
    (SELECT id FROM users LIMIT 1),
    '["basics", "money", "currency"]'::jsonb
),
(
    'Personal Budgeting Basics',
    'Learn how to create and maintain a personal budget to manage your income and expenses',
    1, 'financial-literacy', 'beginner', 15, 150,
    '[]'::jsonb, 'published',
    (SELECT id FROM users LIMIT 1),
    '["budgeting", "expenses", "income"]'::jsonb
),
(
    'Understanding Bank Accounts',
    'Explore different types of bank accounts and how to choose the right one for your needs',
    1, 'financial-literacy', 'beginner', 12, 120,
    '[]'::jsonb, 'published',
    (SELECT id FROM users LIMIT 1),
    '["banking", "savings", "checking"]'::jsonb
),

-- Risk Management Modules (Tier 1)
(
    'What is Financial Risk?',
    'Introduction to different types of financial risks and why understanding them matters',
    1, 'risk-management', 'beginner', 10, 100,
    '[]'::jsonb, 'published',
    (SELECT id FROM users LIMIT 1),
    '["risk", "basics", "safety"]'::jsonb
),
(
    'Emergency Fund Planning',
    'Learn why emergency funds are crucial and how to build one systematically',
    1, 'risk-management', 'beginner', 15, 150,
    '[]'::jsonb, 'published',
    (SELECT id FROM users LIMIT 1),
    '["emergency-fund", "planning", "security"]'::jsonb
),

-- Technical Analysis Modules (Tier 2)
(
    'Reading Price Charts',
    'Learn the basics of reading financial charts and understanding price movements',
    2, 'technical-analysis', 'intermediate', 20, 200,
    '[]'::jsonb, 'published',
    (SELECT id FROM users LIMIT 1),
    '["charts", "price-action", "analysis"]'::jsonb
),
(
    'Support and Resistance',
    'Understand key price levels and how they influence trading decisions',
    2, 'technical-analysis', 'intermediate', 18, 180,
    '[]'::jsonb, 'published',
    (SELECT id FROM users LIMIT 1),
    '["support", "resistance", "levels"]'::jsonb
),

-- Trading Psychology Modules (Tier 3)
(
    'Emotions in Trading',
    'Understand how emotions affect trading decisions and learn to manage them',
    3, 'trading-psychology', 'advanced', 25, 250,
    '[]'::jsonb, 'published',
    (SELECT id FROM users LIMIT 1),
    '["emotions", "psychology", "discipline"]'::jsonb
),
(
    'Risk vs Reward Mindset',
    'Develop a proper risk-reward mindset for sustainable trading success',
    3, 'trading-psychology', 'advanced', 22, 220,
    '[]'::jsonb, 'published',
    (SELECT id FROM users LIMIT 1),
    '["risk-reward", "mindset", "strategy"]'::jsonb
);

-- Sample Module Content for "What is Money?" module
WITH money_module AS (
    SELECT id FROM education_modules WHERE title = 'What is Money?' LIMIT 1
)
INSERT INTO module_content (module_id, type, title, content, duration, order_index, metadata) 
SELECT 
    money_module.id,
    content_data.type,
    content_data.title,
    content_data.content,
    content_data.duration,
    content_data.order_index,
    content_data.metadata::jsonb
FROM money_module,
(VALUES 
    ('text', 'Introduction to Money', 'Money is a medium of exchange that facilitates transactions in an economy. Throughout history, humans have used various forms of money, from barter systems to digital currencies.', 3, 1, '{}'),
    ('text', 'Functions of Money', 'Money serves three primary functions: 1) Medium of Exchange - facilitates trade, 2) Store of Value - preserves purchasing power over time, 3) Unit of Account - provides a standard measure of value.', 4, 2, '{}'),
    ('quiz', 'Money Basics Quiz', 'Test your understanding of basic money concepts', 3, 3, '{"quizConfig": {"passingScore": 70, "allowRetry": true, "maxAttempts": 3}}')
) AS content_data(type, title, content, duration, order_index, metadata);

-- Sample Quiz Questions for Money Basics Quiz
WITH quiz_content AS (
    SELECT mc.id 
    FROM module_content mc 
    JOIN education_modules em ON mc.module_id = em.id 
    WHERE em.title = 'What is Money?' AND mc.type = 'quiz'
    LIMIT 1
)
INSERT INTO quiz_questions (content_id, type, question, options, correct_answer, explanation, points, order_index)
SELECT 
    quiz_content.id,
    question_data.type,
    question_data.question,
    question_data.options::jsonb,
    question_data.correct_answer::jsonb,
    question_data.explanation,
    question_data.points,
    question_data.order_index
FROM quiz_content,
(VALUES 
    ('multiple-choice', 'What are the three main functions of money?', '["Medium of exchange, Store of value, Unit of account", "Buying, Selling, Trading", "Saving, Spending, Investing", "Cash, Credit, Digital"]', '"Medium of exchange, Store of value, Unit of account"', 'Money serves as a medium of exchange (facilitates transactions), store of value (preserves purchasing power), and unit of account (standard measure).', 2, 1),
    ('true-false', 'Money has always existed in the form of coins and paper bills.', '["True", "False"]', '"False"', 'Throughout history, money has taken many forms including shells, stones, precious metals, and now digital currencies.', 1, 2),
    ('multiple-choice', 'Which of these is NOT a characteristic of good money?', '["Durability", "Divisibility", "Complexity", "Portability"]', '"Complexity"', 'Good money should be simple to understand and use. Complexity makes it harder for people to adopt and trust.', 2, 3)
) AS question_data(type, question, options, correct_answer, explanation, points, order_index);

-- Initialize module analytics
INSERT INTO module_analytics_daily (module_id, date, total_views, total_completions, unique_users)
SELECT 
    em.id,
    CURRENT_DATE - INTERVAL '30 days' + (generate_series(0, 30) * INTERVAL '1 day'),
    floor(random() * 50) + 1,
    floor(random() * 20) + 1,
    floor(random() * 40) + 1
FROM education_modules em
WHERE em.status = 'published';

-- Update module analytics for all published modules
SELECT update_module_analytics(id) FROM education_modules WHERE status = 'published';