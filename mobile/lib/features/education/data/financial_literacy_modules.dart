import '../models/lesson_content.dart';

class FinancialLiteracyModules {
  static List<LessonContent> getFinancialLiteracyLessons() {
    return [
      // Lesson 1: Building Your Financial Foundation
      LessonContent(
        id: 'fl-001',
        title: 'Building Your Financial Foundation',
        description: 'Learn the basics of personal finance and why it matters for your kingdom',
        type: LessonType.text,
        estimatedMinutes: 7,
        learningObjectives: [
          'Understand what personal finance means',
          'Learn the importance of financial planning',
          'Discover how finance relates to kingdom building',
        ],
        data: {
          'content': '''
Welcome to your financial journey, future ruler! 👑

Just like building a strong kingdom requires a solid foundation, your financial success starts with understanding the basics.

**What is Personal Finance?**
Personal finance is simply managing your money - earning it, spending it wisely, saving it, and making it grow. Think of it as managing your kingdom's treasury!

**The Four Pillars of Financial Foundation:**

🏰 **Earning (Your Kingdom's Income)**
This is all the gold that flows into your treasury. In the real world, this could be from your job, business, or investments.

🛡️ **Spending (Kingdom Expenses)**
Every kingdom has expenses - maintaining your castle, feeding your people, defending your borders. Smart rulers spend wisely!

💰 **Saving (Your Emergency Reserves)**
Great rulers always keep gold in reserve for unexpected events - natural disasters, wars, or opportunities to expand.

⚔️ **Investing (Growing Your Wealth)**
The smartest rulers don't just hoard gold - they use it to create more wealth through trade, new territories, and business ventures.

**Kingdom Metaphor:**
Think of your finances like ruling a kingdom:
- Your income is like taxes collected from your lands
- Your expenses are like maintaining your army and infrastructure  
- Your savings are like your royal treasury reserves
- Your investments are like funding expeditions to discover new lands and trade routes

**Why This Matters:**
Without a strong financial foundation, even the mightiest kingdoms fall. But with smart money management, you can build an empire that lasts for generations!

Ready to start building your financial kingdom? Let's continue to the next lesson!
          ''',
          'kingdomAnalogy': 'Building a kingdom requires managing resources wisely - just like managing your personal finances!',
        },
      ),

      // Lesson 2: Understanding Income and Expenses
      LessonContent(
        id: 'fl-002',
        title: 'Income vs Expenses: Managing Your Kingdom\'s Flow',
        description: 'Learn how money flows in and out, with visual charts showing the balance',
        type: LessonType.chart,
        estimatedMinutes: 8,
        learningObjectives: [
          'Understand the difference between income and expenses',
          'Learn to categorize different types of income and expenses',
          'See how to balance your financial flow',
        ],
        data: ChartLessonData(
          chartType: ChartType.barChart,
          explanation: '''
Every kingdom must master the flow of resources! 💰

**Income Sources (Gold Flowing In):**
- Primary Income: Your main job (like ruling your kingdom)
- Secondary Income: Side gigs or part-time work (trading with neighboring kingdoms)
- Passive Income: Money that works while you sleep (renting out castle rooms)

**Expense Categories (Gold Flowing Out):**
- Essential Needs: Food, shelter, transportation (feeding your people, maintaining your castle)
- Kingdom Maintenance: Bills, insurance, taxes (army salaries, infrastructure)
- Growth Investments: Education, training, tools (expanding your kingdom)
- Royal Pleasures: Entertainment, dining out (castle feasts and tournaments)

**The Golden Rule:**
Income should always be greater than expenses. If your expenses exceed your income, your kingdom will eventually run out of gold!

**Visual Learning:**
The chart shows a typical monthly budget breakdown. Notice how smart rulers allocate their resources across different categories while always keeping some gold in reserve.
          ''',
          chartData: {
            'incomeData': [
              {'category': 'Primary Job', 'amount': 4000, 'color': '#58CC02'},
              {'category': 'Side Gig', 'amount': 800, 'color': '#89E219'},
              {'category': 'Investments', 'amount': 200, 'color': '#46A302'},
            ],
            'expenseData': [
              {'category': 'Housing', 'amount': 1200, 'color': '#FF4B4B'},
              {'category': 'Food', 'amount': 400, 'color': '#FF9600'},
              {'category': 'Transportation', 'amount': 300, 'color': '#FFC800'},
              {'category': 'Entertainment', 'amount': 200, 'color': '#CE82FF'},
              {'category': 'Savings', 'amount': 1000, 'color': '#1CB0F6'},
              {'category': 'Emergency Fund', 'amount': 500, 'color': '#84D8FF'},
            ],
          },
          keyTakeaways: [
            'Track all money coming into your kingdom (income)',
            'Categorize all money going out (expenses)',
            'Always aim to have income higher than expenses',
            'The difference becomes your savings and investment power',
          ],
        ).toMap(),
      ),

      // Lesson 3: The Power of Budgeting
      LessonContent(
        id: 'fl-003',
        title: 'The Royal Budget: Your Kingdom\'s Master Plan',
        description: 'Create and manage budgets with interactive budget planning tools',
        type: LessonType.interactive,
        estimatedMinutes: 10,
        learningObjectives: [
          'Learn how to create a budget',
          'Understand the 50/30/20 rule',
          'Practice budget allocation with interactive tools',
        ],
        data: InteractiveLessonData(
          interactionType: 'budget_planner',
          instructions: 'Use the sliders to allocate your monthly income across different categories. Try to follow the 50/30/20 rule!',
          successMessage: 'Excellent! You\'ve created a balanced budget worthy of a wise ruler!',
          parameters: {
            'monthlyIncome': 5000,
            'categories': [
              {'name': 'Needs (Housing, Food, Bills)', 'percentage': 50, 'color': '#FF4B4B', 'min': 40, 'max': 60},
              {'name': 'Wants (Entertainment, Dining)', 'percentage': 30, 'color': '#FFC800', 'min': 20, 'max': 40},
              {'name': 'Savings & Investments', 'percentage': 20, 'color': '#58CC02', 'min': 10, 'max': 30},
            ],
            'explanation': '''
The 50/30/20 Rule - A Royal Strategy:

🏰 **50% for Needs** (Kingdom Essentials)
These are expenses you can't avoid - rent, groceries, utilities, minimum debt payments. Just like a kingdom needs to maintain its walls and feed its people!

🎭 **30% for Wants** (Royal Pleasures)
This is for things that make life enjoyable but aren't essential - dining out, entertainment, hobbies. Every ruler deserves some luxuries!

💰 **20% for Savings & Investments** (Growing Your Wealth)
This builds your future empire - emergency fund, retirement savings, investments. This is how you expand your kingdom over time!

Remember: These are guidelines, not rigid laws. Adjust based on your kingdom's unique needs!
            ''',
          },
        ).toMap(),
      ),

      // Lesson 4: Emergency Funds - Your Castle's Defense
      LessonContent(
        id: 'fl-004',
        title: 'Emergency Funds: Defending Your Castle',
        description: 'Learn why emergency funds are crucial with visual scenarios',
        type: LessonType.chart,
        estimatedMinutes: 6,
        learningObjectives: [
          'Understand what an emergency fund is',
          'Learn how much to save for emergencies',
          'See real scenarios where emergency funds help',
        ],
        data: ChartLessonData(
          chartType: ChartType.custom,
          explanation: '''
Every wise ruler keeps emergency reserves! 🛡️

**What is an Emergency Fund?**
It's money set aside specifically for unexpected events - just like keeping extra soldiers and supplies in case your kingdom is attacked!

**How Much Should You Save?**
Most financial advisors recommend 3-6 months of expenses. If your monthly expenses are 3,000 gold pieces, aim for 9,000-18,000 gold pieces in your emergency fund.

**Common Emergencies:**
- Job loss (losing your kingdom's main income source)
- Medical expenses (healing potions can be expensive!)
- Car repairs (your royal carriage breaks down)
- Home repairs (castle roof needs fixing)
- Family emergencies (helping fellow royalty in need)

**Where to Keep Emergency Funds:**
- High-yield savings accounts (easily accessible but earning some interest)
- Money market accounts (slightly higher returns)
- NOT in investments (too risky - you need this money to be safe!)

**Building Your Emergency Fund:**
Start small! Even 500 gold pieces is better than nothing. Add to it gradually until you reach your goal.
          ''',
          chartData: {
            'emergencyScenarios': [
              {'scenario': 'Job Loss', 'probability': 15, 'cost': 12000, 'color': '#FF4B4B'},
              {'scenario': 'Medical Emergency', 'probability': 25, 'cost': 3000, 'color': '#FF9600'},
              {'scenario': 'Car Repair', 'probability': 40, 'cost': 1500, 'color': '#FFC800'},
              {'scenario': 'Home Repair', 'probability': 30, 'cost': 2500, 'color': '#1CB0F6'},
              {'scenario': 'Family Emergency', 'probability': 20, 'cost': 2000, 'color': '#CE82FF'},
            ],
            'fundProgressExample': [
              {'month': 1, 'amount': 500, 'goal': 15000},
              {'month': 3, 'amount': 1500, 'goal': 15000},
              {'month': 6, 'amount': 3000, 'goal': 15000},
              {'month': 12, 'amount': 6000, 'goal': 15000},
              {'month': 18, 'amount': 9000, 'goal': 15000},
              {'month': 24, 'amount': 12000, 'goal': 15000},
              {'month': 30, 'amount': 15000, 'goal': 15000},
            ],
          },
          keyTakeaways: [
            'Emergency funds protect your kingdom from unexpected events',
            'Aim for 3-6 months of expenses in your emergency fund',
            'Keep emergency money in safe, easily accessible accounts',
            'Build your emergency fund gradually - every gold piece counts!',
          ],
        ).toMap(),
      ),

      // Lesson 5: Quiz - Test Your Financial Knowledge
      LessonContent(
        id: 'fl-005',
        title: 'Royal Financial Wisdom Test',
        description: 'Test your understanding of financial basics with kingdom-themed questions',
        type: LessonType.quiz,
        estimatedMinutes: 5,
        learningObjectives: [
          'Reinforce key financial concepts learned',
          'Test understanding through practical scenarios',
          'Gain confidence in financial decision-making',
        ],
        data: {
          'questions': [
            QuizQuestion(
              question: 'What percentage of income should a wise ruler typically allocate to savings and investments?',
              options: ['10%', '20%', '30%', '50%'],
              correctAnswer: 1,
              explanation: 'The 50/30/20 rule suggests 20% for savings and investments. This builds your future wealth and expands your kingdom over time!',
              kingdomMetaphor: 'Just as a kingdom must invest in its future growth, you must invest in yours!',
            ).toMap(),
            QuizQuestion(
              question: 'How much should your emergency fund typically contain?',
              options: ['1 month of expenses', '3-6 months of expenses', '1 year of expenses', '2 years of income'],
              correctAnswer: 1,
              explanation: '3-6 months of expenses provides a solid safety net for most unexpected situations, like having enough supplies to survive a siege!',
              kingdomMetaphor: 'Your emergency fund is like your castle\'s emergency supplies - enough to survive tough times but not so much that it prevents growth.',
            ).toMap(),
            QuizQuestion(
              question: 'Which category does NOT belong in "essential needs" for budgeting?',
              options: ['Housing (rent/mortgage)', 'Groceries', 'Entertainment subscriptions', 'Transportation'],
              correctAnswer: 2,
              explanation: 'Entertainment subscriptions are "wants," not "needs." While they\'re nice to have, they\'re not essential for survival - unlike food, shelter, and transportation!',
              kingdomMetaphor: 'Royal entertainment is wonderful, but feeding your people and maintaining your castle comes first!',
            ).toMap(),
            QuizQuestion(
              question: 'What should you do if your expenses exceed your income?',
              options: ['Use credit cards to cover the difference', 'Ignore it and hope it gets better', 'Either increase income or decrease expenses', 'Borrow money from family'],
              correctAnswer: 2,
              explanation: 'You need to balance your kingdom\'s budget! Either find ways to bring in more gold (increase income) or reduce spending (decrease expenses).',
              kingdomMetaphor: 'A kingdom that spends more than it earns will eventually fall! Balance is key to long-term prosperity.',
            ).toMap(),
            QuizQuestion(
              question: 'Why is tracking your income and expenses important?',
              options: ['It\'s required by law', 'It helps you understand where your money goes', 'It\'s only for wealthy people', 'It\'s too complicated to be useful'],
              correctAnswer: 1,
              explanation: 'Tracking helps you see patterns and make informed decisions about your money. You can\'t manage what you don\'t measure!',
              kingdomMetaphor: 'A wise ruler always knows the state of their treasury - how much gold comes in, how much goes out, and where it all goes!',
            ).toMap(),
          ],
        },
      ),
    ];
  }
}