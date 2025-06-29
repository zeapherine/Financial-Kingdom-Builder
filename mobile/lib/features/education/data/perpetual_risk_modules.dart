import '../models/lesson_content.dart';

class PerpetualRiskModules {
  static List<LessonContent> getPerpetualRiskLessons() {
    return [
      // Lesson 1: Overextension Risks (Liquidation explained)
      LessonContent(
        id: 'perp-risk-001',
        title: 'Overextension Risks',
        description: 'Learn about liquidation - the greatest threat to any trading kingdom',
        type: LessonType.interactive,
        estimatedMinutes: 10,
        learningObjectives: [
          'Understand what liquidation means and how it happens',
          'Learn to calculate liquidation prices',
          'Discover how to avoid liquidation disasters',
        ],
        data: {
          'interactionType': 'liquidation_calculator',
          'instructions': '''
Use our Kingdom Liquidation Calculator to see how different leverage levels 
affect your risk. Watch your liquidation price change as you adjust position size!
''',
          'parameters': {
            'startingBalance': 10000,
            'assetPrice': 40000,
            'leverageOptions': [2, 5, 10, 20],
            'positionSizes': [1000, 2500, 5000, 7500]
          },
          'explanation': '''
**What is Liquidation?**

Liquidation is when your position gets automatically closed because you've lost too much money. It's like losing a battle so badly that you must retreat to save what's left of your army!

**How Liquidation Works:**

When you use leverage, you're essentially borrowing gold from the exchange. If your losses get too close to the borrowed amount, the exchange automatically closes your position to prevent you from losing more than you have.

**Kingdom Analogy:**
You have 1,000 gold in your treasury
You borrow 4,000 gold to control a 5,000 gold position (5x leverage)
If your position loses 800 gold, you only have 200 gold left
The lender gets nervous and forces you to close the position to protect their 4,000 gold

**Liquidation Price Calculation:**
For a LONG position: **Liquidation Price = Entry Price × (1 - 1/Leverage)**
For a SHORT position: **Liquidation Price = Entry Price × (1 + 1/Leverage)**

**Examples:**
Long BTC at 40,000 dollars with 5x leverage: Liquidation at 32,000 dollars (20% drop)
Long BTC at 40,000 dollars with 10x leverage: Liquidation at 36,000 dollars (10% drop)
Short BTC at 40,000 dollars with 5x leverage: Liquidation at 48,000 dollars (20% rise)

**The Liquidation Death Spiral:**
1. Price moves against you
2. Your margin gets low
3. You might add more funds (emotional decision)
4. Price continues moving against you
5. Complete liquidation - you lose everything

**Kingdom Defense Strategies:**
🛡️ **Use Lower Leverage**: 2x-5x instead of 10x-20x
⚡ **Set Stop Losses**: Retreat before liquidation
💰 **Keep Reserves**: Never use 100% of your treasury
📊 **Monitor Constantly**: Watch your liquidation price
🧠 **Stay Calm**: Don't chase losses with more leverage
''',
        },
      ),

      // Lesson 2: Safe Territory Management (Position sizing)
      LessonContent(
        id: 'perp-risk-002',
        title: 'Safe Territory Management',
        description: 'Master the art of position sizing to protect your kingdom',
        type: LessonType.chart,
        estimatedMinutes: 11,
        learningObjectives: [
          'Learn the 1% and 2% position sizing rules',
          'Understand risk-reward ratios',
          'Calculate optimal position sizes for different strategies',
        ],
        data: {
          'chartType': 'ChartType.barChart',
          'explanation': '''
Position sizing is like deciding how many soldiers to send into each battle. Send too many, and a single defeat could destroy your entire kingdom. Send too few, and you'll never achieve great victories.

**The Golden Rules of Position Sizing:**

**1% Rule (Conservative Kingdoms):**
Never risk more than 1% of your total treasury on a single trade.
Treasury: 10,000 dollars → Max risk per trade: 100 dollars
This means you can survive 100 consecutive losses!

**2% Rule (Moderate Kingdoms):**
Risk up to 2% of your treasury on high-confidence trades.
Treasury: 10,000 dollars → Max risk per trade: 200 dollars
This allows for 50 consecutive losses before bankruptcy

**Position Sizing Formula:**
**Position Size = (Account Balance × Risk %) ÷ (Entry Price - Stop Loss Price)**

**Kingdom Examples:**

**Conservative Lord** (1% risk):
- Treasury: 10,000 dollars
- Risk per trade: 100 dollars
- Long BTC at 40,000 dollars, stop loss at 38,000 dollars
- Position size: 100 dollars ÷ 2,000 dollars = 0.05 BTC

**Aggressive General** (2% risk):
- Treasury: 10,000 dollars  
- Risk per trade: 200 dollars
- Long BTC at 40,000 dollars, stop loss at 38,000 dollars
- Position size: 200 dollars ÷ 2,000 dollars = 0.1 BTC

**Risk-Reward Ratios:**
**1:1 Ratio**: Risk 100 dollars to make 100 dollars
**1:2 Ratio**: Risk 100 dollars to make 200 dollars (Preferred)
**1:3 Ratio**: Risk 100 dollars to make 300 dollars (Excellent)

**Position Sizing by Experience Level:**
• **Rookie Ruler**: 0.5% risk, 2x leverage max
• **Seasoned Lord**: 1% risk, 5x leverage max
• **Master General**: 2% risk, 10x leverage max
• **Legendary Emperor**: 3% risk, 20x leverage max (VERY RARE)
''',
          'chartData': {
            'riskLevels': [
              {'level': 'Conservative', 'riskPercent': 1, 'survivability': 100, 'growthPotential': 'Slow'},
              {'level': 'Moderate', 'riskPercent': 2, 'survivability': 50, 'growthPotential': 'Steady'},
              {'level': 'Aggressive', 'riskPercent': 5, 'survivability': 20, 'growthPotential': 'Fast'},
              {'level': 'Extreme', 'riskPercent': 10, 'survivability': 10, 'growthPotential': 'Very Fast'}
            ]
          },
          'keyTakeaways': [
            'Position size determines your kingdom\'s survival',
            'Risk 1-2% per trade for long-term success',
            'Higher risk = faster growth but lower survivability',
            'Adjust position size based on confidence level',
            'Always calculate your risk before entering any battle'
          ],
        },
      ),

      // Lesson 3: Emergency Retreats (Stop losses)
      LessonContent(
        id: 'perp-risk-003',
        title: 'Emergency Retreats',
        description: 'Learn when and how to retreat from losing trades',
        type: LessonType.text,
        estimatedMinutes: 8,
        learningObjectives: [
          'Understand the importance of stop-loss orders',
          'Learn different types of stop-loss strategies',
          'Master the psychology of cutting losses',
        ],
        data: {
          'content': '''
Even the greatest generals know when to retreat. In trading, this wisdom is called "stop-loss orders" - your automated retreat system! 🏃‍♂️

**What is a Stop-Loss?**
A stop-loss is like having a trusted advisor who automatically orders a retreat when the battle turns too costly. It closes your position at a predetermined loss level.

**Why Stop-Losses are Essential:**
🧠 **Removes Emotion**: No hoping, praying, or "diamond hands" mentality
⚡ **Limits Damage**: Small losses instead of catastrophic ones
💤 **Works 24/7**: Protects you even when you're sleeping
📈 **Preserves Capital**: Live to fight another day

**Types of Stop-Loss Orders:**

**1. Fixed Stop-Loss (Traditional Retreat)**
Set a specific price level: "Close if BTC drops to 38,000 dollars"
Simple, reliable, but can be triggered by temporary spikes

**2. Trailing Stop-Loss (Strategic Withdrawal)**
Follows the price up but stays fixed on the downside
Example: "Stay 2,000 dollars below the highest price reached"
Lets profits run while protecting gains

**3. Percentage Stop-Loss (Kingdom Tax)**
Set as a percentage: "Close if I lose 5% on this position"
Easy to calculate and consistent across all trades

**Kingdom Stop-Loss Strategies:**

🏰 **The Fortress Strategy** (Tight stops: 2-3%):
- Quick retreats to minimize losses
- More frequent trades, smaller losses
- Good for volatile markets

⚔️ **The Campaign Strategy** (Wide stops: 5-8%):
- Give trades room to breathe
- Fewer trades, potentially larger losses
- Good for trending markets

🛡️ **The Siege Strategy** (Mental stops):
- No automatic order, manual decision
- Requires discipline and constant monitoring
- For experienced traders only

**Stop-Loss Placement Rules:**

**Technical Levels:**
• Below support levels for longs
• Above resistance levels for shorts
• Beyond key moving averages

**Volatility-Based:**
• Use Average True Range (ATR)
• Place stops 1.5-2x ATR away
• Adapts to market conditions

**Kingdom Wisdom for Stop-Losses:**
✅ **Always set before entering**: Decide retreat point during planning, not panic
✅ **Stick to your plan**: Don't move stops against you
✅ **Size positions accordingly**: Stop distance determines position size
❌ **Never remove stops**: This leads to liquidation disasters
❌ **Don't move stops closer**: Let your original plan play out
''',
          'kingdomAnalogy': '''
Think of stop-losses like having watchtowers around your kingdom:

🗼 **Early Warning System**: Alerts you when enemies approach
⚔️ **Automatic Defense**: Activates defenses without your constant attention
🏰 **Protects the Treasury**: Ensures you don't lose everything in one battle
🛡️ **Strategic Retreat**: Preserves your army for the next campaign

A kingdom without stop-losses is like a castle without walls - it might survive good times, but it will fall when storms come!
''',
        },
      ),

      // Lesson 4: Kingdom Survival Rules (Risk management)
      LessonContent(
        id: 'perp-risk-004', 
        title: 'Kingdom Survival Rules',
        description: 'Master the fundamental rules that separate surviving kingdoms from fallen empires',
        type: LessonType.text,
        estimatedMinutes: 12,
        learningObjectives: [
          'Learn the core risk management principles',
          'Understand proper trading psychology',
          'Develop a personal risk management plan',
        ],
        data: {
          'content': '''
These are the sacred laws that have protected trading kingdoms for centuries. Follow them, and your kingdom will endure. Ignore them, and join the countless fallen empires! 👑

**The 10 Sacred Laws of Kingdom Survival:**

**1. The Law of Capital Preservation** 💰
"Your first goal is not to make money, but to not lose money."
• Never risk more than you can afford to lose completely
• Treat each trade as potentially your last
• Capital preservation > profit maximization

**2. The Law of Diversification** 🌍
"Never put all your armies in one battlefield."
• Don't risk everything on Bitcoin alone
• Spread risk across different assets and strategies
• Geographic and temporal diversification

**3. The Law of Leverage Restraint** "Great power requires great responsibility."
• Start with 2x-5x leverage maximum
• Higher leverage only with proven skill
• Remember: Leverage magnifies both wisdom and folly

**4. The Law of Emotional Discipline** 🧘‍♂️
"Fear and greed destroy more kingdoms than any army."
• Never trade when angry, scared, or euphoric
• Take breaks after big wins or losses
• Have a trading plan and stick to it

**5. The Law of Risk-Reward Balance** "Never risk 2 dollars to make 1 dollar."
Minimum 1:2 risk-reward ratio
Higher probability trades can accept 1:1
Always know your exit before entering

**6. The Law of Stop-Loss Discipline** "A small retreat today prevents a big defeat tomorrow."
• Always set stops before entering trades
• Never move stops against you
• Accept small losses gracefully

**7. The Law of Position Sizing** "Size your battles according to your confidence and treasury."
• Risk 1-2% per trade maximum
• Larger positions only for highest conviction plays
• Position size determines survival time

**8. The Law of Market Respect** 🙏
"The market is always right, even when it's wrong."
• Don't fight obvious trends
• Accept that you can't predict everything
• Adapt to market conditions, don't force your will

**9. The Law of Continuous Learning** 📚
"Every trade teaches a lesson - learn it."
• Keep a trading journal
• Review both wins and losses
• Study market cycles and patterns

**10. The Law of Long-Term Perspective** 🔮
"Build an empire, not just win battles."
• Focus on consistent profitability, not home runs
• Compound gains over time
• Think in years, not days

**The Trading Kingdom Checklist:**
Before every trade, ask yourself:

✅ Have I defined my risk (stop-loss)?
✅ Is my position size appropriate (1-2% risk)?
✅ Do I have a clear profit target?
✅ Am I emotionally stable?
✅ Does this fit my overall strategy?
✅ Can I afford to lose this amount?

**Emergency Kingdom Protocols:**

🚨 **If you lose 10% of your treasury in a day**: Stop trading for 24 hours
🚨 **If you lose 20% in a week**: Stop trading for 1 week, review everything
🚨 **If you lose 30% in a month**: Stop trading for 1 month, get education

**The Psychology of Survival:**
• **Overconfidence** kills more traders than bad luck
• **FOMO** (Fear of Missing Out) leads to poor entries
• **Revenge trading** after losses compounds mistakes
• **Analysis paralysis** prevents taking good opportunities

**Kingdom Wisdom:**
Remember, you're not just trading - you're building a financial empire that should last for generations. Every decision should be made with the long-term prosperity of your kingdom in mind.

The crypto markets will always be here tomorrow. Make sure you are too! 🏰
''',
          'kingdomAnalogy': '''
Think of risk management like the fundamental laws that govern a successful kingdom:

🏰 **Constitution**: Core rules that never change (position sizing, stop-losses)
👑 **Royal Advisors**: Risk management tools and systems  
⚖️ **Justice System**: Consistent application of rules
🛡️ **Defense Strategy**: Protection against external threats
📜 **Historical Records**: Learning from past kingdoms (trading journal)

A kingdom without these foundations may prosper briefly, but it will inevitably fall to those who follow the timeless principles of survival and growth!
''',
        },
      ),
    ];
  }
}