import '../models/lesson_content.dart';

class PerpetualBasicsModules {
  static List<LessonContent> getPerpetualBasicsLessons() {
    return [
      // Lesson 1: Territory Expansion Contracts (What are perpetuals?)
      LessonContent(
        id: 'perp-001',
        title: 'Territory Expansion Contracts',
        description: 'Discover perpetual contracts - the foundation of modern kingdom trading',
        type: LessonType.text,
        estimatedMinutes: 8,
        learningObjectives: [
          'Understand what perpetual contracts are',
          'Learn how they differ from owning actual territories',
          'Discover why perpetuals are perfect for kingdom expansion',
        ],
        data: {
          'content': '''
Welcome to the world of Territory Expansion Contracts, brave ruler!

Imagine you want to expand your kingdom by claiming new territories, but you don't want to physically occupy them right away. That's exactly what perpetual contracts let you do!

**What are Perpetual Contracts?**
A perpetual contract is like making a bet on whether a territory's value will go up or down, without actually owning the land. It's a magical contract that never expires - hence "perpetual"!

**Kingdom Analogy:**
Traditional Land Ownership: You buy a piece of land, you own it forever, you get the crops it produces.

Territory Expansion Contracts: You make an agreement about a territory's future value. If you're right, you profit. If you're wrong, you lose gold.

**Key Differences from Spot Trading:**
No Expiry: Unlike traditional contracts, perpetuals never expire
No Physical Delivery: You never actually receive the underlying asset
Funding Payments: Traders pay each other to keep the contract price fair
Leverage: You can control large territories with small amounts of gold

**Real-World Example:**
Instead of buying 1 Bitcoin for 40,000 dollars, you can open a perpetual contract that gives you the same profit/loss as owning Bitcoin, but you only need 4,000 dollars (with 10x leverage).

**Why Perpetuals are Perfect for Kingdoms:**
Efficiency: Control more territory with less gold
Speed: Enter and exit positions instantly
Access: Trade territories from anywhere in the world
Flexibility: Profit from both rising AND falling territory values
''',
          'kingdomAnalogy': '''
Think of perpetual contracts like hiring mercenaries instead of maintaining a standing army:

Mercenaries (Perpetuals): Pay as needed, deploy quickly, highly flexible
Standing Army (Spot Trading): Expensive to maintain, slower to deploy, but you own them completely

Smart rulers use both strategies depending on the situation!
''',
        },
      ),

      // Lesson 2: Rising vs Falling Kingdom Values (Long vs Short)
      LessonContent(
        id: 'perp-002',
        title: 'Rising vs Falling Kingdom Values',
        description: 'Master the art of profiting from both prosperity and decline',
        type: LessonType.interactive,
        estimatedMinutes: 10,
        learningObjectives: [
          'Understand long positions (betting on territory growth)',
          'Learn short positions (profiting from territory decline)',
          'Practice entering both types of positions safely',
        ],
        data: {
          'interactionType': 'long_short_simulator',
          'instructions': '''
Practice opening long and short positions with our kingdom simulator. 
Watch how your treasury changes as territory values fluctuate!
''',
          'parameters': {
            'startingBalance': 10000,
            'territories': [
              {
                'name': 'Bitcoin Kingdom',
                'symbol': 'BTC',
                'currentPrice': 40000,
                'priceHistory': [39000, 39500, 40000, 40200, 39800]
              },
              {
                'name': 'Ethereum Realm',
                'symbol': 'ETH', 
                'currentPrice': 2500,
                'priceHistory': [2400, 2450, 2500, 2520, 2480]
              }
            ],
            'maxLeverage': 5
          },
          'explanation': '''
**Long Positions (Betting on Growth)**

When you "go long" on a territory, you're betting its value will increase:
Kingdom Analogy: You believe a neighboring kingdom will prosper
How it Works: You buy a contract that profits when the price goes up
Example: Long Bitcoin at 40,000 dollars. If it goes to 42,000 dollars, you profit 2,000 dollars per contract

**Short Positions (Profiting from Decline)**

When you "go short" on a territory, you're betting its value will decrease:
Kingdom Analogy: You predict a rival kingdom will face troubles
How it Works: You sell a contract that profits when the price goes down  
Example: Short Bitcoin at 40,000 dollars. If it drops to 38,000 dollars, you profit 2,000 dollars per contract

**Key Kingdom Wisdom:**
Long: "I believe this territory will flourish" (Buy first, sell later at higher price)
Short: "I believe this territory will struggle" (Sell first, buy back later at lower price)

**When to Use Each:**
Long: During kingdom growth periods, new technologies, positive news
Short: During conflicts, economic troubles, or overvalued territories

Remember: A wise ruler can profit in any season - whether kingdoms rise or fall!
''',
        },
      ),

      // Lesson 3: Resource Amplification (Leverage basics)
      LessonContent(
        id: 'perp-003',
        title: 'Resource Amplification',
        description: 'Learn how to multiply your trading power with leverage',
        type: LessonType.chart,
        estimatedMinutes: 12,
        learningObjectives: [
          'Understand what leverage means in perpetual trading',
          'Learn different leverage levels and their risks',
          'See how leverage amplifies both gains and losses',
        ],
        data: {
          'chartType': 'ChartType.custom',
          'explanation': '''
Leverage is like borrowing soldiers to expand your army - it multiplies your power, but also your risk!

**What is Leverage?**
Leverage lets you control a large position with a small amount of gold. It's like commanding 10 armies while only paying for 1.

**Common Leverage Levels:**
2x: Control 2,000 dollars worth with 1,000 dollars (Conservative)
5x: Control 5,000 dollars worth with 1,000 dollars (Moderate)  
10x: Control 10,000 dollars worth with 1,000 dollars (Aggressive)
20x: Control 20,000 dollars worth with 1,000 dollars (Very Risky)

**The Double-Edged Sword:**
Amplified Profits: 5x leverage = 5x profits when you're right
Amplified Losses: 5x leverage = 5x losses when you're wrong

**Kingdom Example:**
You have 1,000 gold. Without leverage, if Bitcoin goes up 10%, you make 100 gold.
With 5x leverage, you control 5,000 gold worth. If Bitcoin goes up 10%, you make 500 gold!

But if Bitcoin goes DOWN 10%, you lose 500 gold instead of 100.
''',
          'chartData': {
            'leverageComparison': [
              {'leverage': '1x', 'position': 1000, 'profit10': 100, 'loss10': -100},
              {'leverage': '2x', 'position': 2000, 'profit10': 200, 'loss10': -200},
              {'leverage': '5x', 'position': 5000, 'profit10': 500, 'loss10': -500},
              {'leverage': '10x', 'position': 10000, 'profit10': 1000, 'loss10': -1000},
            ]
          },
          'keyTakeaways': [
            'Leverage multiplies both profits AND losses equally',
            'Higher leverage = higher risk of liquidation',
            'Start with low leverage (2x-5x) until you gain experience',
            'Never risk more than you can afford to lose',
            'Leverage is a tool - use it wisely like a sharp sword'
          ],
        },
      ),

      // Lesson 4: Kingdom Taxes and Rewards (Funding rates)
      LessonContent(
        id: 'perp-004',
        title: 'Kingdom Taxes and Rewards',
        description: 'Understand funding rates - the mechanism that keeps perpetual contracts fair',
        type: LessonType.text,
        estimatedMinutes: 9,
        learningObjectives: [
          'Understand what funding rates are and why they exist',
          'Learn when you pay vs receive funding',
          'Discover how to use funding rates to your advantage',
        ],
        data: {
          'content': '''
Every great kingdom needs a taxation system to maintain balance. In the world of perpetuals, this system is called "funding rates"!

**What are Funding Rates?**
Funding rates are like a tax/reward system that keeps perpetual contract prices aligned with the real market price. It's paid between traders every 8 hours.

**The Kingdom Balance System:**

When there are too many LONG positions (bulls):
Long traders pay funding to short traders
This encourages more short positions to balance the market
Like: "Too many people want to expand north, so they pay those defending the south"

When there are too many SHORT positions (bears):
Short traders pay funding to long traders  
This encourages more long positions to balance the market
Like: "Too many people expect attacks, so they pay those who stay optimistic"

**Funding Rate Examples:**
Positive Funding (+0.01%): Longs pay shorts
Negative Funding (-0.01%): Shorts pay longs
Zero Funding (0%): Perfectly balanced market

**Kingdom Analogy:**
Imagine your kingdom has two armies:
Expansion Army (Longs): Want to conquer new territories
Defense Army (Shorts): Expect enemy attacks

If too many join the Expansion Army, they must pay the Defense Army to maintain balance. If too many join Defense, they pay Expansion.

**Smart Kingdom Strategy:**
Funding Farmers: Take the less popular side to collect funding payments
Trend Followers: Focus on price direction, accept funding costs
Balanced Rulers: Use funding rates to time entries and exits

**Real Example:**
If Bitcoin perpetual has +0.05% funding (positive), and you're long with a 10,000 dollar position:
You pay 5 dollars every 8 hours (3 times per day = 15 dollars/day)
But if Bitcoin goes up 2%, you make 200 dollars!

**Kingdom Wisdom:**
Funding rates are like the weather - sometimes it rains (you pay), sometimes it shines (you receive). A wise ruler plans for both!
''',
          'kingdomAnalogy': '''
Think of funding rates like maintaining the kingdom's balance:

High Long Interest: Too many want to expand so expansion tax
High Short Interest: Too many expect war so defense tax  
Balanced Interest: Peaceful kingdom so no extra taxes

The funding system ensures no army becomes too dominant, keeping your kingdom's markets fair and efficient!
''',
        },
      ),
    ];
  }
}