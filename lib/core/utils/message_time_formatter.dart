class MessageTimeFormatter {
  MessageTimeFormatter._();

  static final Map<String, String> _timeCache = {};
  static final Map<String, String> _dateCache = {};
  static final Map<String, String> _dayKeyCache = {};

  static String dayKey(String value) {
    final cached = _dayKeyCache[value];
    if (cached != null) return cached;

    final date = DateTime.tryParse(value)?.toLocal();
    final key = date == null
        ? (value.length >= 10 ? value.substring(0, 10) : '')
        : '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    _cache(_dayKeyCache, value, key);
    return key;
  }

  static bool sameDay(String a, String b) {
    final first = dayKey(a);
    final second = dayKey(b);
    return first.isNotEmpty && first == second;
  }

  static String time(String value) {
    final cached = _timeCache[value];
    if (cached != null) return cached;

    final date = DateTime.tryParse(value)?.toLocal();
    final label = date == null
        ? ''
        : '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    _cache(_timeCache, value, label);
    return label;
  }

  static String date(String value) {
    final date = DateTime.tryParse(value)?.toLocal();
    if (date == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final days = today.difference(target).inDays;

    if (days == 0) return '今天';
    if (days == 1) return '昨天';

    final absolute = date.year == now.year
        ? '${date.month}月${date.day}日'
        : '${date.year}年${date.month}月${date.day}日';
    final cacheKey = '${dayKey(now.toIso8601String())}:$value';
    _cache(_dateCache, cacheKey, absolute);
    return absolute;
  }

  static void _cache(Map<String, String> cache, String key, String value) {
    if (cache.length >= 300) cache.clear();
    cache[key] = value;
  }
}
