import '../../../affirmations/domain/models/affirmation_model.dart';
export '../../../affirmations/domain/models/affirmation_model.dart';

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LIFE AREA — Screen 1 selections
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class LifeArea {
  final String id;
  final String title;
  final String emoji;

  const LifeArea({required this.id, required this.title, required this.emoji});

  Map<String, dynamic> toMap() => {'id': id, 'title': title, 'emoji': emoji};
  factory LifeArea.fromMap(Map<String, dynamic> map) =>
      LifeArea(id: map['id'], title: map['title'], emoji: map['emoji']);

  static const List<LifeArea> defaults = [
    LifeArea(id: 'health', title: 'Health', emoji: '💪'),
    LifeArea(id: 'reading', title: 'Reading', emoji: '📚'),
    LifeArea(id: 'finance', title: 'Finance', emoji: '💰'),
    LifeArea(id: 'business', title: 'Business', emoji: '🚀'),
    LifeArea(id: 'coding', title: 'Coding', emoji: '💻'),
    LifeArea(id: 'productivity', title: 'Productivity', emoji: '🎯'),
    LifeArea(id: 'mindset', title: 'Mindset', emoji: '🧠'),
    LifeArea(id: 'journaling', title: 'Journaling', emoji: '📝'),
    LifeArea(id: 'spiritual', title: 'Spiritual', emoji: '🙏'),
    LifeArea(id: 'running', title: 'Running', emoji: '🏃'),
    LifeArea(id: 'nutrition', title: 'Nutrition', emoji: '🥗'),
    LifeArea(id: 'sleep', title: 'Sleep', emoji: '😴'),
    LifeArea(id: 'learning', title: 'Learning', emoji: '🎓'),
    LifeArea(id: 'relationships', title: 'Relationships', emoji: '❤️'),
    LifeArea(id: 'creativity', title: 'Creativity', emoji: '🎨'),
    LifeArea(id: 'career', title: 'Career', emoji: '📈'),
    LifeArea(id: 'travel', title: 'Travel', emoji: '✈️'),
    LifeArea(id: 'lifestyle', title: 'Lifestyle', emoji: '🏡'),
  ];
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// READING PREFERENCES — Screen 3 selections
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class ReadingPreferences {
  final List<String> categories;
  final int bookTarget;
  final int dailyReadingMinutes;

  const ReadingPreferences({
    this.categories = const [],
    this.bookTarget = 10,
    this.dailyReadingMinutes = 20,
  });

  ReadingPreferences copyWith({
    List<String>? categories,
    int? bookTarget,
    int? dailyReadingMinutes,
  }) {
    return ReadingPreferences(
      categories: categories ?? this.categories,
      bookTarget: bookTarget ?? this.bookTarget,
      dailyReadingMinutes: dailyReadingMinutes ?? this.dailyReadingMinutes,
    );
  }

  Map<String, dynamic> toMap() => {
    'categories': categories,
    'bookTarget': bookTarget,
    'dailyReadingMinutes': dailyReadingMinutes,
  };

  factory ReadingPreferences.fromMap(Map<String, dynamic> map) =>
      ReadingPreferences(
        categories: List<String>.from(map['categories'] ?? []),
        bookTarget: map['bookTarget'] ?? 10,
        dailyReadingMinutes: map['dailyReadingMinutes'] ?? 20,
      );
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HEALTH PREFERENCES — Screen 4 selections
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class HealthPreferences {
  final String weightGoal; // 'Lose Weight', 'Maintain Weight', 'Gain Weight'
  final List<String> activities;
  final List<String> nutritionGoals;
  final String sleepGoal;

  const HealthPreferences({
    this.weightGoal = '',
    this.activities = const [],
    this.nutritionGoals = const [],
    this.sleepGoal = '',
  });

  HealthPreferences copyWith({
    String? weightGoal,
    List<String>? activities,
    List<String>? nutritionGoals,
    String? sleepGoal,
  }) {
    return HealthPreferences(
      weightGoal: weightGoal ?? this.weightGoal,
      activities: activities ?? this.activities,
      nutritionGoals: nutritionGoals ?? this.nutritionGoals,
      sleepGoal: sleepGoal ?? this.sleepGoal,
    );
  }

  Map<String, dynamic> toMap() => {
    'weightGoal': weightGoal,
    'activities': activities,
    'nutritionGoals': nutritionGoals,
    'sleepGoal': sleepGoal,
  };

  factory HealthPreferences.fromMap(Map<String, dynamic> map) =>
      HealthPreferences(
        weightGoal: map['weightGoal'] ?? '',
        activities: List<String>.from(map['activities'] ?? []),
        nutritionGoals: List<String>.from(map['nutritionGoals'] ?? []),
        sleepGoal: map['sleepGoal'] ?? '',
      );
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FINANCE PREFERENCES — Screen 5 selections
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class FinancePreferences {
  final List<String> financialGoals;
  final String savingsTarget;
  final List<String> monthlyChallenges;

  const FinancePreferences({
    this.financialGoals = const [],
    this.savingsTarget = '',
    this.monthlyChallenges = const [],
  });

  FinancePreferences copyWith({
    List<String>? financialGoals,
    String? savingsTarget,
    List<String>? monthlyChallenges,
  }) {
    return FinancePreferences(
      financialGoals: financialGoals ?? this.financialGoals,
      savingsTarget: savingsTarget ?? this.savingsTarget,
      monthlyChallenges: monthlyChallenges ?? this.monthlyChallenges,
    );
  }

  Map<String, dynamic> toMap() => {
    'financialGoals': financialGoals,
    'savingsTarget': savingsTarget,
    'monthlyChallenges': monthlyChallenges,
  };

  factory FinancePreferences.fromMap(Map<String, dynamic> map) =>
      FinancePreferences(
        financialGoals: List<String>.from(map['financialGoals'] ?? []),
        savingsTarget: map['savingsTarget'] ?? '',
        monthlyChallenges: List<String>.from(map['monthlyChallenges'] ?? []),
      );
}

class UserIdentity {
  final String id;
  final String title;
  final String icon; // emoji or icon name

  UserIdentity({required this.id, required this.title, required this.icon});

  Map<String, dynamic> toMap() => {'id': id, 'title': title, 'icon': icon};
  factory UserIdentity.fromMap(Map<String, dynamic> map) => UserIdentity(id: map['id'], title: map['title'], icon: map['icon']);
}

class UserGoal {
  final String id;
  final String title;

  UserGoal({required this.id, required this.title});

  Map<String, dynamic> toMap() => {'id': id, 'title': title};
  factory UserGoal.fromMap(Map<String, dynamic> map) => UserGoal(id: map['id'], title: map['title']);
}

class UserHabit {
  final String id;
  final String title;
  final String category;
  final String difficulty; // 'Easy', 'Medium', 'Hard'
  final bool isEnabled;
  final String? timeOfDay;

  UserHabit({
    required this.id,
    required this.title,
    required this.category,
    required this.difficulty,
    this.isEnabled = true,
    this.timeOfDay,
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'title': title, 'category': category, 'difficulty': difficulty, 'isEnabled': isEnabled, 'timeOfDay': timeOfDay
  };

  factory UserHabit.fromMap(Map<String, dynamic> map) => UserHabit(
    id: map['id'], title: map['title'], category: map['category'], difficulty: map['difficulty'], 
    isEnabled: map['isEnabled'] ?? true, timeOfDay: map['timeOfDay']
  );
}

// DailyAffirmation class definition is now loaded from affirmations feature domain model.

class UserStatistics {
  final int disciplinePoints;
  final int level;
  final int currentStreak;
  final int bestStreak;
  final int totalHabitsCompleted;

  UserStatistics({
    this.disciplinePoints = 0,
    this.level = 1,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.totalHabitsCompleted = 0,
  });

  Map<String, dynamic> toMap() => {
    'disciplinePoints': disciplinePoints, 'level': level, 'currentStreak': currentStreak, 'bestStreak': bestStreak, 'totalHabitsCompleted': totalHabitsCompleted
  };

  factory UserStatistics.fromMap(Map<String, dynamic> map) => UserStatistics(
    disciplinePoints: map['disciplinePoints'] ?? 0,
    level: map['level'] ?? 1,
    currentStreak: map['currentStreak'] ?? 0,
    bestStreak: map['bestStreak'] ?? 0,
    totalHabitsCompleted: map['totalHabitsCompleted'] ?? 0,
  );
}
