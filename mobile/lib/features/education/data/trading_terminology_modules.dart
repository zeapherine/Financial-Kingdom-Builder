import '../models/lesson_content.dart';

class TradingTerminologyModules {
  static final List<LessonContent> modules = [
    // Module 1: Basic Trading Terms
    LessonContent(
      id: 'terms-001',
      title: 'Basic Trading Terms',
      description: 'Learn the fundamental trading vocabulary every investor needs to know.',
      type: LessonType.interactive,
      data: {
        'content': '''
Welcome to the royal treasury of trading knowledge! Every successful ruler must master the language of commerce.

**Essential Trading Terms:**

**Asset** 💎
Anything of value that can be owned or traded.
Examples: Stocks, bonds, real estate, gold, cryptocurrency

**Portfolio** 📁
Your collection of investments, like a royal treasury.
Think: A bag containing different types of valuable items.

**Liquidity** 💧
How quickly you can convert an investment to cash.
High liquidity = Easy to sell quickly (like stocks)
Low liquidity = Takes time to sell (like real estate)

**Volatility** 🌊
How much an investment's price moves up and down.
High volatility = Prices change dramatically
Low volatility = Prices are relatively stable

**Bull Market** 🐂
When prices are generally rising and investors are optimistic.
Think: A bull charges upward with its horns.

**Bear Market** 🐻
When prices are generally falling and investors are pessimistic.
Think: A bear swipes downward with its claws.
''',
        'interactionType': 'termDefinition',
        'parameters': {
          'terms': [
            {
              'term': 'Asset',
              'definition': 'Anything of value that can be owned or traded',
              'example': 'Stocks, bonds, real estate, cryptocurrency',
              'kingdomAnalogy': 'Like treasures in your royal vault'
            },
            {
              'term': 'Portfolio',
              'definition': 'Your collection of investments',
              'example': 'Mix of stocks, bonds, and other investments',
              'kingdomAnalogy': 'Your kingdom\'s complete treasury collection'
            },
            {
              'term': 'Liquidity',
              'definition': 'How quickly you can convert an investment to cash',
              'example': 'Stocks (high) vs Real Estate (low)',
              'kingdomAnalogy': 'How quickly you can access your royal funds'
            },
            {
              'term': 'Volatility',
              'definition': 'How much an investment\'s price fluctuates',
              'example': 'Cryptocurrency (high) vs Bonds (low)',
              'kingdomAnalogy': 'How stable your kingdom\'s wealth remains'
            }
          ]
        },
        'instructions': 'Tap on terms to see animated definitions and examples',
        'successMessage': 'Excellent! You now know the basic trading vocabulary.',
      },
      estimatedMinutes: 6,
    ),

    // Module 2: Order Types
    LessonContent(
      id: 'terms-002',
      title: 'Types of Trading Orders',
      description: 'Master different ways to buy and sell investments.',
      type: LessonType.interactive,
      data: {
        'content': '''
In your financial kingdom, you need different types of orders to execute trades effectively. Each order type serves a specific purpose.

**Market Order** ⚡
Buy or sell immediately at the current market price.
• Pros: Executes quickly, guaranteed fill
• Cons: Price might change before execution
• When to use: When you want to trade now at any reasonable price

**Limit Order** 🎯
Buy or sell only at a specific price or better.
• Pros: You control the price
• Cons: Might not execute if price does not reach your limit
• When to use: When you want to pay no more (or receive no less) than a specific price

**Stop-Loss Order** 🛑
Automatically sell when price falls to a certain level.
• Purpose: Limit losses on a declining investment
• How it works: Becomes a market order when stop price is hit
• When to use: To protect profits or limit losses

**Stop-Limit Order** 🎯🛑
Combines stop and limit orders for more control.
• How it works: When stop price is hit, becomes a limit order
• Advantage: More price control than stop-loss
• Risk: Might not execute in fast-moving markets

**Take-Profit Order** 🎉
Automatically sell when price rises to your target level.
• Purpose: Lock in profits when investment reaches your goal
• Strategy: Set realistic profit targets
• Benefit: Removes emotion from profit-taking decisions
''',
        'interactionType': 'orderSimulation',
        'parameters': {
          'scenarios': [
            {
              'stock': 'Royal Mining Corp',
              'currentPrice': 50,
              'scenario': 'You want to buy but only if price drops to \$45',
              'correctOrder': 'Limit Order',
              'explanation': 'Use a limit order to buy at \$45 or lower'
            },
            {
              'stock': 'Kingdom Tech',
              'currentPrice': 100,
              'scenario': 'You own shares and want to sell if price falls to \$90',
              'correctOrder': 'Stop-Loss Order',
              'explanation': 'Stop-loss will sell if price drops to \$90 to limit losses'
            },
            {
              'stock': 'Castle Foods',
              'currentPrice': 30,
              'scenario': 'You want to buy right now at whatever price',
              'correctOrder': 'Market Order',
              'explanation': 'Market order executes immediately at current price'
            }
          ]
        },
        'instructions': 'Choose the correct order type for each trading scenario',
        'successMessage': 'Perfect! You understand how to use different order types strategically.',
      },
      estimatedMinutes: 8,
    ),

    // Module 3: Market Fundamentals
    LessonContent(
      id: 'terms-003',
      title: 'Market Fundamentals',
      description: 'Understand key market concepts and how they affect trading.',
      type: LessonType.interactive,
      data: {
        'content': '''
To rule your financial kingdom wisely, you must understand the fundamental forces that move markets.

**Supply and Demand** ⚖️
The basic force that determines all prices.
• High Demand + Low Supply = Prices Rise 📈
• Low Demand + High Supply = Prices Fall 📉
• Example: More people want to buy a stock than sell it → Price goes up

**Bid and Ask** 💰
• Bid: Highest price someone is willing to pay to buy
• Ask: Lowest price someone is willing to accept to sell
• Spread: Difference between bid and ask prices
• Narrow spread: Very liquid, easy to trade
• Wide spread: Less liquid, harder to trade

**Volume** 📊
The number of shares traded in a given period.
• High Volume: Lots of trading activity, strong interest
• Low Volume: Little trading activity, less interest
• Volume + Price Movement: Confirms trend strength

**Market Cap** 👑
Total value of all company shares.
• Large Cap: 10+ billion dollars (stable, established companies)
• Mid Cap: 2-10 billion dollars (growing companies)
• Small Cap: 300M-2B dollars (smaller, potentially faster-growing)

**P/E Ratio** 🔍
Price-to-Earnings ratio measures if a stock is expensive.
• Formula: Stock Price ÷ Earnings Per Share
• High P/E: Stock might be overvalued or have high growth expectations
• Low P/E: Stock might be undervalued or have problems
• Industry Comparison: Compare P/E ratios within same industry

**Dividend** 💰
Regular payments some companies make to shareholders.
• Dividend Yield: Annual dividend ÷ Stock price
• Income Strategy: Some investors buy stocks mainly for dividends
• Growth vs Income: Growth companies often do not pay dividends
''',
        'interactionType': 'conceptQuiz',
        'parameters': {
          'concepts': [
            {
              'concept': 'Supply and Demand',
              'question': 'What happens when many people want to buy a stock but few want to sell?',
              'options': ['Price goes up', 'Price goes down', 'Price stays same', 'Trading stops'],
              'correct': 0,
              'explanation': 'High demand with low supply drives prices higher'
            },
            {
              'concept': 'Bid-Ask Spread',
              'question': 'A stock has bid \$10.50 and ask \$10.52. What is the spread?',
              'options': ['\$0.02', '\$0.50', '\$10.51', '\$21.02'],
              'correct': 0,
              'explanation': 'Spread = Ask - Bid = \$10.52 - \$10.50 = \$0.02'
            },
            {
              'concept': 'Market Cap',
              'question': 'A company with 1 million shares at \$50 per share has what market cap?',
              'options': ['\$1 million', '\$50 million', '\$500 million', '\$50 billion'],
              'correct': 1,
              'explanation': 'Market Cap = Shares × Price = 1M × \$50 = \$50 million'
            }
          ]
        },
        'instructions': 'Answer questions to test your understanding of market fundamentals',
        'successMessage': 'Outstanding! You grasp the fundamental concepts that drive markets.',
      },
      estimatedMinutes: 10,
    ),

    // Module 4: Advanced Trading Terms
    LessonContent(
      id: 'terms-004',
      title: 'Advanced Trading Concepts',
      description: 'Learn sophisticated trading terms for advanced strategies.',
      type: LessonType.interactive,
      data: {
        'content': '''
As your financial kingdom grows, you'll encounter more advanced concepts. Master these to trade like a seasoned ruler.

**Margin Trading** 🏦
Borrowing money from your broker to buy more securities.
• Leverage: Amplifies both gains and losses
• Margin Call: Broker demands more money if losses are too high
• Risk: Can lose more than your initial investment

**Short Selling** 📉
Betting that a stock price will fall.
• Process: Borrow shares → Sell them → Buy back later (hopefully cheaper)
• Profit: Make money when stock price drops
• Risk: Unlimited losses if stock price rises

**Options** 🎛️
Contracts giving the right (not obligation) to buy/sell at specific price.
• **Call Option**: Right to buy at specific price
• **Put Option**: Right to sell at specific price
• **Premium**: Cost to buy the option
• **Expiration**: Options have time limits

**Futures** 📅
Contracts to buy/sell something at a future date and price.
• **Commodities**: Oil, gold, wheat, etc.
• **Financial**: Stock indexes, currencies
• **Standardized**: Fixed sizes and dates
• **Leverage**: High potential gains and losses

**ETF (Exchange-Traded Fund)** 📦
Basket of securities that trades like a single stock.
• **Diversification**: Own many stocks in one purchase
• **Low Fees**: Usually cheaper than mutual funds
• **Liquidity**: Can trade during market hours
• **Types**: Index funds, sector funds, commodity funds

**IPO (Initial Public Offering)** 🎉
When a private company first sells shares to the public.
• **Going Public**: Company becomes publicly traded
• **Price Discovery**: Market determines fair value
• **Risk**: New companies can be very volatile
• **Lock-up Period**: Insiders can't sell immediately

**Beta** 📊
Measures how much a stock moves compared to the overall market.
• **Beta = 1**: Moves exactly with market
• **Beta > 1**: More volatile than market (higher risk/reward)
• **Beta < 1**: Less volatile than market (lower risk/reward)
• **Negative Beta**: Moves opposite to market (rare)
''',
        'interactionType': 'termMatching',
        'parameters': {
          'matches': [
            {
              'term': 'Margin Trading',
              'definition': 'Borrowing money to buy more securities',
              'risk': 'Can lose more than initial investment'
            },
            {
              'term': 'Short Selling',
              'definition': 'Betting that stock price will fall',
              'risk': 'Unlimited potential losses'
            },
            {
              'term': 'Options',
              'definition': 'Right to buy/sell at specific price',
              'risk': 'Can lose entire premium paid'
            },
            {
              'term': 'ETF',
              'definition': 'Basket of securities trading as one',
              'risk': 'Market risk but diversified'
            },
            {
              'term': 'Beta',
              'definition': 'Measures stock volatility vs market',
              'risk': 'High beta = higher volatility'
            }
          ]
        },
        'instructions': 'Match advanced trading terms with their definitions and risks',
        'successMessage': 'Excellent! You now understand advanced trading concepts.',
      },
      estimatedMinutes: 12,
    ),

    // Module 5: Risk and Psychology Terms
    LessonContent(
      id: 'terms-005',
      title: 'Risk and Psychology in Trading',
      description: 'Learn terms related to trading psychology and risk management.',
      type: LessonType.text,
      data: {
        'content': '''
The most important battle in trading happens in your mind. Understanding these psychological concepts will make you a wiser ruler of your financial kingdom.

**FOMO (Fear of Missing Out)** 😱
The anxiety that others are getting better returns.
• **Danger**: Leads to impulsive, poorly-researched investments
• **Solution**: Stick to your plan, don't chase hot tips
• **Remember**: There will always be another opportunity

**FUD (Fear, Uncertainty, and Doubt)** 😨
Negative emotions that can cause panic selling.
• **Sources**: News media, social media, market rumors
• **Effect**: Can cause good investors to make poor decisions
• **Defense**: Focus on facts, not emotions

**Diamond Hands** 💎🙌
Holding investments through volatility without selling.
• **Benefit**: Avoids selling during temporary downturns
• **Risk**: Might hold losing investments too long
• **Balance**: Know when to hold and when to fold

**Paper Hands** 📄🙌
Selling investments quickly, especially at first sign of trouble.
• **Problem**: Often sells at worst possible time
• **Cause**: Usually driven by fear or panic
• **Solution**: Develop emotional discipline

**HODL** 🏰
"Hold On for Dear Life" - long-term investment strategy.
• **Origin**: Originally a typo for "hold" in crypto forums
• **Philosophy**: Time in market beats timing the market
• **Strategy**: Buy and hold through market cycles

**Confirmation Bias** 🔍
Only seeking information that confirms what you already believe.
• **Danger**: Ignores warning signs and opposing views
• **Effect**: Poor investment decisions
• **Antidote**: Actively seek contrarian viewpoints

**Loss Aversion** 😰
The psychological tendency to fear losses more than value gains.
• **Impact**: People feel the pain of \$100 loss more than joy of \$100 gain
• **Trading Effect**: Leads to holding losers too long, selling winners too early
• **Management**: Use stop-losses and take-profit orders

**Sunk Cost Fallacy** ⛳
Continuing bad investment because you've already lost money.
• **Logic Error**: "I've lost \$1000, so I can't sell now"
• **Truth**: Past losses don't justify future bad decisions
• **Solution**: Evaluate each investment on current merits

**Overconfidence Bias** 🎭
Believing you're better at trading than you actually are.
• **Danger**: Taking excessive risks, overtrading
• **Common after**: Series of winning trades
• **Reality Check**: Track your actual performance vs market

**Market Timing** ⏰
Trying to predict when to buy and sell for maximum profit.
• **Appeal**: Seems like it should work
• **Reality**: Extremely difficult, even for professionals
• **Better Strategy**: Regular investing (dollar-cost averaging)

**The Golden Rules of Trading Psychology:**
1. Plan your trades, trade your plan
2. Don't let emotions drive decisions
3. Accept that losses are part of investing
4. Stay humble - markets are humbling
5. Focus on process, not just outcomes
''',
      },
      estimatedMinutes: 8,
    ),

    // Quiz Module
    LessonContent(
      id: 'terms-quiz',
      title: 'Trading Terminology Mastery Quiz',
      description: 'Test your knowledge of trading vocabulary and concepts.',
      type: LessonType.quiz,
      data: {
        'content': 'Test your trading terminology knowledge with this comprehensive quiz.',
        'questions': [
          {
            'question': 'What type of order would you use to buy a stock only if it drops to \$25 or lower?',
            'options': ['Market Order', 'Limit Order', 'Stop Order', 'Take-Profit Order'],
            'correctAnswer': 1,
            'explanation': 'A limit order lets you specify the maximum price you are willing to pay.',
            'kingdomMetaphor': 'Like telling your treasurer: "Only buy if the price is \$25 or better."',
          },
          {
            'question': 'What does high liquidity mean for an investment?',
            'options': ['High returns', 'Easy to buy/sell quickly', 'Low risk', 'High volatility'],
            'correctAnswer': 1,
            'explanation': 'High liquidity means you can easily convert the investment to cash quickly.',
            'kingdomMetaphor': 'Like having gold coins vs land - coins are easier to spend immediately.',
          },
          {
            'question': 'In a bull market, what is generally happening to prices?',
            'options': ['Falling', 'Rising', 'Staying flat', 'Becoming more volatile'],
            'correctAnswer': 1,
            'explanation': 'A bull market is characterized by generally rising prices and investor optimism.',
            'kingdomMetaphor': 'Like a prosperous time when your kingdom\'s wealth grows.',
          },
          {
            'question': 'What is FOMO in trading?',
            'options': ['Fear of Major Outflows', 'Fear of Missing Out', 'Financial Options Market Order', 'Fund Optimization Management Operation'],
            'correctAnswer': 1,
            'explanation': 'FOMO is Fear of Missing Out - the anxiety that others are getting better returns.',
            'kingdomMetaphor': 'Like worrying other kingdoms are getting richer faster than yours.',
          },
          {
            'question': 'What does a P/E ratio measure?',
            'options': ['Profit and Expenses', 'Price compared to Earnings', 'Portfolio Efficiency', 'Percentage Earnings'],
            'correctAnswer': 1,
            'explanation': 'P/E ratio is Price-to-Earnings ratio, measuring if a stock is expensive relative to its earnings.',
            'kingdomMetaphor': 'Like comparing the cost of buying a business to how much profit it makes.',
          },
        ],
      },
      estimatedMinutes: 10,
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