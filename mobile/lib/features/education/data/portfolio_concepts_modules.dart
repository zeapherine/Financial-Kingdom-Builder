import '../models/lesson_content.dart';

class PortfolioConceptsModules {
  static List<LessonContent> getPortfolioConceptsLessons() {
    return [
      // Lesson 1: Introduction to Portfolios
      LessonContent(
        id: 'pc-001',
        title: 'What is a Portfolio?',
        description: 'Learn the basics of investment portfolios with visual examples',
        type: LessonType.chart,
        estimatedMinutes: 8,
        learningObjectives: [
          'Understand what an investment portfolio is',
          'Learn the components of a portfolio',
          'See how portfolios work in practice',
        ],
        data: ChartLessonData(
          chartType: ChartType.pieChart,
          explanation: '''
Welcome to Portfolio Kingdom! 🏰

**What is a Portfolio?**
Think of your portfolio as your kingdom's various territories and assets. Just as a wise ruler wouldn't put all their resources in one place, smart investors don't put all their money in one investment!

**Portfolio Components:**

🏆 **Stocks (Equity Territory)**
These represent ownership in companies. Like owning shares in various businesses across your kingdom. Higher risk, higher potential reward.

🏛️ **Bonds (Treasury Bonds)**
These are loans you give to governments or companies. Like lending gold to other kingdoms for interest. Lower risk, steady returns.

🏪 **Real Estate (Property Kingdom)**
Physical properties that generate income. Like owning buildings and land in your kingdom that pay rent.

💰 **Cash & Cash Equivalents (Royal Treasury)**
Money kept readily available for emergencies and opportunities. Like your kingdom's immediate reserves.

🌾 **Commodities (Trade Goods)**
Physical goods like gold, oil, crops. Like your kingdom's trade in valuable resources.

**The Magic of Diversification:**
By spreading your wealth across different types of assets (territories), you protect your kingdom from disasters that might affect just one area. If one territory struggles, others might thrive!

**Visual Learning:**
The pie chart shows a balanced portfolio allocation. Notice how the wealth is spread across different asset types to minimize risk while maximizing growth potential.
          ''',
          chartData: {
            'portfolioAllocation': [
              {'category': 'Stocks', 'percentage': 40, 'amount': 40000, 'color': '#58CC02', 'description': 'Growth potential through company ownership'},
              {'category': 'Bonds', 'percentage': 25, 'amount': 25000, 'color': '#1CB0F6', 'description': 'Stable income through lending'},
              {'category': 'Real Estate', 'percentage': 20, 'amount': 20000, 'color': '#FF9600', 'description': 'Property and land investments'},
              {'category': 'Cash', 'percentage': 10, 'amount': 10000, 'color': '#FFC800', 'description': 'Emergency funds and opportunities'},
              {'category': 'Commodities', 'percentage': 5, 'amount': 5000, 'color': '#CE82FF', 'description': 'Physical goods and resources'},
            ],
            'riskLevels': [
              {'category': 'Stocks', 'risk': 'High', 'potential_return': '8-12%'},
              {'category': 'Bonds', 'risk': 'Low', 'potential_return': '3-6%'},
              {'category': 'Real Estate', 'risk': 'Medium', 'potential_return': '5-10%'},
              {'category': 'Cash', 'risk': 'Very Low', 'potential_return': '1-3%'},
              {'category': 'Commodities', 'risk': 'High', 'potential_return': '6-15%'},
            ],
          },
          keyTakeaways: [
            'A portfolio is a collection of different investments',
            'Diversification spreads risk across multiple asset types',
            'Different assets have different risk and return characteristics',
            'Balancing high and low risk investments creates stability',
            'Regular rebalancing maintains your desired allocation',
          ],
        ).toMap(),
      ),

      // Lesson 2: Portfolio Risk and Return
      LessonContent(
        id: 'pc-002',
        title: 'Risk vs Return: The Royal Balance',
        description: 'Understand the relationship between risk and return with interactive charts',
        type: LessonType.chart,
        estimatedMinutes: 10,
        learningObjectives: [
          'Learn the risk-return relationship',
          'Understand different risk levels',
          'See how to balance risk and return',
        ],
        data: ChartLessonData(
          chartType: ChartType.custom,
          explanation: '''
Every wise ruler must understand the eternal balance! ⚖️

**The Risk-Return Principle:**
In the financial kingdom, there's a fundamental law: higher potential returns usually come with higher risk. You can't get something for nothing!

**Understanding Risk Levels:**

🟢 **Low Risk (Safe Territories)**
- Government bonds, savings accounts
- Predictable returns but lower growth
- Like well-established, peaceful provinces

🟡 **Medium Risk (Developing Lands)**
- Balanced funds, dividend stocks
- Moderate growth with some volatility
- Like expanding into new but stable regions

🔴 **High Risk (Frontier Territories)**
- Growth stocks, startups, crypto
- High potential returns but high volatility
- Like exploring uncharted lands - great rewards but danger!

**Kingdom Wisdom:**
- Young rulers (investors) can take more risk - time heals wounds
- Older rulers need more stability - preserve wealth for the future
- Never risk more than you can afford to lose
- Diversification is your royal guard against catastrophe

**The Chart Shows:**
How different investment types sit on the risk-return spectrum. Higher up means more potential return, further right means more risk.
          ''',
          chartData: {
            'riskReturnScatter': [
              {'investment': 'Government Bonds', 'risk': 1, 'return': 3, 'color': '#1CB0F6'},
              {'investment': 'Corporate Bonds', 'risk': 2, 'return': 5, 'color': '#84D8FF'},
              {'investment': 'Dividend Stocks', 'risk': 4, 'return': 7, 'color': '#58CC02'},
              {'investment': 'Growth Stocks', 'risk': 6, 'return': 10, 'color': '#FF9600'},
              {'investment': 'Small Cap Stocks', 'risk': 7, 'return': 12, 'color': '#FFC800'},
              {'investment': 'Cryptocurrency', 'risk': 9, 'return': 15, 'color': '#CE82FF'},
              {'investment': 'Real Estate', 'risk': 3, 'return': 6, 'color': '#FF4B4B'},
            ],
            'portfolioTypes': [
              {'type': 'Conservative', 'stocks': 20, 'bonds': 60, 'cash': 20, 'expectedReturn': 4, 'risk': 'Low'},
              {'type': 'Moderate', 'stocks': 50, 'bonds': 35, 'cash': 15, 'expectedReturn': 7, 'risk': 'Medium'},
              {'type': 'Aggressive', 'stocks': 80, 'bonds': 15, 'cash': 5, 'expectedReturn': 10, 'risk': 'High'},
            ],
          },
          keyTakeaways: [
            'Higher potential returns typically mean higher risk',
            'Your age and goals determine your risk tolerance',
            'Diversification helps manage risk without sacrificing returns',
            'Conservative portfolios prioritize stability over growth',
            'Aggressive portfolios prioritize growth over stability',
          ],
        ).toMap(),
      ),

      // Lesson 3: Interactive Portfolio Builder
      LessonContent(
        id: 'pc-003',
        title: 'Build Your Royal Portfolio',
        description: 'Create and test different portfolio allocations with real-time feedback',
        type: LessonType.interactive,
        estimatedMinutes: 12,
        learningObjectives: [
          'Practice building portfolio allocations',
          'See how changes affect risk and return',
          'Understand portfolio optimization',
        ],
        data: InteractiveLessonData(
          interactionType: 'portfolio_builder',
          instructions: 'Use the sliders to allocate your 100,000 gold pieces across different asset types. Watch how your changes affect the portfolio\'s risk and expected return!',
          successMessage: 'Excellent! You\'ve created a well-balanced portfolio worthy of a wise ruler!',
          parameters: {
            'totalAmount': 100000,
            'assetTypes': [
              {'name': 'Stocks', 'minPercent': 0, 'maxPercent': 100, 'expectedReturn': 10, 'risk': 8, 'color': '#58CC02'},
              {'name': 'Bonds', 'minPercent': 0, 'maxPercent': 100, 'expectedReturn': 5, 'risk': 3, 'color': '#1CB0F6'},
              {'name': 'Real Estate', 'minPercent': 0, 'maxPercent': 50, 'expectedReturn': 7, 'risk': 5, 'color': '#FF9600'},
              {'name': 'Cash', 'minPercent': 0, 'maxPercent': 50, 'expectedReturn': 2, 'risk': 1, 'color': '#FFC800'},
              {'name': 'Commodities', 'minPercent': 0, 'maxPercent': 30, 'expectedReturn': 8, 'risk': 9, 'color': '#CE82FF'},
            ],
            'presetPortfolios': [
              {'name': 'Young Knight (20s-30s)', 'stocks': 70, 'bonds': 20, 'realestate': 5, 'cash': 5, 'commodities': 0},
              {'name': 'Seasoned Lord (40s-50s)', 'stocks': 50, 'bonds': 30, 'realestate': 15, 'cash': 5, 'commodities': 0},
              {'name': 'Wise Elder (60s+)', 'stocks': 30, 'bonds': 50, 'realestate': 10, 'cash': 10, 'commodities': 0},
            ],
            'explanation': '''
Portfolio Builder - Royal Edition! 👑

**How It Works:**
1. Drag the sliders to allocate your wealth
2. Watch the pie chart update in real-time
3. See how your allocation affects expected return and risk
4. Try the preset portfolios for different life stages

**Key Metrics:**
- **Expected Return**: Average annual growth you might expect
- **Risk Level**: How much your portfolio value might fluctuate
- **Sharpe Ratio**: Return per unit of risk (higher is better)

**Portfolio Rules:**
- Total allocation must equal 100%
- Each asset has limits based on typical recommendations
- Higher risk assets have higher potential returns

**Kingdom Wisdom:**
- Younger rulers can take more risk for growth
- Older rulers should prioritize capital preservation
- Regular rebalancing maintains your target allocation
- Don't put all your eggs in one basket!
            ''',
          },
        ).toMap(),
      ),

      // Lesson 4: Rebalancing Your Portfolio
      LessonContent(
        id: 'pc-004',
        title: 'Rebalancing: Maintaining Kingdom Order',
        description: 'Learn when and how to rebalance your portfolio with visual examples',
        type: LessonType.chart,
        estimatedMinutes: 7,
        learningObjectives: [
          'Understand what rebalancing means',
          'Learn when to rebalance',
          'See the benefits of regular rebalancing',
        ],
        data: ChartLessonData(
          chartType: ChartType.barChart,
          explanation: '''
Even the best-planned kingdoms need maintenance! 🔧

**What is Rebalancing?**
Rebalancing is like reorganizing your kingdom to maintain the right balance of resources. When some investments grow faster than others, your portfolio allocation changes from what you originally planned.

**Example: The Drift Problem**
Let's say you started with:
- 60% Stocks
- 40% Bonds

After a year, stocks performed really well (+20%) while bonds stayed flat (0%). Now your portfolio is:
- 67% Stocks (much higher!)
- 33% Bonds (much lower!)

**Why Rebalance?**

🎯 **Maintains Your Risk Level**
Prevents your portfolio from becoming riskier than intended.

💰 **Forces "Buy Low, Sell High"**
You sell assets that have grown (sell high) and buy assets that haven't (buy low).

⚖️ **Keeps You Disciplined**
Prevents emotional decisions based on market trends.

🛡️ **Risk Management**
Ensures you don't accidentally become over-concentrated in one asset.

**When to Rebalance:**
- Time-based: Every 6-12 months
- Threshold-based: When any asset drifts 5-10% from target
- Life event-based: When your goals or timeline changes

**How to Rebalance:**
1. Check your current allocation
2. Compare to your target allocation
3. Sell overweight assets
4. Buy underweight assets
5. Return to target allocation

The chart shows how different rebalancing strategies perform over time!
          ''',
          chartData: {
            'rebalancingExample': [
              {'period': 'Start', 'stocks': 60, 'bonds': 40, 'totalValue': 100000},
              {'period': 'After 1 Year', 'stocks': 67, 'bonds': 33, 'totalValue': 112000},
              {'period': 'After Rebalancing', 'stocks': 60, 'bonds': 40, 'totalValue': 112000},
              {'period': 'After 2 Years', 'stocks': 55, 'bonds': 45, 'totalValue': 119000},
              {'period': 'After Rebalancing', 'stocks': 60, 'bonds': 40, 'totalValue': 119000},
            ],
            'rebalancingStrategies': [
              {'strategy': 'Never Rebalance', 'return': 8.2, 'risk': 12.5, 'color': '#FF4B4B'},
              {'strategy': 'Annual Rebalancing', 'return': 8.7, 'risk': 11.2, 'color': '#58CC02'},
              {'strategy': 'Quarterly Rebalancing', 'return': 8.9, 'risk': 11.0, 'color': '#1CB0F6'},
              {'strategy': 'Monthly Rebalancing', 'return': 8.8, 'risk': 10.9, 'color': '#FFC800'},
            ],
          },
          keyTakeaways: [
            'Rebalancing maintains your intended asset allocation',
            'It forces you to sell high and buy low systematically',
            'Regular rebalancing often improves risk-adjusted returns',
            'Don\'t rebalance too frequently - costs can eat returns',
            'Set calendar reminders or use automated rebalancing',
          ],
        ).toMap(),
      ),

      // Lesson 5: Portfolio Quiz
      LessonContent(
        id: 'pc-005',
        title: 'Portfolio Mastery Test',
        description: 'Test your understanding of portfolio concepts and management',
        type: LessonType.quiz,
        estimatedMinutes: 6,
        learningObjectives: [
          'Reinforce portfolio management concepts',
          'Test practical portfolio decisions',
          'Gain confidence in portfolio planning',
        ],
        data: {
          'questions': [
            QuizQuestion(
              question: 'What is the primary benefit of diversification in a portfolio?',
              options: ['Higher returns', 'Lower taxes', 'Reduced risk', 'Faster growth'],
              correctAnswer: 2,
              explanation: 'Diversification\'s main benefit is reducing risk by spreading investments across different asset types. While it may not maximize returns, it helps protect against major losses.',
              kingdomMetaphor: 'A wise ruler doesn\'t put all their armies in one battlefield - spreading forces across territories protects the kingdom from total defeat!',
            ).toMap(),
            QuizQuestion(
              question: 'A 25-year-old investor should typically have what type of portfolio allocation?',
              options: ['Very conservative (20% stocks)', 'Moderate (50% stocks)', 'Aggressive (70-80% stocks)', 'All cash'],
              correctAnswer: 2,
              explanation: 'Young investors have a long time horizon and can weather market volatility. An aggressive allocation with 70-80% stocks allows for maximum growth potential.',
              kingdomMetaphor: 'Young rulers can take bold risks to expand their kingdom - they have time to recover from setbacks and build great wealth!',
            ).toMap(),
            QuizQuestion(
              question: 'When should you rebalance your portfolio?',
              options: ['Every week', 'When any asset drifts significantly from target', 'Only when markets crash', 'Never - let winners run'],
              correctAnswer: 1,
              explanation: 'Rebalance when assets drift significantly (typically 5-10%) from your target allocation, or on a regular schedule like annually.',
              kingdomMetaphor: 'A kingdom needs regular maintenance - you don\'t wait for the castle to crumble before fixing the walls!',
            ).toMap(),
            QuizQuestion(
              question: 'What happens if you never rebalance your portfolio?',
              options: ['Nothing - it\'s fine', 'It becomes riskier over time', 'You save on fees', 'You get better returns'],
              correctAnswer: 1,
              explanation: 'Without rebalancing, your portfolio can become much riskier than intended as winning assets grow to dominate your allocation.',
              kingdomMetaphor: 'A kingdom without maintenance becomes unbalanced - one prosperous city might grow too powerful while others are neglected!',
            ).toMap(),
            QuizQuestion(
              question: 'Which asset typically has the highest risk and potential return?',
              options: ['Government bonds', 'Cash savings', 'Growth stocks', 'Real estate'],
              correctAnswer: 2,
              explanation: 'Growth stocks typically offer the highest potential returns but also come with the highest risk and volatility.',
              kingdomMetaphor: 'Exploring new frontiers offers the greatest treasures but also the greatest dangers - high risk, high reward!',
            ).toMap(),
          ],
        },
      ),
    ];
  }
}