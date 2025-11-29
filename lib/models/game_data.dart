class GameData {
  final String title;
  final String description;
  final String iconPath; // Using assets or icons
  final List<GameStage> stages;
  final String category;
  final String targetAudience;

  GameData({
    required this.title,
    required this.description,
    required this.iconPath,
    required this.stages,
    required this.category,
    required this.targetAudience,
  });
}

class GameStage {
  final String title;
  final String mission;
  final List<String> challenges; // or actions/mechanics
  final String awareness;

  GameStage({
    required this.title,
    required this.mission,
    required this.challenges,
    required this.awareness,
  });
}

// Static data
final List<GameData> gamesList = [
  GameData(
    title: 'البطل البيئي',
    description: 'لعبة مغامرات تفاعلية تهدف إلى إنقاذ الكوكب من الكوارث البيئية.',
    category: 'مغامرات تفاعلية تعليمية',
    targetAudience: 'جميع الأعمار (مناسبة للعائلات)',
    iconPath: 'assets/hero.png', // Placeholder
    stages: [
      GameStage(
        title: 'المرحلة 1: الشاطئ الملوث',
        mission: 'تنظيف الشواطئ من النفايات البلاستيكية',
        challenges: ['تجنب الأمواج والعقبات الطبيعية'],
        awareness: 'مخاطر البلاستيك على الحياة البحرية',
      ),
      GameStage(
        title: 'المرحلة 2: الغابة المتدهورة',
        mission: 'زراعة الأشجار واستعادة التنوع البيولوجي',
        challenges: ['استخدام الموارد الطبيعية بشكل مستدام'],
        awareness: 'أهمية الغابات في مواجهة التغير المناخي',
      ),
      GameStage(
        title: 'المرحلة 3: المدينة الإيكولوجية',
        mission: 'تحويل المدينة إلى بيئة مستدامة',
        challenges: ['تركيب الألواح الشمسية', 'فرز النفايات'],
        awareness: 'أهمية الطاقة المتجددة وإعادة التدوير',
      ),
      GameStage(
        title: 'المرحلة 4: بحار نظيفة',
        mission: 'تنظيف المحيطات وحماية الكائنات البحرية',
        challenges: ['حماية الدلافين والسلاحف', 'استعادة الشعب المرجانية'],
        awareness: 'تأثير التلوث على النظم البيئية البحرية',
      ),
    ],
  ),
  GameData(
    title: 'مكافحة تغير المناخ',
    description: 'لعبة استراتيجية حيث تلعب دور قائد عالمي يتخذ قرارات مصيرية.',
    category: 'استراتيجية وإدارة',
    targetAudience: 'المراهقون والكبار',
    iconPath: 'assets/climate.png',
    stages: [
      GameStage(
        title: 'تقليل انبعاثات الكربون',
        mission: 'خفض انبعاثات ثاني أكسيد الكربون',
        challenges: ['الصناعة', 'النقل', 'المباني', 'ضرائب كربون', 'تشريعات بيئية'],
        awareness: 'أهمية خفض الانبعاثات',
      ),
      GameStage(
        title: 'ثورة الطاقة المتجددة',
        mission: 'التحول من الوقود الأحفوري إلى الطاقة النظيفة',
        challenges: ['التكاليف', 'البنية التحتية', 'طاقة شمسية', 'ريحية'],
        awareness: 'فوائد الطاقة المتجددة',
      ),
      GameStage(
        title: 'التكيف مع الكوارث',
        mission: 'بناء مجتمعات مرنة للكوارث الطبيعية',
        challenges: ['فيضانات', 'جفاف', 'عواصف', 'أنظمة إنذار'],
        awareness: 'الاستعداد للكوارث',
      ),
      GameStage(
        title: 'حماية النظم البيئية',
        mission: 'استعادة الموائل الطبيعية المهددة',
        challenges: ['غابات استوائية', 'محميات طبيعية', 'إعادة تشجير'],
        awareness: 'الحفاظ على التنوع البيولوجي',
      ),
    ],
  ),
  GameData(
    title: 'تحدي المدينة المستدامة',
    description: 'لعبة محاكاة لتحويل مدينة ملوثة إلى مدينة مستدامة.',
    category: 'محاكاة وإدارة مدن',
    targetAudience: 'محبي ألعاب الإدارة والاستراتيجية',
    iconPath: 'assets/city.png',
    stages: [
      GameStage(
        title: 'المرحلة 1: تحول الطاقة',
        mission: 'استبدال محطات الفحم بالطاقة المتجددة',
        challenges: ['طاقة ريحية', 'شمسية', 'من النفايات', 'ترشيد الاستهلاك'],
        awareness: 'الطاقة النظيفة',
      ),
      GameStage(
        title: 'المرحلة 2: إدارة النفايات',
        mission: 'إنشاء نظام فرز انتقائي متكامل',
        challenges: ['إعادة الاستخدام والتدوير', 'تقليل النفايات من المصدر'],
        awareness: 'إدارة النفايات',
      ),
      GameStage(
        title: 'المرحلة 3: تنقل مستدام',
        mission: 'تطوير شبكة نقل عام صديقة للبيئة',
        challenges: ['الدراجات', 'المركبات الكهربائية', 'بنية تحتية خضراء'],
        awareness: 'النقل المستدام',
      ),
      GameStage(
        title: 'المرحلة 4: زراعة حضرية',
        mission: 'مشاريع زراعة على أسطح المباني',
        challenges: ['حدائق مجتمعية', 'زراعة عمودية', 'توفير غذاء محلي'],
        awareness: 'الزراعة الحضرية',
      ),
    ],
  ),
];
