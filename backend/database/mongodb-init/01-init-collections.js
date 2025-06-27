// MongoDB Initialization Script
// Financial Kingdom Builder - Educational Content Management

// Switch to the application database
db = db.getSiblingDB('financial_kingdom');

// Create educational_modules collection
db.createCollection('educational_modules', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['id', 'title', 'category', 'tier', 'content', 'createdAt'],
      properties: {
        id: {
          bsonType: 'string',
          description: 'Unique module identifier'
        },
        title: {
          bsonType: 'string',
          description: 'Module title'
        },
        description: {
          bsonType: 'string',
          description: 'Module description'
        },
        category: {
          bsonType: 'string',
          enum: ['financial_literacy', 'risk_management', 'technical_analysis', 'trading_psychology', 'market_fundamentals', 'cryptocurrency_basics', 'options_trading', 'margin_trading', 'perpetuals_trading'],
          description: 'Module category'
        },
        tier: {
          bsonType: 'int',
          minimum: 1,
          maximum: 4,
          description: 'Required tier to access module'
        },
        difficulty: {
          bsonType: 'string',
          enum: ['beginner', 'intermediate', 'advanced'],
          description: 'Module difficulty level'
        },
        estimatedMinutes: {
          bsonType: 'int',
          minimum: 1,
          description: 'Estimated completion time in minutes'
        },
        content: {
          bsonType: 'object',
          required: ['sections'],
          properties: {
            introduction: {
              bsonType: 'string',
              description: 'Module introduction text'
            },
            sections: {
              bsonType: 'array',
              items: {
                bsonType: 'object',
                required: ['title', 'content'],
                properties: {
                  title: { bsonType: 'string' },
                  content: { bsonType: 'string' },
                  mediaUrl: { bsonType: 'string' },
                  mediaType: { 
                    bsonType: 'string',
                    enum: ['image', 'video', 'interactive']
                  }
                }
              }
            },
            summary: {
              bsonType: 'string',
              description: 'Module summary'
            }
          }
        },
        quiz: {
          bsonType: 'object',
          properties: {
            questions: {
              bsonType: 'array',
              items: {
                bsonType: 'object',
                required: ['question', 'options', 'correctAnswer'],
                properties: {
                  question: { bsonType: 'string' },
                  options: {
                    bsonType: 'array',
                    items: { bsonType: 'string' }
                  },
                  correctAnswer: { bsonType: 'int' },
                  explanation: { bsonType: 'string' }
                }
              }
            },
            passingScore: {
              bsonType: 'int',
              minimum: 0,
              maximum: 100
            }
          }
        },
        prerequisites: {
          bsonType: 'array',
          items: { bsonType: 'string' },
          description: 'Required module IDs before accessing this module'
        },
        tags: {
          bsonType: 'array',
          items: { bsonType: 'string' },
          description: 'Searchable tags'
        },
        isActive: {
          bsonType: 'bool',
          description: 'Whether module is active'
        },
        createdAt: {
          bsonType: 'date',
          description: 'Creation timestamp'
        },
        updatedAt: {
          bsonType: 'date',
          description: 'Last update timestamp'
        },
        version: {
          bsonType: 'int',
          description: 'Content version for A/B testing'
        }
      }
    }
  }
});

// Create educational_content collection for rich content
db.createCollection('educational_content', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['id', 'type', 'title', 'content', 'createdAt'],
      properties: {
        id: {
          bsonType: 'string',
          description: 'Unique content identifier'
        },
        type: {
          bsonType: 'string',
          enum: ['article', 'video', 'interactive', 'infographic', 'quiz', 'simulation'],
          description: 'Content type'
        },
        title: {
          bsonType: 'string',
          description: 'Content title'
        },
        description: {
          bsonType: 'string',
          description: 'Content description'
        },
        content: {
          bsonType: 'object',
          description: 'Flexible content structure'
        },
        mediaUrls: {
          bsonType: 'array',
          items: { bsonType: 'string' },
          description: 'Associated media URLs'
        },
        tags: {
          bsonType: 'array',
          items: { bsonType: 'string' },
          description: 'Content tags'
        },
        category: {
          bsonType: 'string',
          description: 'Content category'
        },
        difficulty: {
          bsonType: 'string',
          enum: ['beginner', 'intermediate', 'advanced']
        },
        isActive: {
          bsonType: 'bool',
          description: 'Whether content is active'
        },
        createdAt: {
          bsonType: 'date',
          description: 'Creation timestamp'
        },
        updatedAt: {
          bsonType: 'date',
          description: 'Last update timestamp'
        }
      }
    }
  }
});

// Create learning_paths collection for structured learning journeys
db.createCollection('learning_paths', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['id', 'name', 'description', 'tier', 'modules', 'createdAt'],
      properties: {
        id: {
          bsonType: 'string',
          description: 'Unique path identifier'
        },
        name: {
          bsonType: 'string',
          description: 'Learning path name'
        },
        description: {
          bsonType: 'string',
          description: 'Path description'
        },
        tier: {
          bsonType: 'int',
          minimum: 1,
          maximum: 4,
          description: 'Tier level for this path'
        },
        modules: {
          bsonType: 'array',
          items: {
            bsonType: 'object',
            required: ['moduleId', 'order'],
            properties: {
              moduleId: { bsonType: 'string' },
              order: { bsonType: 'int' },
              isOptional: { bsonType: 'bool' }
            }
          }
        },
        estimatedHours: {
          bsonType: 'int',
          description: 'Estimated completion time in hours'
        },
        prerequisites: {
          bsonType: 'array',
          items: { bsonType: 'string' },
          description: 'Required path IDs'
        },
        isActive: {
          bsonType: 'bool',
          description: 'Whether path is active'
        },
        createdAt: {
          bsonType: 'date',
          description: 'Creation timestamp'
        },
        updatedAt: {
          bsonType: 'date',
          description: 'Last update timestamp'
        }
      }
    }
  }
});

// Create content_analytics collection for tracking content performance
db.createCollection('content_analytics', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['contentId', 'contentType', 'userId', 'event', 'timestamp'],
      properties: {
        contentId: {
          bsonType: 'string',
          description: 'Content identifier'
        },
        contentType: {
          bsonType: 'string',
          enum: ['module', 'content', 'quiz', 'path'],
          description: 'Type of content'
        },
        userId: {
          bsonType: 'string',
          description: 'User identifier'
        },
        event: {
          bsonType: 'string',
          enum: ['view', 'start', 'progress', 'complete', 'quiz_attempt', 'quiz_pass', 'quiz_fail', 'bookmark', 'share'],
          description: 'Event type'
        },
        metadata: {
          bsonType: 'object',
          description: 'Additional event data'
        },
        timestamp: {
          bsonType: 'date',
          description: 'Event timestamp'
        },
        sessionId: {
          bsonType: 'string',
          description: 'User session identifier'
        }
      }
    }
  }
});

// Create user_bookmarks collection for saved content
db.createCollection('user_bookmarks', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['userId', 'contentId', 'contentType', 'createdAt'],
      properties: {
        userId: {
          bsonType: 'string',
          description: 'User identifier'
        },
        contentId: {
          bsonType: 'string',
          description: 'Content identifier'
        },
        contentType: {
          bsonType: 'string',
          enum: ['module', 'content', 'path'],
          description: 'Type of content'
        },
        notes: {
          bsonType: 'string',
          description: 'User notes'
        },
        tags: {
          bsonType: 'array',
          items: { bsonType: 'string' },
          description: 'User-defined tags'
        },
        createdAt: {
          bsonType: 'date',
          description: 'Bookmark creation timestamp'
        }
      }
    }
  }
});

// Create indexes for performance optimization
db.educational_modules.createIndex({ 'id': 1 }, { unique: true });
db.educational_modules.createIndex({ 'category': 1, 'tier': 1 });
db.educational_modules.createIndex({ 'isActive': 1 });
db.educational_modules.createIndex({ 'tags': 1 });
db.educational_modules.createIndex({ 'createdAt': -1 });

db.educational_content.createIndex({ 'id': 1 }, { unique: true });
db.educational_content.createIndex({ 'type': 1, 'category': 1 });
db.educational_content.createIndex({ 'isActive': 1 });
db.educational_content.createIndex({ 'tags': 1 });
db.educational_content.createIndex({ 'title': 'text', 'description': 'text' });

db.learning_paths.createIndex({ 'id': 1 }, { unique: true });
db.learning_paths.createIndex({ 'tier': 1 });
db.learning_paths.createIndex({ 'isActive': 1 });
db.learning_paths.createIndex({ 'modules.moduleId': 1 });

db.content_analytics.createIndex({ 'contentId': 1, 'timestamp': -1 });
db.content_analytics.createIndex({ 'userId': 1, 'timestamp': -1 });
db.content_analytics.createIndex({ 'event': 1, 'timestamp': -1 });
db.content_analytics.createIndex({ 'contentType': 1, 'timestamp': -1 });

db.user_bookmarks.createIndex({ 'userId': 1, 'contentId': 1 }, { unique: true });
db.user_bookmarks.createIndex({ 'userId': 1, 'createdAt': -1 });
db.user_bookmarks.createIndex({ 'contentType': 1 });

// Insert sample educational modules for Tier 1 (Village Foundations)
db.educational_modules.insertMany([
  {
    id: 'financial-literacy-101',
    title: 'Financial Literacy Fundamentals',
    description: 'Learn the basic principles of personal finance and money management',
    category: 'financial_literacy',
    tier: 1,
    difficulty: 'beginner',
    estimatedMinutes: 15,
    content: {
      introduction: 'Welcome to your financial journey! This module covers the fundamental concepts of personal finance.',
      sections: [
        {
          title: 'What is Money?',
          content: 'Money is a medium of exchange that facilitates trade and commerce. Understanding its role is crucial for financial success.'
        },
        {
          title: 'Income vs Expenses',
          content: 'Income is money you earn, expenses are money you spend. The key to financial health is earning more than you spend.'
        },
        {
          title: 'Budgeting Basics',
          content: 'A budget is a plan for your money. It helps you track income and expenses to achieve your financial goals.'
        }
      ],
      summary: 'Financial literacy is the foundation of wealth building. Master these basics to build your financial kingdom!'
    },
    quiz: {
      questions: [
        {
          question: 'What is the primary function of money?',
          options: ['Store of value', 'Medium of exchange', 'Unit of account', 'All of the above'],
          correctAnswer: 3,
          explanation: 'Money serves all three functions: store of value, medium of exchange, and unit of account.'
        },
        {
          question: 'What is a budget?',
          options: ['A plan for spending money', 'A way to track expenses', 'A financial goal-setting tool', 'All of the above'],
          correctAnswer: 3,
          explanation: 'A budget serves multiple purposes in personal finance management.'
        }
      ],
      passingScore: 70
    },
    prerequisites: [],
    tags: ['basics', 'finance', 'budgeting', 'money'],
    isActive: true,
    createdAt: new Date(),
    updatedAt: new Date(),
    version: 1
  },
  {
    id: 'risk-management-basics',
    title: 'Understanding Risk and Reward',
    description: 'Learn how to assess and manage financial risks in your investment journey',
    category: 'risk_management',
    tier: 1,
    difficulty: 'beginner',
    estimatedMinutes: 20,
    content: {
      introduction: 'Risk and reward go hand in hand in finance. Learn to balance them wisely.',
      sections: [
        {
          title: 'What is Financial Risk?',
          content: 'Financial risk is the possibility of losing money on an investment. Every investment carries some level of risk.'
        },
        {
          title: 'Types of Risk',
          content: 'Market risk, credit risk, inflation risk, and liquidity risk are the main types you should understand.'
        },
        {
          title: 'Risk vs Reward',
          content: 'Generally, higher potential returns come with higher risk. The key is finding the right balance for your situation.'
        }
      ],
      summary: 'Understanding risk helps you make informed decisions and protect your financial kingdom from threats.'
    },
    quiz: {
      questions: [
        {
          question: 'What is the relationship between risk and reward?',
          options: ['Higher risk = lower reward', 'Higher risk = higher potential reward', 'Risk and reward are unrelated', 'Lower risk = higher reward'],
          correctAnswer: 1,
          explanation: 'In general, investments with higher risk offer the potential for higher returns to compensate investors.'
        }
      ],
      passingScore: 70
    },
    prerequisites: ['financial-literacy-101'],
    tags: ['risk', 'investment', 'basics', 'portfolio'],
    isActive: true,
    createdAt: new Date(),
    updatedAt: new Date(),
    version: 1
  },
  {
    id: 'cryptocurrency-101',
    title: 'Cryptocurrency Fundamentals',
    description: 'Introduction to digital currencies and blockchain technology',
    category: 'cryptocurrency_basics',
    tier: 1,
    difficulty: 'beginner',
    estimatedMinutes: 25,
    content: {
      introduction: 'Cryptocurrency is revolutionizing finance. Learn the basics to participate safely.',
      sections: [
        {
          title: 'What is Cryptocurrency?',
          content: 'Cryptocurrency is digital money secured by cryptography and powered by blockchain technology.'
        },
        {
          title: 'How Blockchain Works',
          content: 'Blockchain is a distributed ledger that records transactions across many computers in a secure, transparent way.'
        },
        {
          title: 'Popular Cryptocurrencies',
          content: 'Bitcoin, Ethereum, and other major cryptocurrencies each serve different purposes in the digital economy.'
        },
        {
          title: 'Storing Crypto Safely',
          content: 'Wallets are essential for storing cryptocurrency. Learn the difference between hot and cold storage.'
        }
      ],
      summary: 'Cryptocurrency knowledge is essential for modern traders. Start building your digital kingdom here!'
    },
    quiz: {
      questions: [
        {
          question: 'What technology powers most cryptocurrencies?',
          options: ['Cloud computing', 'Blockchain', 'Artificial intelligence', 'Quantum computing'],
          correctAnswer: 1,
          explanation: 'Blockchain technology provides the secure, decentralized foundation for most cryptocurrencies.'
        },
        {
          question: 'What is a cryptocurrency wallet?',
          options: ['A physical wallet for coins', 'Software to store digital currencies', 'A bank account', 'A trading platform'],
          correctAnswer: 1,
          explanation: 'A cryptocurrency wallet is software that stores your digital currency and allows you to send and receive it.'
        }
      ],
      passingScore: 70
    },
    prerequisites: ['financial-literacy-101'],
    tags: ['cryptocurrency', 'blockchain', 'bitcoin', 'digital'],
    isActive: true,
    createdAt: new Date(),
    updatedAt: new Date(),
    version: 1
  }
]);

// Insert sample learning paths
db.learning_paths.insertMany([
  {
    id: 'tier-1-village-foundations',
    name: 'Village Foundations',
    description: 'Master the basics of finance and trading to build your financial kingdom',
    tier: 1,
    modules: [
      { moduleId: 'financial-literacy-101', order: 1, isOptional: false },
      { moduleId: 'risk-management-basics', order: 2, isOptional: false },
      { moduleId: 'cryptocurrency-101', order: 3, isOptional: false }
    ],
    estimatedHours: 1,
    prerequisites: [],
    isActive: true,
    createdAt: new Date(),
    updatedAt: new Date()
  }
]);

// Create application user with appropriate permissions
db.createUser({
  user: 'financial_kingdom',
  pwd: 'financial_kingdom_mongodb_password',
  roles: [
    {
      role: 'readWrite',
      db: 'financial_kingdom'
    }
  ]
});

// Create read-only user for analytics
db.createUser({
  user: 'financial_kingdom_readonly',
  pwd: 'financial_kingdom_mongodb_readonly_password',
  roles: [
    {
      role: 'read',
      db: 'financial_kingdom'
    }
  ]
});

print('MongoDB initialization completed successfully!');