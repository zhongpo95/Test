library JNDaily
static if not REFORGED_MODE then
    native JNDailySave takes string MapId, string UserId, string SecretKey, string Character, string DailyType returns string
    native JNDailyCheckToday takes string MapId, string UserId, string SecretKey, string Character, string DailyType returns string
    native JNDailyCheckTodayList takes string MapId, string UserId, string SecretKey, string Character, string DailyType returns string
    native JNDailyCountWeek takes string MapId, string UserId, string SecretKey, string Character, string DailyType, string WeekDay returns string
    native JNDailyCountWeekList takes string MapId, string UserId, string SecretKey, string Character, string DailyType, string WeekDay returns string
    native JNDailyCountMonth takes string MapId, string UserId, string SecretKey, string Character, string DailyType returns string
    native JNDailyCountMonthList takes string MapId, string UserId, string SecretKey, string Character, string DailyType returns string
endif
endlibrary