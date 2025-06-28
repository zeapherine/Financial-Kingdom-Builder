import '../models/lesson_content.dart';

class BuildingPermitModules {
  static final List<LessonContent> modules = [
    // Module 1: Understanding Building Permits (Financial Prerequisites)
    LessonContent(
      id: 'permit-001',
      title: 'Understanding Financial Building Permits',
      description: 'Learn why financial education is like getting building permits for your kingdom.',
      type: LessonType.interactive,
      data: {
        'content': '''
In your financial kingdom, every wise ruler knows that you cannot build anything substantial without proper permits. Financial education works the same way!

**What are Financial Building Permits?** 🏗️
Just like construction permits in the real world, financial "permits" are the knowledge and skills you need before attempting complex financial maneuvers.

**Why Building Permits Matter:**

**Safety First** 🦺
• Physical building permits ensure structures will not collapse
• Financial permits (education) ensure your wealth will not collapse
• Both protect you and others from dangerous mistakes
• Kingdom Analogy: You would not let someone build a bridge without knowing engineering

**Legal Requirements** ⚖️
• Real construction requires permits before starting
• Financial activities have legal requirements too
• Some investments require specific knowledge or income levels
• Understanding regulations protects you from violations

**Quality Standards** ✨
• Building permits ensure structures meet minimum standards
• Financial education ensures your strategies meet basic competency standards
• Both prevent costly mistakes and rebuilding later
• Professional standards protect everyone in the community

**Progressive Complexity** 📈
• You start with simple buildings before attempting skyscrapers
• You start with basic investments before attempting complex trading
• Each level requires demonstrating competency at the previous level
• Kingdom Rule: Master simple structures before attempting grand architecture

**The Financial Building Permit System:**
1. **Foundation Permit**: Basic financial literacy
2. **Framing Permit**: Understanding risk and return
3. **Electrical Permit**: Market mechanics and terminology
4. **Plumbing Permit**: Cash flow and budgeting
5. **Finishing Permit**: Advanced investment strategies
6. **Occupancy Permit**: Ready for real money investing
''',
        'interactionType': 'permitExplorer',
        'parameters': {
          'permits': [
            {
              'name': 'Foundation Permit',
              'description': 'Basic financial literacy and money management',
              'requirements': ['Understand budgeting', 'Know income vs expenses', 'Emergency fund concept'],
              'buildingAnalogy': 'Like pouring concrete foundation - everything else depends on this',
              'unlocks': 'Savings accounts, basic budgeting tools'
            },
            {
              'name': 'Framing Permit',
              'description': 'Risk and return fundamentals',
              'requirements': ['Risk tolerance assessment', 'Diversification basics', 'Time horizon planning'],
              'buildingAnalogy': 'Like erecting the main structure - gives shape to your financial plan',
              'unlocks': 'Index funds, basic portfolio allocation'
            },
            {
              'name': 'Electrical Permit',
              'description': 'Market mechanics and trading terminology',
              'requirements': ['Market terminology', 'Order types', 'Basic analysis'],
              'buildingAnalogy': 'Like wiring the house - connects all parts and powers your strategy',
              'unlocks': 'Individual stock selection, market orders'
            },
            {
              'name': 'Plumbing Permit',
              'description': 'Cash flow management and liquidity',
              'requirements': ['Cash flow analysis', 'Liquidity planning', 'Tax implications'],
              'buildingAnalogy': 'Like installing plumbing - ensures smooth flow of resources',
              'unlocks': 'Advanced portfolio management, tax-advantaged accounts'
            }
          ]
        },
        'instructions': 'Explore each permit level to understand the progressive education system',
        'successMessage': 'Excellent! You understand why financial education follows a building permit system.',
      },
      estimatedMinutes: 8,
    ),

    // Module 2: Foundation Permit Requirements
    LessonContent(
      id: 'permit-002',
      title: 'Foundation Permit: Building Your Financial Base',
      description: 'Master the fundamental skills needed for all future financial construction.',
      type: LessonType.interactive,
      data: {
        'content': '''
Just as every magnificent castle starts with a solid foundation, your financial kingdom requires fundamental knowledge before building wealth.

**Foundation Permit Requirements** 🏗️

**1. Income vs Expenses Mastery** 💰
Understanding where money comes from and where it goes.
• Track all income sources
• Categorize all expenses
• Identify spending patterns
• Find opportunities to optimize
• Build positive cash flow

**2. Emergency Fund Construction** 🛡️
Building your financial safety net before taking risks.
• 3-6 months of expenses saved
• Separate from investment accounts
• Easily accessible (high liquidity)
• Acts as foundation stabilizer
• Prevents need to sell investments during emergencies

**3. Debt Management Framework** 📋
Understanding and controlling debt before building wealth.
• High-interest debt elimination priority
• Good debt vs bad debt distinction
• Debt-to-income ratio management
• Payment strategy optimization
• Credit score improvement

**4. Basic Banking and Account Management** 🏦
Setting up proper financial infrastructure.
• Checking account optimization
• Savings account strategy
• Understanding fees and terms
• Online banking security
• Account organization systems

**Foundation Inspection Checklist** ✅
Before receiving your Foundation Permit, you must demonstrate:

□ Monthly budget creation and tracking
□ Emergency fund of at least 1000 dollars established
□ High-interest debt payment plan in action
□ Basic banking accounts properly set up
□ Understanding of compound interest concept
□ Ability to calculate net worth
□ Knowledge of basic financial terminology

**Common Foundation Failures** ⚠️
• Trying to invest before eliminating high-interest debt
• No emergency fund while taking investment risks
• Inconsistent income and expense tracking
• Using credit cards to fund investments
• Skipping basic financial account setup

**Kingdom Wisdom**: "A castle built on sand will fall, but one built on stone will stand forever. Your financial foundation must be rock-solid before adding higher levels."
''',
        'interactionType': 'foundationBuilder',
        'parameters': {
          'checklistItems': [
            {
              'category': 'Budgeting',
              'tasks': ['Create monthly budget', 'Track expenses for 30 days', 'Identify 3 spending optimizations'],
              'points': 25
            },
            {
              'category': 'Emergency Fund',
              'tasks': ['Open high-yield savings', 'Save first 500 dollars', 'Set up automatic transfers'],
              'points': 30
            },
            {
              'category': 'Debt Management',
              'tasks': ['List all debts', 'Calculate debt-to-income ratio', 'Create payment priority plan'],
              'points': 25
            },
            {
              'category': 'Banking Setup',
              'tasks': ['Optimize checking account', 'Set up savings account', 'Enable online banking security'],
              'points': 20
            }
          ],
          'passingScore': 80,
          'certification': 'Foundation Permit Certified'
        },
        'instructions': 'Complete all foundation requirements to earn your Foundation Permit',
        'successMessage': 'Congratulations! You have earned your Foundation Permit and can begin building wealth.',
      },
      estimatedMinutes: 10,
    ),

    // Module 3: Framing Permit - Risk and Structure
    LessonContent(
      id: 'permit-003',
      title: 'Framing Permit: Building Your Risk Framework',
      description: 'Learn to construct a solid risk management framework for your investments.',
      type: LessonType.interactive,
      data: {
        'content': '''
With your foundation solid, it is time to frame your financial structure. The framing determines the shape, strength, and capacity of your entire financial building.

**Framing Permit Requirements** 🏗️

**1. Risk Assessment Blueprint** 📐
Understanding your personal risk capacity and tolerance.
• Personal risk tolerance questionnaire
• Financial capacity for risk assessment
• Time horizon planning (short, medium, long-term)
• Goal-based risk allocation
• Regular risk review schedule

**2. Diversification Framework** 🌈
Building a structure that can weather any storm.
• Asset class diversification principles
• Geographic diversification strategy
• Sector diversification planning
• Time diversification (dollar-cost averaging)
• Correlation understanding between assets

**3. Portfolio Architecture** 🏛️
Designing the structure of your investment portfolio.
• Strategic asset allocation planning
• Age-based allocation guidelines
• Risk-adjusted return expectations
• Rebalancing schedule and triggers
• Tax-efficient account placement

**4. Risk Management Tools** 🔧
Installing safety systems in your financial structure.
• Stop-loss order understanding
• Position sizing principles
• Portfolio insurance concepts
• Hedging strategy basics
• Emergency exit procedures

**Framing Inspection Points** 🔍
Your structure must pass these safety checks:

□ Risk tolerance assessment completed
□ Diversification strategy documented
□ Asset allocation plan created
□ Understanding of correlation effects
□ Rebalancing procedures established
□ Risk management tools identified
□ Emergency procedures defined

**Structural Engineering Principles** ⚖️

**Load Distribution**
• No single investment carries too much weight
• Risk spread across multiple support points
• Stress testing under various market conditions
• Redundancy in case of individual failures

**Flexibility with Strength**
• Structure can bend without breaking during market storms
• Regular maintenance and adjustment capability
• Adaptation to changing life circumstances
• Growth capacity for future expansion

**Building Code Compliance**
• Following established investment principles
• Meeting regulatory requirements
• Adhering to fiduciary standards
• Maintaining ethical investment practices

**Common Framing Mistakes** ❌
• Over-concentrating in one asset class or stock
• Ignoring correlation between supposedly diverse investments
• Setting inappropriate risk levels for time horizon
• Failing to plan for rebalancing
• Not stress-testing the portfolio design

**Kingdom Engineering Wisdom**: "A well-framed structure can support tremendous weight and weather any storm. Poor framing will collapse under the first real test."
''',
        'interactionType': 'framingBuilder',
        'parameters': {
          'riskAssessment': {
            'timeHorizon': ['< 5 years', '5-10 years', '10-20 years', '20+ years'],
            'riskTolerance': ['Conservative', 'Moderate', 'Aggressive'],
            'capacity': ['Low', 'Medium', 'High']
          },
          'allocationTemplates': {
            'Conservative': {'stocks': 30, 'bonds': 60, 'alternatives': 10},
            'Moderate': {'stocks': 60, 'bonds': 30, 'alternatives': 10},
            'Aggressive': {'stocks': 80, 'bonds': 10, 'alternatives': 10}
          },
          'diversificationRules': [
            'No more than 10% in any single stock',
            'At least 3 different asset classes',
            'Geographic diversification across regions',
            'Sector limits of 20% maximum'
          ]
        },
        'instructions': 'Design your portfolio framework to earn your Framing Permit',
        'successMessage': 'Excellent! Your portfolio framework is structurally sound. Framing Permit granted.',
      },
      estimatedMinutes: 12,
    ),

    // Module 4: Electrical Permit - Market Connections
    LessonContent(
      id: 'permit-004',
      title: 'Electrical Permit: Connecting to Market Systems',
      description: 'Learn to safely connect to market systems and power your investment strategy.',
      type: LessonType.text,
      data: {
        'content': '''
With foundation and framing complete, you need electrical systems to power your financial building. This permit focuses on safely connecting to market systems.

**Electrical Permit Requirements** ⚡

**1. Market Circuit Understanding** 🔌
Learning how financial markets are wired and connected.
• Stock exchange operations and hours
• Market maker vs electronic trading systems
• Circuit breaker mechanisms during extreme volatility
• After-hours trading risks and limitations
• Market holidays and settlement cycles

**2. Order Execution Wiring** 🔧
Understanding how your trading orders flow through the system.
• Market order execution priority and timing
• Limit order queue mechanics
• Stop order trigger mechanisms
• Order routing and best execution requirements
• Transaction cost analysis and impact

**3. Information Flow Networks** 📡
Connecting to reliable data sources and avoiding bad wiring.
• Real-time vs delayed market data
• Earnings reports and financial statement analysis
• Economic calendar and market-moving events
• Reliable news sources vs market rumors
• Social media influence and sentiment analysis

**4. Safety Systems and Circuit Breakers** 🛡️
Installing protection against electrical fires (major losses).
• Personal circuit breakers: position sizing limits
• Account-level protection: stop-loss automation
• Market-level protection: understanding trading halts
• Emotional circuit breakers: cooling-off periods
• Emergency shutdown procedures for major losses

**Electrical Code Compliance** 📋
Your market connections must meet these safety standards:

**Proper Grounding** 🌍
• Understanding market fundamentals grounds your decisions
• Economic principles provide stable reference points
• Historical market context prevents emotional overreactions
• Fundamental analysis grounds valuation expectations

**Overload Protection** ⚠️
• Position sizing prevents account overload
• Diversification prevents concentration overload
• Risk management prevents leverage overload
• Cooling-off periods prevent emotional trading overload

**Regular Inspection and Maintenance** 🔍
• Monthly portfolio review and rebalancing
• Quarterly performance analysis and adjustment
• Annual strategy review and optimization
• Continuous education and skill updating

**Common Electrical Hazards** ⚡
• Information overload leading to analysis paralysis
• Hot tips and rumors causing dangerous short circuits
• Leveraged positions creating fire hazards
• Emotional trading causing power surges
• Ignoring circuit breakers during market stress

**Professional Electrician Standards** 👷
• Following established trading principles and ethics
• Using properly rated tools and platforms
• Maintaining detailed logs of all electrical work (trades)
• Regular safety training and certification updates
• Working within licensed capacity and knowledge limits

**Power Management Best Practices** 💡
• Never exceed your electrical capacity (risk tolerance)
• Use surge protectors (stop-losses) on valuable equipment
• Have backup power systems (emergency funds) ready
• Regular testing of safety systems and procedures
• Professional consultation for complex installations

**Kingdom Electrical Wisdom**: "Proper electrical work powers progress safely. Shoddy wiring causes fires that destroy everything you have built."
''',
      },
      estimatedMinutes: 9,
    ),

    // Module 5: Final Inspection and Occupancy Permit
    LessonContent(
      id: 'permit-005',
      title: 'Final Inspection: Ready for Financial Occupancy',
      description: 'Complete your final inspection to earn full financial trading privileges.',
      type: LessonType.interactive,
      data: {
        'content': '''
Your financial building is nearly complete! Time for the final inspection to ensure everything meets safety codes before you can occupy and operate with real money.

**Final Inspection Checklist** 📋

**Foundation Verification** ✅
□ Emergency fund fully funded (3-6 months expenses)
□ High-interest debt eliminated or under control
□ Consistent budgeting and expense tracking
□ Positive monthly cash flow established
□ Basic banking infrastructure optimized

**Structural Integrity Check** ✅
□ Risk tolerance properly assessed and documented
□ Portfolio allocation plan created and tested
□ Diversification strategy implemented
□ Rebalancing procedures established
□ Risk management tools understood and ready

**Electrical Systems Test** ✅
□ Market terminology and mechanics mastered
□ Order types understood and practiced (paper trading)
□ Information sources identified and verified
□ Trading platform familiarity established
□ Risk controls and limits configured

**Safety Systems Verification** ✅
□ Stop-loss procedures tested and functional
□ Position sizing rules established and automated
□ Emergency exit procedures documented
□ Emotional control mechanisms in place
□ Professional support network identified

**Code Compliance Review** ✅
□ Legal and tax implications understood
□ Regulatory requirements researched
□ Fiduciary responsibilities acknowledged
□ Ethical investing principles adopted
□ Record keeping systems established

**Occupancy Permit Privileges** 🏠
Once you pass final inspection, you earn these privileges:

**Residential Use** (Basic Investing)
• Individual retirement accounts
• Index fund investing
• Dollar-cost averaging strategies
• Buy-and-hold investing
• Basic rebalancing activities

**Commercial Use** (Active Trading)
• Individual stock selection
• Options trading (with additional permits)
• Margin accounts (with strict controls)
• Short-term trading strategies
• Advanced portfolio management

**Industrial Use** (Professional Level)
• Complex derivatives trading
• Hedge fund strategies
• Professional money management
• Institutional investing
• Advanced risk management

**Ongoing Maintenance Requirements** 🔧
Your financial building requires regular maintenance:

**Monthly Inspections**
• Portfolio review and rebalancing
• Budget review and optimization
• Risk assessment updates
• Performance analysis
• Goal progress evaluation

**Annual Inspections**
• Complete financial plan review
• Tax optimization strategies
• Insurance needs assessment
• Estate planning updates
• Professional consultation

**Emergency Procedures** 🚨
Every financial building needs emergency procedures:
• Market crash response plan
• Job loss contingency plan
• Major expense emergency procedures
• Portfolio emergency exit strategy
• Professional help contact list

**Kingdom Building Completion Wisdom**: "A master builder never stops learning. Your financial building will require lifelong maintenance, improvement, and occasionally, expansion."
''',
        'interactionType': 'finalInspection',
        'parameters': {
          'inspectionAreas': [
            {
              'area': 'Foundation',
              'weight': 30,
              'requirements': ['Emergency fund', 'Debt control', 'Budget tracking', 'Cash flow positive']
            },
            {
              'area': 'Structure',
              'weight': 25,
              'requirements': ['Risk assessment', 'Portfolio plan', 'Diversification', 'Rebalancing']
            },
            {
              'area': 'Electrical',
              'weight': 25,
              'requirements': ['Market knowledge', 'Order types', 'Information sources', 'Platform familiarity']
            },
            {
              'area': 'Safety',
              'weight': 20,
              'requirements': ['Stop-loss plan', 'Position sizing', 'Exit procedures', 'Emotional control']
            }
          ],
          'passingScore': 85,
          'certification': 'Financial Occupancy Permit'
        },
        'instructions': 'Complete all inspection requirements to earn your Financial Occupancy Permit',
        'successMessage': 'Congratulations! You have earned your Financial Occupancy Permit. Welcome to responsible investing!',
      },
      estimatedMinutes: 15,
    ),

    // Quiz Module
    LessonContent(
      id: 'permit-quiz',
      title: 'Building Permit Mastery Quiz',
      description: 'Test your understanding of the financial building permit system.',
      type: LessonType.quiz,
      data: {
        'content': 'Test your knowledge of financial building permits and progressive education.',
        'questions': [
          {
            'question': 'Why is financial education compared to building permits?',
            'options': ['It is unnecessarily bureaucratic', 'It ensures safety and competency before complex tasks', 'It is required by law', 'It makes investing more expensive'],
            'correctAnswer': 1,
            'explanation': 'Like building permits, financial education ensures you have the necessary knowledge and skills before attempting complex financial activities.',
            'kingdomMetaphor': 'Just as you would not let someone build a bridge without engineering knowledge, you should not attempt complex investing without proper education.',
          },
          {
            'question': 'What must be completed before earning a Foundation Permit?',
            'options': ['Opening a brokerage account', 'Emergency fund and debt management', 'Learning options trading', 'Starting a business'],
            'correctAnswer': 1,
            'explanation': 'The Foundation Permit requires basic financial stability including an emergency fund and debt control before building wealth.',
            'kingdomMetaphor': 'Like ensuring solid ground before laying foundation stones for your castle.',
          },
          {
            'question': 'What does the Framing Permit focus on?',
            'options': ['Market timing strategies', 'Risk management and portfolio structure', 'Tax optimization', 'Real estate investing'],
            'correctAnswer': 1,
            'explanation': 'The Framing Permit focuses on building a solid risk management framework and portfolio structure.',
            'kingdomMetaphor': 'Like creating the structural framework that will support all future additions to your castle.',
          },
          {
            'question': 'Why should you follow the building permit progression?',
            'options': ['It is legally required', 'It ensures each skill builds on previous knowledge safely', 'It takes longer to get started', 'It is more expensive'],
            'correctAnswer': 1,
            'explanation': 'Following the progression ensures each skill builds safely on previous knowledge, preventing costly mistakes.',
            'kingdomMetaphor': 'Like learning to walk before running, each permit ensures you are ready for the next level of complexity.',
          },
          {
            'question': 'What happens if you skip permits and jump to advanced strategies?',
            'options': ['You learn faster', 'You save money', 'You risk major financial losses', 'Nothing different'],
            'correctAnswer': 2,
            'explanation': 'Skipping fundamental education and jumping to advanced strategies greatly increases the risk of major financial losses.',
            'kingdomMetaphor': 'Like trying to build a tower without a foundation - it will collapse when tested.',
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