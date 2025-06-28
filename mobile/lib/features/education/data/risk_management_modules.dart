import '../models/lesson_content.dart';

class RiskManagementModules {
  static final List<LessonContent> modules = [
    // Module 1: Understanding Risk
    LessonContent(
      id: 'risk-001',
      title: 'Understanding Financial Risk',
      description: 'Learn what risk means in investing and how to identify different types of risk.',
      type: LessonType.text,
      data: {
        'content': '''
In the kingdom of finance, risk is like the weather - it's always present, but understanding it helps you prepare better.

**What is Financial Risk?**
Risk is the possibility that your investment might lose value or not perform as expected. Just like a kingdom faces threats from storms, droughts, or invaders, your investments face various risks.

**Why Risk Matters**
• Higher potential returns usually come with higher risk
• Understanding risk helps you make informed decisions
• Proper risk management protects your financial kingdom
• Risk tolerance varies from person to person

Think of risk like the moat around your castle - the deeper you understand it, the better you can protect your wealth.
''',
      },
      estimatedMinutes: 5,
    ),

    // Module 2: Types of Investment Risk
    LessonContent(
      id: 'risk-002',
      title: 'Types of Investment Risk',
      description: 'Explore different categories of risk that can affect your investments.',
      type: LessonType.interactive,
      data: {
        'content': '''
Different risks threaten your financial kingdom in different ways. Let's explore the main types:

**Market Risk** 🌊
The risk that entire markets decline, affecting most investments.
Example: During economic downturns, most stocks fall together.

**Company Risk** 🏢
Risk specific to individual companies or investments.
Example: A company's poor earnings affecting only its stock.

**Inflation Risk** 💰
The risk that rising prices reduce your purchasing power.
Example: If inflation is 3% but your savings earn 1%, you're losing purchasing power.

**Liquidity Risk** 🔒
The risk of not being able to sell an investment quickly.
Example: Real estate might take months to sell, while stocks sell instantly.

**Interest Rate Risk** 📈
Risk that changing interest rates affect investment values.
Example: When rates rise, bond prices typically fall.
''',
        'interactionType': 'riskAssessment',
        'parameters': {
          'scenarios': [
            {
              'title': 'Tech Stock During Market Crash',
              'risks': ['Market Risk', 'Company Risk'],
              'explanation': 'Both market-wide decline and company-specific risks apply'
            },
            {
              'title': 'Savings Account During Inflation',
              'risks': ['Inflation Risk'],
              'explanation': 'Low returns may not keep up with rising prices'
            },
            {
              'title': 'Real Estate Investment',
              'risks': ['Liquidity Risk', 'Interest Rate Risk'],
              'explanation': 'Hard to sell quickly and sensitive to rate changes'
            }
          ]
        },
        'instructions': 'Evaluate different investment scenarios for risk types',
        'successMessage': 'Great! You understand the different types of investment risk.',
      },
      estimatedMinutes: 7,
    ),

    // Module 3: Risk vs Return
    LessonContent(
      id: 'risk-003',
      title: 'The Risk-Return Relationship',
      description: 'Understand how risk and potential returns are connected in investing.',
      type: LessonType.chart,
      data: ChartLessonData(
        chartType: ChartType.custom,
        chartData: {
          'type': 'risk_return_scatter',
          'title': 'Risk vs Return by Asset Class',
          'xLabel': 'Risk Level (Volatility %)',
          'yLabel': 'Expected Annual Return %',
          'data': [
            {'name': 'Savings Account', 'risk': 0, 'return': 1, 'color': '#58CC02'},
            {'name': 'Government Bonds', 'risk': 5, 'return': 3, 'color': '#1CB0F6'},
            {'name': 'Corporate Bonds', 'risk': 8, 'return': 5, 'color': '#FFC800'},
            {'name': 'Balanced Fund', 'risk': 12, 'return': 7, 'color': '#FF9600'},
            {'name': 'Stock Fund', 'risk': 18, 'return': 10, 'color': '#FF4B4B'},
            {'name': 'Individual Stocks', 'risk': 25, 'return': 12, 'color': '#CE82FF'},
            {'name': 'Cryptocurrency', 'risk': 40, 'return': 15, 'color': '#777777'}
          ]
        },
        explanation: '''
In your financial kingdom, there's a fundamental law: **Higher Risk = Higher Potential Return**

This doesn't mean higher risk guarantees higher returns, but historically, riskier investments have offered higher potential rewards to compensate investors for taking on more risk.

**The Risk-Return Spectrum:**
• **Low Risk, Low Return**: Government bonds, savings accounts
• **Medium Risk, Medium Return**: Diversified stock funds, corporate bonds  
• **High Risk, High Return**: Individual stocks, cryptocurrency, startups

**Key Insights:**
1. **No Free Lunch**: You can't get high returns without accepting higher risk
2. **Compensation for Risk**: Higher potential returns compensate for uncertainty
3. **Personal Choice**: Your risk tolerance determines your investment mix
4. **Time Horizon Matters**: Longer investment periods can handle more volatility

Think of it like choosing your kingdom's defense strategy - safer approaches cost less but offer less expansion potential.
''',
        keyTakeaways: [
          'Higher risk typically comes with higher potential returns',
          'No investment strategy offers high returns without risk',
          'Your personal risk tolerance guides investment decisions',
          'Time horizon affects your ability to take on risk',
        ],
      ).toMap(),
      estimatedMinutes: 6,
    ),

    // Module 4: Risk Tolerance Assessment
    LessonContent(
      id: 'risk-004',
      title: 'Discovering Your Risk Tolerance',
      description: 'Learn to assess your personal risk tolerance and investment comfort level.',
      type: LessonType.interactive,
      data: {
        'content': '''
Every ruler has a different approach to risk. Some are bold conquerors, others are cautious defenders. Your risk tolerance depends on several factors:

**Factors Affecting Risk Tolerance:**

**Time Horizon** ⏰
• **Long-term (10+ years)**: Can handle more volatility
• **Medium-term (3-10 years)**: Moderate risk approach
• **Short-term (< 3 years)**: Lower risk is safer

**Financial Situation** 💼
• **Emergency fund**: More security = more risk capacity
• **Income stability**: Steady income = can handle more risk
• **Debts**: High debt = should take less risk

**Emotional Comfort** 😊
• How do you sleep when investments are down 20%?
• Can you stick to your plan during market crashes?
• Do you check your portfolio daily or monthly?

**Life Stage** 🎯
• **Young**: More time to recover from losses
• **Mid-career**: Balancing growth and stability
• **Near retirement**: Capital preservation becomes important

Your risk tolerance isn't permanent - it evolves as your life changes!
''',
        'interactionType': 'riskTolerance',
        'parameters': {
          'questions': [
            {
              'question': 'Your portfolio drops 20% in a month. What do you do?',
              'options': [
                {'text': 'Sell everything immediately', 'score': 1},
                {'text': 'Reduce risky investments', 'score': 2},
                {'text': 'Hold steady and wait', 'score': 3},
                {'text': 'Buy more at lower prices', 'score': 4}
              ]
            },
            {
              'question': 'How often do you check your investments?',
              'options': [
                {'text': 'Multiple times daily', 'score': 1},
                {'text': 'Once a day', 'score': 2},
                {'text': 'Weekly or monthly', 'score': 3},
                {'text': 'Quarterly or less', 'score': 4}
              ]
            },
            {
              'question': 'When do you need this money?',
              'options': [
                {'text': 'Within 2 years', 'score': 1},
                {'text': 'In 3-5 years', 'score': 2},
                {'text': 'In 6-10 years', 'score': 3},
                {'text': 'More than 10 years', 'score': 4}
              ]
            }
          ],
          'scoring': {
            '3-6': {'profile': 'Conservative', 'description': 'You prefer stability and capital preservation'},
            '7-9': {'profile': 'Moderate', 'description': 'You balance growth with some stability'},
            '10-12': {'profile': 'Aggressive', 'description': 'You are comfortable with volatility for higher returns'}
          }
        },
        'instructions': 'Answer questions to discover your risk profile',
        'successMessage': 'You have discovered your personal risk tolerance!',
      },
      estimatedMinutes: 8,
    ),

    // Module 5: Diversification
    LessonContent(
      id: 'risk-005',
      title: 'Diversification: Do not Put All Eggs in One Basket',
      description: 'Learn how diversification reduces risk without sacrificing returns.',
      type: LessonType.interactive,
      data: {
        'content': '''
"Don't put all your eggs in one basket" - this ancient wisdom is the foundation of smart risk management.

**What is Diversification?**
Diversification means spreading your investments across different assets, sectors, and geographic regions to reduce risk.

**How Diversification Works** 🛡️
When one investment performs poorly, others might perform well, balancing your overall portfolio.

**Types of Diversification:**

**Asset Class Diversification**
• Stocks, bonds, real estate, commodities
• Each asset class reacts differently to market events

**Geographic Diversification**  
• Domestic vs. international investments
• Reduces country-specific risks

**Sector Diversification**
• Technology, healthcare, finance, energy
• Different sectors perform well at different times

**Company Size Diversification**
• Large, medium, and small companies
• Different sizes have different risk profiles

**Time Diversification**
• Dollar-cost averaging (investing regularly over time)
• Reduces timing risk

**The Magic of Correlation**
When investments move in opposite directions (negative correlation), they provide better diversification benefits.
''',
        'interactionType': 'portfolioBuilder',
        'parameters': {
          'totalAmount': 10000,
          'assetClasses': [
            {'name': 'US Stocks', 'minPercent': 0, 'maxPercent': 100, 'risk': 'High'},
            {'name': 'International Stocks', 'minPercent': 0, 'maxPercent': 50, 'risk': 'High'},
            {'name': 'Bonds', 'minPercent': 0, 'maxPercent': 80, 'risk': 'Low'},
            {'name': 'Real Estate', 'minPercent': 0, 'maxPercent': 30, 'risk': 'Medium'},
            {'name': 'Cash', 'minPercent': 5, 'maxPercent': 50, 'risk': 'None'}
          ],
          'recommendations': {
            'Conservative': {'stocks': 30, 'bonds': 60, 'realestate': 5, 'cash': 5},
            'Moderate': {'stocks': 60, 'bonds': 30, 'realestate': 5, 'cash': 5},
            'Aggressive': {'stocks': 80, 'bonds': 10, 'realestate': 5, 'cash': 5}
          }
        },
        'instructions': 'Allocate investments across different asset classes',
        'successMessage': 'Excellent! You have built a diversified portfolio.',
      },
      estimatedMinutes: 7,
    ),

    // Module 6: Risk Management Strategies
    LessonContent(
      id: 'risk-006',
      title: 'Practical Risk Management Strategies',
      description: 'Learn specific techniques to manage and reduce investment risk.',
      type: LessonType.text,
      data: {
        'content': '''
Now that you understand risk, let's learn how to manage it like a wise ruler protecting their kingdom.

**Key Risk Management Strategies:**

**1. Position Sizing** ⚖️
• Never put more than 5-10% in any single investment
• Larger positions = higher risk if they fail
• Size positions based on conviction and risk

**2. Stop-Loss Orders** 🛑
• Automatically sell if an investment falls below a certain price
• Limits potential losses on individual positions
• Helps remove emotion from loss-cutting decisions

**3. Asset Allocation** 📊
• Divide investments between stocks, bonds, and other assets
• Rebalance periodically to maintain target percentages
• Age-based rules: 100 - your age = stock percentage

**4. Emergency Fund First** 🏦
• Keep 3-6 months of expenses in cash
• Prevents need to sell investments during emergencies
• Provides psychological comfort for taking investment risk

**5. Regular Monitoring** 👁️
• Review portfolio quarterly, not daily
• Look for major changes in fundamentals
• Avoid overtrading based on short-term movements

**6. Education and Research** 📚
• Understand what you're investing in
• Stay informed about market conditions
• Never invest in something you don't understand

**The Golden Rule**: Only invest money you can afford to lose and won't need for at least 5 years.
''',
      },
      estimatedMinutes: 6,
    ),

    // Quiz Module
    LessonContent(
      id: 'risk-quiz',
      title: 'Risk Management Mastery Quiz',
      description: 'Test your understanding of risk management principles.',
      type: LessonType.quiz,
      data: {
        'content': 'Test your risk management knowledge with this comprehensive quiz covering all the key concepts you have learned.',
        'questions': [
          {
            'question': 'What is the relationship between risk and potential return?',
            'options': [
              'Higher risk always guarantees higher returns',
              'Risk and return are completely unrelated', 
              'Higher potential returns typically require accepting higher risk',
              'Lower risk always provides better returns'
            ],
            'correctAnswer': 2,
            'explanation': 'Higher potential returns typically require accepting higher risk. This is fundamental principle of investing - you get compensated for taking on uncertainty.',
            'kingdomMetaphor': 'Like expanding your kingdom, greater rewards require taking greater risks.',
          },
          {
            'question': 'Which of these is NOT a type of investment risk?',
            'options': [
              'Market Risk',
              'Inflation Risk',
              'Guarantee Risk',
              'Liquidity Risk'
            ],
            'correctAnswer': 2,
            'explanation': 'Guarantee Risk is not a real type of investment risk. The main types include market, inflation, liquidity, interest rate, and company-specific risks.',
            'kingdomMetaphor': 'In the kingdom of finance, there are no guarantees, only calculated risks.',
          },
          {
            'question': 'What is diversification primarily designed to do?',
            'options': [
              'Maximize returns',
              'Reduce risk without necessarily sacrificing returns',
              'Eliminate all investment risk',
              'Increase portfolio complexity'
            ],
            'correctAnswer': 1,
            'explanation': 'Diversification is designed to reduce risk without necessarily sacrificing returns by spreading investments across different assets that do not move together.',
            'kingdomMetaphor': 'Like having multiple trade routes, diversification protects against any single path failing.',
          },
          {
            'question': 'For a young investor with 30+ years until retirement, which risk tolerance is typically most appropriate?',
            'options': [
              'Very conservative - mostly cash and bonds',
              'Conservative - mostly bonds with some stocks',
              'Moderate to aggressive - mostly stocks',
              'Risk tolerance does not matter for young investors'
            ],
            'correctAnswer': 2,
            'explanation': 'Young investors typically can afford moderate to aggressive risk tolerance because they have decades to recover from market downturns and benefit from compound growth.',
            'kingdomMetaphor': 'Young rulers have time to rebuild after setbacks, so they can afford bolder expansion strategies.',
          },
          {
            'question': 'What should you do BEFORE investing in riskier assets?',
            'options': [
              'Take out a loan to maximize investment amount',
              'Build an emergency fund of 3-6 months expenses',
              'Quit your job to focus on investing',
              'Invest all available money immediately'
            ],
            'correctAnswer': 1,
            'explanation': 'You should build an emergency fund before investing in riskier assets. This prevents you from having to sell investments during emergencies and provides peace of mind.',
            'kingdomMetaphor': 'A wise ruler ensures the castle supplies are stocked before venturing into new territories.',
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