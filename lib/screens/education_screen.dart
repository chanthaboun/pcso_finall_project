import 'package:flutter/material.dart';

class EducationalArticle {
  final String id;
  final String title;
  final String titleLao;
  final String summary;
  final String summaryLao;
  final String content;
  final String contentLao;
  final String category;
  final List<String> tags;
  final String readTime;
  final IconData icon;
  final Color color;

  EducationalArticle({
    required this.id,
    required this.title,
    required this.titleLao,
    required this.summary,
    required this.summaryLao,
    required this.content,
    required this.contentLao,
    required this.category,
    required this.tags,
    required this.readTime,
    required this.icon,
    required this.color,
  });
}

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  String _selectedCategory = 'all';
  bool _isLaoLanguage = true;

  final List<EducationalArticle> _articles = [
    EducationalArticle(
      id: '1',
      title: 'What is PCOS?',
      titleLao: 'PCOS ແມ່ນຫຍັງ?',
      summary:
          'Understanding Polycystic Ovary Syndrome and its impact on women\'s health',
      summaryLao: 'ການເຂົ້າໃຈກ່ຽວກັບໂຣກ PCOS ແລະ ຜົນກະທົບຕໍ່ສຸຂະພາບຜູ້ຍິງ',
      content:
          '''PCOS (Polycystic Ovary Syndrome) is a hormonal disorder affecting 1 in 10 women of reproductive age. It's characterized by:

• Irregular menstrual periods
• Excess androgen (male hormone) levels
• Polycystic ovaries (enlarged ovaries with small cysts)

Common symptoms include:
- Weight gain or difficulty losing weight
- Acne and oily skin
- Excessive hair growth (hirsutism)
- Hair loss or thinning
- Irregular or absent periods
- Difficulty getting pregnant
- Mood changes and depression

PCOS is manageable with proper lifestyle changes, medication, and regular monitoring.''',
      contentLao:
          '''PCOS (Polycystic Ovary Syndrome) ເປັນໂຣກທີ່ເກີດຈາກຮໍໂມນຜິດປົກກະຕິ ພົບໃນຜູ້ຍິງ 1 ໃນ 10 ຄົນໃນໄລຍະອາຍຸມີລູກໄດ້. ລັກສະນະສຳຄັນມີ:

• ປະຈຳເດືອນບໍ່ປົກກະຕິ
• ຮໍໂມນຜູ້ຊາຍສູງເກີນໄປ
• ຮັງໄຂ່ມີຖົງນ້ຳນ້ອຍໆ ຫຼາຍຖົງ

ອາການທົ່ວໄປ:
- ນ້ຳໜັກເພີ່ມ ຫຼື ຫຼຸດຍາກ
- ສິວ ແລະ ຜິວມັນ
- ຂົນງອກຫຼາຍ
- ຜົມຫຼ່ວງ ຫຼື ບາງ
- ປະຈຳເດືອນບໍ່ປົກກະຕິ
- ມີລູກຍາກ
- ອາລົມປ່ຽນແປງ ແລະ ຊຶມເສົ້າ

PCOS ສາມາດຄວບຄຸມໄດ້ດ້ວຍການປ່ຽນແປງວິຖີຊີວິດ, ການກິນຢາ, ແລະ ການຕິດຕາມເປັນປະຈຳ.''',
      category: 'basics',
      tags: ['PCOS', 'symptoms', 'diagnosis'],
      readTime: '5 min',
      icon: Icons.info,
      color: Colors.blue,
    ),
    EducationalArticle(
      id: '2',
      title: 'Diet and Nutrition for PCOS',
      titleLao: 'ອາຫານ ແລະ ໂພຊະນາການສຳລັບ PCOS',
      summary:
          'Learn about the best foods and eating habits to manage PCOS symptoms',
      summaryLao:
          'ຮຽນຮູ້ກ່ຽວກັບອາຫານທີ່ດີທີ່ສຸດ ແລະ ນິສັຍການກິນເພື່ອຈັດການອາການ PCOS',
      content:
          '''A balanced diet is crucial for managing PCOS. Key principles include:

**Foods to Include:**
• High-fiber foods (vegetables, fruits, whole grains)
• Lean proteins (fish, chicken, legumes)
• Anti-inflammatory foods (berries, fatty fish, nuts)
• Complex carbohydrates (quinoa, brown rice, oats)

**Foods to Limit:**
• Refined sugars and processed foods
• White bread and pasta
• Sugary drinks and snacks
• Trans fats and excessive saturated fats

**Meal Planning Tips:**
- Eat regular, balanced meals
- Include protein with each meal
- Choose low glycemic index foods
- Stay hydrated with plenty of water
- Consider smaller, frequent meals

Remember to consult with a healthcare provider or nutritionist for personalized advice.''',
      contentLao:
          '''ອາຫານທີ່ສົມດູນແມ່ນສິ່ງສຳຄັນສຳລັບການຈັດການ PCOS. ຫຼັກການສຳຄັນມີ:

**ອາຫານທີ່ຄວນກິນ:**
• ອາຫານທີ່ມີໄຟເບີສູງ (ຜັກ, ໝາກໄມ້, ເມັດພືດເຕັມ)
• ໂປຣຕີນບໍ່ມີໄຂມັນ (ປາ, ໄກ່, ຖົ່ວ)
• ອາຫານຕ້ານການອັກເສບ (berry, ປາໄຂມັນ, ແກ່ນໄມ້)
• ຄາໂບໄຮເດຣດສະລັບສີ (quinoa, ເຂົ້າອາຫານ, oats)

**ອາຫານທີ່ຄວນຫຼີກເວັ້ນ:**
• ນ້ຳຕານແລະອາຫານປຸງແຕ່ງ
• ເຂົ້າຈີ່ຂາວ ແລະ pasta
• ເຄື່ອງດື່ມຫວານ ແລະ ຂະໜົມ
• ໄຂມັນ trans ແລະ ໄຂມັນອີ່ມຕົວເກີນ

**ຄຳແນະນຳການວາງແຜນອາຫານ:**
- ກິນອາຫານປົກກະຕິທີ່ສົມດູນ
- ລວມໂປຣຕີນໃນທຸກມື້
- ເລືອກອາຫານ glycemic index ຕ່ຳ
- ດື່ມນ້ຳໃຫ້ພຽງພໍ
- ພິຈາລະນາກິນໜ້ອຍໆ ແຕ່ເລື້ອຍໆ

ຢ່າລືມປຶກສາກັບຜູ້ໃຫ້ບໍລິການດູແລສຸຂະພາບ ຫຼື ນັກໂພຊະນາການເພື່ອຄຳແນະນຳສ່ວນບຸກຄົນ.''',
      category: 'nutrition',
      tags: ['diet', 'nutrition', 'meal planning'],
      readTime: '7 min',
      icon: Icons.restaurant,
      color: Colors.green,
    ),
    EducationalArticle(
      id: '3',
      title: 'Exercise and PCOS',
      titleLao: 'ການອອກກຳລັງກາຍ ແລະ PCOS',
      summary: 'Discover the best types of exercise to improve PCOS symptoms',
      summaryLao: 'ຄົ້ນພົບປະເພດການອອກກຳລັງກາຍທີ່ດີທີ່ສຸດເພື່ອປັບປຸງອາການ PCOS',
      content:
          '''Regular exercise is one of the most effective ways to manage PCOS symptoms. Benefits include:

• Improved insulin sensitivity
• Weight management
• Reduced inflammation
• Better mood and mental health
• Improved sleep quality

**Best Types of Exercise:**

1. **Cardio Exercise:**
   - Walking, jogging, cycling
   - Swimming, dancing
   - 150 minutes per week recommended

2. **Strength Training:**
   - Weight lifting, resistance bands
   - Bodyweight exercises
   - 2-3 times per week

3. **Low-Impact Options:**
   - Yoga, Pilates
   - Water aerobics
   - Tai Chi

**Getting Started Tips:**
- Start slowly and gradually increase intensity
- Find activities you enjoy
- Set realistic goals
- Track your progress
- Listen to your body

Remember: Any movement is better than none. Start where you are and build from there!''',
      contentLao:
          '''ການອອກກຳລັງກາຍເປັນປະຈຳແມ່ນວິທີທີ່ມີປະສິດທິພາບທີ່ສຸດໃນການຈັດການອາການ PCOS. ຜົນປະໂຫຍດລວມມີ:

• ປັບປຸງຄວາມອ່ອນໄຫວຕໍ່ insulin
• ຄວບຄຸມນ້ຳໜັກ
• ຫຼຸດການອັກເສບ
• ອາລົມ ແລະ ສຸຂະພາບຈິດດີຂຶ້ນ
• ນອນຫຼັບດີຂຶ້ນ

**ປະເພດການອອກກຳລັງກາຍທີ່ດີທີ່ສຸດ:**

1. **ການອອກກຳລັງກາຍ Cardio:**
   - ຍ່າງ, ແລ່ນ, ຂີ່ລົດຖີບ
   - ວ່າຍນ້ຳ, ເຕັ້ນລຳ
   - ແນະນຳ 150 ນາທີຕໍ່ອາທິດ

2. **ການຝຶກຄວາມແຂງແຮງ:**
   - ຍົກນ້ຳໜັກ, ການໃຊ້ສາຍຍືດ
   - ການອອກກຳລັງກາຍດ້ວຍນ້ຳໜັກຕົວ
   - 2-3 ຄັ້ງຕໍ່ອາທິດ

3. **ທາງເລືອກກະທົບນ້ອຍ:**
   - ໂຍຄະ, Pilates
   - ການອອກກຳລັງກາຍໃນນ້ຳ
   - ໄຕ໋ຈີ

**ຄຳແນະນຳການເລີ່ມຕົ້ນ:**
- ເລີ່ມຊ້າໆ ແລະ ເພີ່ມຄວາມແຮງຄ່ອຍໆ
- ຊອກຫາກິດຈະກຳທີ່ມັກ
- ຕັ້ງເປົ້າຫມາຍທີ່ສົມເຫດສົມຜົນ
- ຕິດຕາມຄວາມກ້າວໜ້າ
- ຟັງຮ່າງກາຍຂອງຕົວເອງ

ຈົດຈຳ: ການເຄື່ອນໄຫວຢ່າງໃດກໍ່ດີກວ່າບໍ່ເຄື່ອນໄຫວເລີຍ. ເລີ່ມຈາກຈຸດທີ່ເຮົາຢູ່ ແລະ ກໍ່ສ້າງຂຶ້ນໄປຈາກນັ້ນ!''',
      category: 'exercise',
      tags: ['exercise', 'fitness', 'health'],
      readTime: '6 min',
      icon: Icons.fitness_center,
      color: Colors.orange,
    ),
    EducationalArticle(
      id: '4',
      title: 'Managing PCOS Stress',
      titleLao: 'ການຈັດການຄວາມຄຽດຈາກ PCOS',
      summary:
          'Learn stress management techniques specifically for women with PCOS',
      summaryLao: 'ຮຽນຮູ້ເຕັກນິກການຄຸ້ມຄອງຄວາມຄຽດສະເພາະສຳລັບຜູ້ຍິງທີ່ມີ PCOS',
      content:
          '''Living with PCOS can be stressful, but managing stress is crucial for symptom control. Here's why and how:

**Why Stress Management Matters:**
• Stress increases cortisol levels
• High cortisol worsens insulin resistance
• Stress can trigger hormonal imbalances
• Mental health impacts overall wellbeing

**Effective Stress Management Techniques:**

1. **Mindfulness and Meditation:**
   - Daily meditation practice
   - Deep breathing exercises
   - Mindful eating

2. **Relaxation Techniques:**
   - Progressive muscle relaxation
   - Guided imagery
   - Warm baths or aromatherapy

3. **Social Support:**
   - Join PCOS support groups
   - Talk to friends and family
   - Consider counseling if needed

4. **Healthy Boundaries:**
   - Learn to say no
   - Prioritize self-care
   - Manage work-life balance

5. **Regular Sleep Schedule:**
   - 7-9 hours per night
   - Consistent bedtime routine
   - Limit screen time before bed

Remember: It's okay to ask for help. Mental health is just as important as physical health.''',
      contentLao:
          '''ການດຳລົງຊີວິດກັບ PCOS ອາດຈະເຄັ່ງຄຽດ, ແຕ່ການຄຸ້ມຄອງຄວາມຄຽດມີຄວາມສຳຄັນສຳລັບການຄວບຄຸມອາການ. ນີ້ແມ່ນເຫດຜົນ ແລະ ວິທີການ:

**ເປັນຫຍັງການຄຸ້ມຄອງຄວາມຄຽດຈຶ່ງສຳຄັນ:**
• ຄວາມຄຽດເຮັດໃຫ້ລະດັບ cortisol ເພີ່ມ
• Cortisol ສູງເຮັດໃຫ້ການຕ້ານທານ insulin ຮ້າຍແຮງຂຶ້ນ
• ຄວາມຄຽດສາມາດກະຕຸ້ນຄວາມບໍ່ສົມດູນຂອງຮໍໂມນ
• ສຸຂະພາບຈິດສົ່ງຜົນຕໍ່ສະຫວັດດີການໂດຍລວມ

**ເຕັກນິກການຄຸ້ມຄອງຄວາມຄຽດທີ່ມີປະສິດທິພາບ:**

1. **ສະຕິ ແລະ ການຂະມົງ:**
   - ການຂະມົງເປັນປະຈຳ
   - ການຫາຍໃຈເລິກ
   - ການກິນດ້ວຍສະຕິ

2. **ເຕັກນິກການຜ່ອນຄາຍ:**
   - ການຜ່ອນຄາຍກ້າມເນື້ອແບບຄ່ອຍເປັນຄ່ອຍໄປ
   - ການຈິນຕະນາການທີ່ມີການນຳພາ
   - ອາບນ້ຳອຸ່ນ ຫຼື ກິ່ນຫອມບຳບັດ

3. **ການສະໜັບສະໜູນທາງສັງຄົມ:**
   - ເຂົ້າຮ່ວມກຸ່ມສະໜັບສະໜູນ PCOS
   - ລົມກັບໝູ່ເພື່ອນ ແລະ ຄອບຄົວ
   - ພິຈາລະນາການປຶກສາຖ້າຈຳເປັນ

4. **ຂອບເຂດທີ່ມີສຸຂະພາບດີ:**
   - ຮຽນຮູ້ທີ່ຈະປະຕິເສດ
   - ໃຫ້ຄວາມສຳຄັນກັບການດູແລຕົນເອງ
   - ຈັດການຄວາມສົມດູນລະຫວ່າງການເຮັດວຽກ-ຊີວິດ

5. **ຕາລາງການນອນເປັນປະຈຳ:**
   - 7-9 ຊົ່ວໂມງຕໍ່ຄືນ
   - ກິດຈະກຳກ່ອນນອນທີ່ສະເໝີຕົ້ນ
   - ຈຳກັດການໃຊ້ໜ້າຈໍກ່ອນນອນ

ຈົດຈຳ: ການຂໍຄວາມຊ່ວຍເຫຼືອແມ່ນສິ່ງປົກກະຕິ. ສຸຂະພາບຈິດມີຄວາມສຳຄັນເທົ່າກັບສຸຂະພາບທາງດ້ານຮ່າງກາຍ.''',
      category: 'mental_health',
      tags: ['stress', 'mental health', 'wellness'],
      readTime: '8 min',
      icon: Icons.psychology,
      color: Colors.purple,
    ),
  ];

  List<EducationalArticle> get _filteredArticles {
    if (_selectedCategory == 'all') {
      return _articles;
    }
    return _articles
        .where((article) => article.category == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(_isLaoLanguage ? '📚 ການສຶກສາ PCOS' : '📚 PCOS Education'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isLaoLanguage = !_isLaoLanguage;
              });
            },
            icon: Text(
              _isLaoLanguage ? 'EN' : 'ລາວ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildCategoryChip('all', _isLaoLanguage ? 'ທັງໝົດ' : 'All'),
                _buildCategoryChip(
                    'basics', _isLaoLanguage ? 'ພື້ນຖານ' : 'Basics'),
                _buildCategoryChip(
                    'nutrition', _isLaoLanguage ? 'ໂພຊະນາການ' : 'Nutrition'),
                _buildCategoryChip(
                    'exercise', _isLaoLanguage ? 'ອອກກຳລັງກາຍ' : 'Exercise'),
                _buildCategoryChip('mental_health',
                    _isLaoLanguage ? 'ສຸຂະພາບຈິດ' : 'Mental Health'),
              ],
            ),
          ),

          // Articles list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredArticles.length,
              itemBuilder: (context, index) {
                final article = _filteredArticles[index];
                return _buildArticleCard(article);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category, String label) {
    final isSelected = _selectedCategory == category;
    return Container(
      margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = category;
          });
        },
        selectedColor: const Color(0xFFE91E63).withOpacity(0.2),
        checkmarkColor: const Color(0xFFE91E63),
        labelStyle: TextStyle(
          color: isSelected ? const Color(0xFFE91E63) : Colors.grey[600],
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildArticleCard(EducationalArticle article) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ArticleDetailScreen(
                article: article,
                isLaoLanguage: _isLaoLanguage,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: article.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(
                      article.icon,
                      color: article.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isLaoLanguage ? article.titleLao : article.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: article.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                article.readTime,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: article.color,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey,
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _isLaoLanguage ? article.summaryLao : article.summary,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: article.tags
                    .map((tag) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ArticleDetailScreen extends StatelessWidget {
  final EducationalArticle article;
  final bool isLaoLanguage;

  const ArticleDetailScreen({
    super.key,
    required this.article,
    required this.isLaoLanguage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(isLaoLanguage ? article.titleLao : article.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    article.color.withOpacity(0.8),
                    article.color,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        article.icon,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          isLaoLanguage ? article.titleLao : article.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isLaoLanguage ? article.summaryLao : article.summary,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: Colors.white70,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              article.readTime,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Content
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                isLaoLanguage ? article.contentLao : article.content,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tags
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isLaoLanguage ? 'ຫົວຂໍ້ທີ່ກ່ຽວຂ້ອງ:' : 'Related Topics:',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: article.tags
                        .map((tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: article.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: article.color,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Disclaimer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.amber[200]!,
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.amber[700],
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isLaoLanguage
                          ? 'ຂໍ້ມູນນີ້ເປັນການສຶກສາເທົ່ານັ້ນ ແລະ ບໍ່ສາມາດທົດແທນຄຳແນະນຳທາງການແພດໄດ້. ກະລຸນາປຶກສາກັບແພດເພື່ອການວິນິດໄສ ແລະ ການປິ່ນປົວທີ່ເໝາະສົມ.'
                          : 'This information is for educational purposes only and cannot replace medical advice. Please consult with a healthcare provider for proper diagnosis and treatment.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber[800],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
