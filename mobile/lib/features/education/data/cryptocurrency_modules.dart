import '../models/lesson_content.dart';

class CryptocurrencyModules {
  static final List<LessonContent> modules = [
    // Module 1: What is Cryptocurrency
    LessonContent(
      id: 'crypto-001',
      title: 'What is Cryptocurrency?',
      description: 'Learn the basics of digital currencies and how they work.',
      type: LessonType.interactive,
      data: {
        'content': '''
Welcome to the digital realm of your financial kingdom! Cryptocurrency is like having magical coins that exist only in the digital world.

**What is Cryptocurrency?** 🪙
Digital money that exists only on computers and the internet.
• No physical coins or bills
• Secured by advanced mathematics (cryptography)
• Not controlled by any government or bank
• Can be sent instantly worldwide

**Key Characteristics:**

**Digital Only** 💻
Unlike gold coins in your treasury, crypto exists only as computer code.
Think: Like having a magical ledger that everyone can see but no one can fake.

**Decentralized** 🌐
No single ruler controls it - the network is managed by thousands of computers.
Kingdom Analogy: Instead of one royal mint, thousands of trusted villages each keep identical records.

**Cryptographic Security** 🔐
Protected by mathematical puzzles so complex that even the most powerful computers cannot easily break them.
Security Level: Imagine a vault with a lock that changes every few seconds.

**Transparent** 👁️
All transactions are recorded publicly, but personal identities are hidden.
Like: A public announcement board where everyone can see "Someone sent 5 coins to someone else" but not who exactly.

**Limited Supply** ⚡
Most cryptocurrencies have a maximum number that will ever exist.
Bitcoin Example: Only 21 million Bitcoin will ever be created, making it scarce like rare gems.
''',
        'interactionType': 'conceptExplorer',
        'parameters': {
          'concepts': [
            {
              'name': 'Digital Nature',
              'icon': '💻',
              'description': 'Exists only as computer code',
              'comparison': 'Like having a royal treasury that exists only in books, but everyone has an identical copy'
            },
            {
              'name': 'Decentralization',
              'icon': '🌐',
              'description': 'No central authority controls it',
              'comparison': 'Like a kingdom where every village keeps identical records instead of one royal archive'
            },
            {
              'name': 'Cryptographic Security',
              'icon': '🔐',
              'description': 'Protected by advanced mathematics',
              'comparison': 'Like a magical lock that changes its pattern every few seconds'
            },
            {
              'name': 'Transparency',
              'icon': '👁️',
              'description': 'All transactions are publicly visible',
              'comparison': 'Like a town crier announcing every transaction without naming the people involved'
            }
          ]
        },
        'instructions': 'Explore each concept to understand how cryptocurrency works',
        'successMessage': 'Excellent! You now understand the fundamental nature of cryptocurrency.',
      },
      estimatedMinutes: 6,
    ),

    // Module 2: Blockchain Technology
    LessonContent(
      id: 'crypto-002',
      title: 'Understanding Blockchain',
      description: 'Learn how blockchain technology powers cryptocurrencies.',
      type: LessonType.interactive,
      data: {
        'content': '''
The blockchain is the foundation of all cryptocurrencies - imagine it as an indestructible chain of records that spans across your entire kingdom.

**What is a Blockchain?** ⛓️
A chain of connected digital "blocks" that contain transaction records.
• Each block contains multiple transactions
• Blocks are linked together chronologically  
• Once added, blocks cannot be changed or deleted
• Copies exist on thousands of computers worldwide

**How Blocks Work:**

**Block Structure** 📦
Each block contains:
1. Transaction Data: List of who sent what to whom
2. Timestamp: When the block was created
3. Hash: A unique digital fingerprint
4. Previous Hash: Connects to the previous block

**The Chain Connection** 🔗
Each block references the previous block, creating an unbreakable chain.
Kingdom Analogy: Like a royal chronicle where each page references the previous page, making it impossible to secretly change history.

**Mining Process** ⛏️
Special computers (miners) compete to solve mathematical puzzles to add new blocks.
• Miners verify all transactions in a block
• First to solve the puzzle gets rewarded with cryptocurrency
• The solved block is added to the chain
• All network computers update their copy

**Network Consensus** 🤝
The majority of computers must agree on the state of the blockchain.
• If someone tries to cheat, other computers reject the false information
• Only valid transactions get permanent acceptance
• This prevents double-spending and fraud

**Immutability** 🏛️
Once information is added to the blockchain, it becomes nearly impossible to change.
Security: To change one transaction, you would need to change every subsequent block on the majority of all computers simultaneously.
''',
        'interactionType': 'blockchainVisualization',
        'parameters': {
          'simulationSteps': [
            {
              'step': 1,
              'title': 'New Transaction',
              'description': 'Alice wants to send 5 coins to Bob',
              'visualization': 'transaction_pending'
            },
            {
              'step': 2,
              'title': 'Transaction Pool',
              'description': 'Transaction joins other pending transactions',
              'visualization': 'mempool'
            },
            {
              'step': 3,
              'title': 'Miners Compete',
              'description': 'Miners race to solve the mathematical puzzle',
              'visualization': 'mining_competition'
            },
            {
              'step': 4,
              'title': 'Block Created',
              'description': 'Winner creates new block with verified transactions',
              'visualization': 'block_creation'
            },
            {
              'step': 5,
              'title': 'Network Verification',
              'description': 'Other computers verify and accept the new block',
              'visualization': 'network_consensus'
            },
            {
              'step': 6,
              'title': 'Chain Updated',
              'description': 'New block is permanently added to the blockchain',
              'visualization': 'chain_update'
            }
          ],
          'blockStructure': {
            'blockNumber': 12345,
            'timestamp': '2024-01-15 10:30:00',
            'transactions': [
              {'from': 'Alice', 'to': 'Bob', 'amount': 5},
              {'from': 'Charlie', 'to': 'Diana', 'amount': 3},
              {'from': 'Eve', 'to': 'Frank', 'amount': 8}
            ],
            'previousHash': 'a1b2c3d4e5f6...',
            'currentHash': 'f6e5d4c3b2a1...',
            'nonce': 187234
          }
        },
        'instructions': 'Follow the step-by-step blockchain process visualization',
        'successMessage': 'Amazing! You understand how blockchain technology creates trust without central authority.',
      },
      estimatedMinutes: 10,
    ),

    // Module 3: Popular Cryptocurrencies
    LessonContent(
      id: 'crypto-003',
      title: 'Major Cryptocurrencies',
      description: 'Explore the most important cryptocurrencies and their unique features.',
      type: LessonType.interactive,
      data: {
        'content': '''
Just as different kingdoms have different currencies, the crypto world has various digital coins, each with unique properties and purposes.

**Bitcoin (BTC)** 🥇
The first and most famous cryptocurrency.
• Created in 2009 by mysterious "Satoshi Nakamoto"
• Digital gold - store of value
• Limited to 21 million coins ever
• Most widely accepted cryptocurrency
• Highest market value

**Ethereum (ETH)** 🏗️
The platform for smart contracts and decentralized applications.
• Created by Vitalik Buterin in 2015
• Not just money - a computer platform
• Enables "smart contracts" (self-executing agreements)
• Powers many other cryptocurrencies and apps
• Like having programmable money

**Stablecoins** ⚖️
Cryptocurrencies designed to maintain stable prices.
• Usually pegged to US Dollar (1 coin = 1 dollar)
• Examples: USDC, USDT, DAI
• Used for trading and storing value without volatility
• Bridge between traditional and crypto money

**Altcoins** 🌟
All cryptocurrencies other than Bitcoin.
• Thousands exist with different purposes
• Some focus on privacy (Monero)
• Others on speed (Solana)
• Many are experimental or specialized

**Utility Tokens** 🔧
Cryptocurrencies that power specific platforms or services.
• Used to pay for services on their respective platforms
• Like arcade tokens that only work in specific games
• Value tied to platform adoption and usage

**Market Dynamics** 📊
Crypto markets are known for high volatility.
• Prices can change dramatically in hours
• Influenced by news, regulations, adoption
• Much more volatile than traditional assets
• Higher potential rewards but also higher risks
''',
        'interactionType': 'cryptoComparison',
        'parameters': {
          'cryptocurrencies': [
            {
              'name': 'Bitcoin',
              'symbol': 'BTC',
              'type': 'Digital Gold',
              'features': ['Store of Value', 'Limited Supply', 'First Crypto'],
              'useCase': 'Digital money and store of value',
              'marketCap': 'Largest',
              'volatility': 'High',
              'kingdomAnalogy': 'Like the gold standard of your treasury'
            },
            {
              'name': 'Ethereum',
              'symbol': 'ETH',
              'type': 'Smart Contract Platform',
              'features': ['Smart Contracts', 'DApps', 'Programmable'],
              'useCase': 'Platform for decentralized applications',
              'marketCap': 'Second Largest',
              'volatility': 'High',
              'kingdomAnalogy': 'Like a magical workshop where contracts execute themselves'
            },
            {
              'name': 'Stablecoins',
              'symbol': 'USDC/USDT',
              'type': 'Stable Value',
              'features': ['Price Stability', 'USD Pegged', 'Low Volatility'],
              'useCase': 'Stable store of value and trading',
              'marketCap': 'Large',
              'volatility': 'Very Low',
              'kingdomAnalogy': 'Like coins that always maintain their purchasing power'
            }
          ]
        },
        'instructions': 'Compare different cryptocurrencies to understand their unique properties',
        'successMessage': 'Perfect! You now know the major types of cryptocurrencies and their purposes.',
      },
      estimatedMinutes: 8,
    ),

    // Module 4: Wallets and Storage
    LessonContent(
      id: 'crypto-004',
      title: 'Cryptocurrency Wallets',
      description: 'Learn how to safely store and manage your digital assets.',
      type: LessonType.interactive,
      data: {
        'content': '''
In your digital kingdom, you need secure vaults to store your cryptocurrency treasures. These digital vaults are called wallets.

**What is a Crypto Wallet?** 👛
A digital tool that stores your cryptocurrency private keys.
• Does NOT actually store coins (coins exist on blockchain)
• Stores the "keys" that prove you own certain addresses
• Like having the combination to a safe deposit box
• Your keys = your crypto ownership

**Types of Wallets:**

**Hot Wallets** 🔥
Connected to the internet for easy access.
• Mobile apps, web browsers, desktop software
• Convenient for daily transactions
• More vulnerable to hacking
• Good for small amounts you use regularly
• Examples: MetaMask, Coinbase Wallet, Trust Wallet

**Cold Wallets** ❄️
Offline storage for maximum security.
• Hardware devices, paper wallets
• Not connected to internet
• Much safer from hackers
• Less convenient for frequent use
• Best for long-term storage of large amounts

**Wallet Security Concepts:**

**Private Keys** 🗝️
Your secret password that controls your crypto.
• Long string of random characters
• Must be kept absolutely secret
• If lost = crypto is lost forever
• If stolen = thief can take your crypto
• Kingdom Analogy: The master key to your royal treasury

**Public Keys/Addresses** 📍
Your "account number" that others can see.
• Safe to share publicly
• Others use this to send you crypto
• Like your royal palace address - everyone can know it
• Derived mathematically from your private key

**Seed Phrases** 🌱
12-24 words that can recover your entire wallet.
• Backup for your private keys
• Must be written down and stored safely
• Can restore wallet on any device
• Like a magical spell that recreates your entire treasury

**Security Best Practices** 🛡️
• Never share private keys or seed phrases
• Use hardware wallets for large amounts
• Enable two-factor authentication
• Regular security updates
• Test with small amounts first
• Multiple backups in different locations
''',
        'interactionType': 'walletSecurity',
        'parameters': {
          'securityLevels': [
            {
              'level': 'Basic',
              'description': 'Mobile wallet with PIN protection',
              'security': '⭐⭐',
              'convenience': '⭐⭐⭐⭐⭐',
              'bestFor': 'Small daily spending amounts',
              'risks': ['Phone theft', 'App vulnerabilities']
            },
            {
              'level': 'Intermediate',
              'description': 'Desktop wallet with 2FA',
              'security': '⭐⭐⭐',
              'convenience': '⭐⭐⭐⭐',
              'bestFor': 'Regular trading and medium amounts',
              'risks': ['Computer malware', 'Online threats']
            },
            {
              'level': 'Advanced',
              'description': 'Hardware wallet offline storage',
              'security': '⭐⭐⭐⭐⭐',
              'convenience': '⭐⭐',
              'bestFor': 'Long-term savings and large amounts',
              'risks': ['Physical loss', 'Seed phrase compromise']
            }
          ],
          'scenarios': [
            {
              'scenario': 'Daily coffee purchases',
              'recommendation': 'Hot wallet with small balance',
              'reasoning': 'Convenience is more important than maximum security for small amounts'
            },
            {
              'scenario': 'Retirement savings',
              'recommendation': 'Cold wallet with multiple backups',
              'reasoning': 'Maximum security is critical for long-term wealth storage'
            },
            {
              'scenario': 'Active trading',
              'recommendation': 'Exchange wallet with 2FA',
              'reasoning': 'Need quick access for frequent buying and selling'
            }
          ]
        },
        'instructions': 'Learn about different wallet security levels and choose the right approach',
        'successMessage': 'Excellent! You understand how to safely store and manage cryptocurrency.',
      },
      estimatedMinutes: 9,
    ),

    // Module 5: Cryptocurrency Investment Basics
    LessonContent(
      id: 'crypto-005',
      title: 'Investing in Cryptocurrency',
      description: 'Learn the basics of cryptocurrency investment and risk management.',
      type: LessonType.text,
      data: {
        'content': '''
Investing in cryptocurrency is like exploring a new continent - full of opportunities but requiring careful preparation and risk management.

**Investment Approaches** 📈

**Dollar-Cost Averaging (DCA)** ⏰
Buying a fixed amount regularly regardless of price.
• Reduces impact of volatility
• Removes emotion from timing decisions
• Good for long-term investors
• Example: Buy 100 dollars of Bitcoin every month

**HODLing** 💎
Buy and hold for long periods (originated from "Hold On for Dear Life").
• Based on belief in long-term value growth
• Ignores short-term price fluctuations
• Requires strong emotional discipline
• Popular strategy for Bitcoin believers

**Trading** ⚡
Actively buying and selling to profit from price movements.
• Requires significant time and skill
• High stress and emotional demands
• Most traders lose money
• Not recommended for beginners

**Key Investment Principles** 🎯

**Only Invest What You Can Afford to Lose** ⚠️
Cryptocurrency is extremely volatile and risky.
• Prices can drop 50-90% during bear markets
• Entire projects can become worthless
• Regulatory changes can impact values
• Never invest emergency funds or borrowed money

**Diversification** 🌈
Don't put all your money in one cryptocurrency.
• Spread investment across multiple coins
• Include some Bitcoin and Ethereum (more established)
• Consider mixing crypto with traditional investments
• Different cryptocurrencies have different risk profiles

**Research Before Investing** 🔍
Understand what you're buying.
• Read project whitepapers
• Understand the technology and use case
• Check the team and partnerships
• Evaluate community and adoption
• Be wary of projects promising unrealistic returns

**Common Mistakes to Avoid** ❌

**FOMO (Fear of Missing Out)** 😱
Buying because price is rising rapidly.
• Often leads to buying at market tops
• Driven by emotion rather than analysis
• Results in poor entry prices

**Panic Selling** 📉
Selling during market crashes due to fear.
• Locks in losses during temporary downturns
• Often sells right before recovery
• Emotional decision making

**Falling for Scams** 🚫
Cryptocurrency space has many fraudulent schemes.
• "Get rich quick" promises
• Ponzi schemes and fake projects
• Phishing websites and fake wallets
• If it sounds too good to be true, it probably is

**Regulatory Considerations** ⚖️
Cryptocurrency regulations vary by country and are constantly evolving.
• Some countries have banned cryptocurrencies
• Tax implications vary widely
• Future regulations could impact values
• Stay informed about legal status in your location

**The Golden Rules of Crypto Investing:**
1. Start small and learn as you go
2. Never invest more than you can afford to lose
3. Do your own research (DYOR)
4. Focus on projects with real utility
5. Think long-term, not quick profits
6. Keep learning about the technology
7. Stay humble - the market is unpredictable
''',
      },
      estimatedMinutes: 10,
    ),

    // Quiz Module
    LessonContent(
      id: 'crypto-quiz',
      title: 'Cryptocurrency Mastery Quiz',
      description: 'Test your understanding of cryptocurrency and blockchain concepts.',
      type: LessonType.quiz,
      data: {
        'content': 'Test your cryptocurrency knowledge with this comprehensive quiz.',
        'questions': [
          {
            'question': 'What makes cryptocurrency different from traditional money?',
            'options': ['It is digital and decentralized', 'It is controlled by banks', 'It has no value', 'It cannot be transferred'],
            'correctAnswer': 0,
            'explanation': 'Cryptocurrency is digital money that operates on decentralized networks, not controlled by any central authority like banks or governments.',
            'kingdomMetaphor': 'Like having magical coins that exist in a realm where no single ruler controls the currency.',
          },
          {
            'question': 'What is a blockchain?',
            'options': ['A type of cryptocurrency', 'A chain of connected transaction records', 'A mining tool', 'A wallet application'],
            'correctAnswer': 1,
            'explanation': 'A blockchain is a chain of connected blocks containing transaction records, forming an immutable ledger.',
            'kingdomMetaphor': 'Like an indestructible royal chronicle where each page references the previous one.',
          },
          {
            'question': 'What should you do with your private keys?',
            'options': ['Share them with friends', 'Post them online', 'Keep them secret and secure', 'Give them to exchanges'],
            'correctAnswer': 2,
            'explanation': 'Private keys must be kept absolutely secret and secure as they control access to your cryptocurrency.',
            'kingdomMetaphor': 'Like guarding the master key to your royal treasury - never let anyone else have it.',
          },
          {
            'question': 'What is the main advantage of dollar-cost averaging in crypto investing?',
            'options': ['Guaranteed profits', 'Reduces impact of volatility', 'Eliminates all risk', 'Provides insider information'],
            'correctAnswer': 1,
            'explanation': 'Dollar-cost averaging reduces the impact of volatility by spreading purchases over time, rather than trying to time the market.',
            'kingdomMetaphor': 'Like gradually building your treasury rather than spending everything at once when prices might be high.',
          },
          {
            'question': 'What is the most important rule for cryptocurrency investing?',
            'options': ['Buy as much as possible', 'Only invest what you can afford to lose', 'Follow social media tips', 'Trade every day'],
            'correctAnswer': 1,
            'explanation': 'The cardinal rule is to only invest what you can afford to lose completely, as cryptocurrency is extremely volatile and risky.',
            'kingdomMetaphor': 'Like only risking treasure you could lose without endangering your kingdom\'s survival.',
          },
        ],
      },
      estimatedMinutes: 8,
    ),
  ];

  static LessonContent? getModuleById(String id) {
    try {
      return modules.firstWhere((module) => module.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<LessonContent> getModulesByType(LessonType type) {
    return modules.where((module) => module.type == type).toList();
  }

  static int getTotalEstimatedMinutes() {
    return modules.fold(0, (sum, module) => sum + module.estimatedMinutes);
  }

  static Duration getTotalDuration() {
    return Duration(minutes: getTotalEstimatedMinutes());
  }
}