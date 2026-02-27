<template>
  <div class="min-h-screen bg-base-100">
    <!-- 헤더 -->
    <div class="navbar bg-base-100/80 backdrop-blur-md shadow-sm border-b border-base-content/5 sticky top-0 z-50">
      <div class="flex-1">
        <a class="btn btn-ghost text-xl gap-2">
          <div class="avatar">
            <div class="w-10 h-10 rounded-2xl bg-base-100 overflow-hidden shadow-sm border border-base-content/10 transition-all hover:scale-105 hover:shadow-md cursor-pointer">
              <img src="/app_icon.png" alt="Icon" class="w-full h-full object-cover scale-110 transform" />
            </div>
          </div>
          <span class="font-bold text-white">출퇴근</span>
          <span class="text-xs font-normal opacity-50 hidden sm:inline-block">Dashboard</span>
        </a>
      </div>
      <div class="flex-none gap-2">
        <div class="dropdown dropdown-end">
          <div tabindex="0" role="button" class="btn btn-ghost btn-circle avatar">
            <div class="w-10 rounded-full">
              <div class="w-full h-full bg-neutral flex items-center justify-center text-neutral-content font-bold text-lg">
                {{ authStore.user?.username?.charAt(0).toUpperCase() || 'U' }}
              </div>
            </div>
          </div>
          <ul tabindex="0" class="mt-3 z-[1] p-2 shadow-lg menu menu-sm dropdown-content bg-base-100 rounded-box w-52 border border-base-content/10">
            <li class="menu-title px-4 py-2">
              <span class="text-xs opacity-50">Signed in as</span>
              <span class="font-bold text-primary">{{ authStore.user?.username }}</span>
            </li>
            <li><a @click="showPasswordModal = true">🔑 비밀번호 변경</a></li>
            <li><a @click="showDeleteModal = true" class="text-error">⚠️ 회원탈퇴</a></li>
            <div class="divider my-1"></div>
            <li><a @click="handleLogout">🚪 로그아웃</a></li>
          </ul>
        </div>
      </div>
    </div>

    <!-- 메인 컨테이너 -->
    <div class="w-full max-w-[1920px] mx-auto p-4 md:p-6 lg:p-8 xl:p-12 animate-fade-in-up flex flex-col gap-8">
      <!-- 상태 카드 섹션 -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 xl:gap-6">
        <!-- 출퇴근 활성화 토글 -->
        <div class="card bg-neutral shadow-lg transition-colors border border-white/10 rounded-2xl">
          <div class="card-body p-6 flex flex-row items-center justify-between">
            <div>
              <h3 class="stat-title text-base-content/60 text-sm font-medium mb-1">자동 출퇴근</h3>
              <div class="flex items-center gap-2">
                <input
                  type="checkbox"
                  class="toggle toggle-primary toggle-sm"
                  v-model="isActive"
                  @change="updateUserStatus"
                />
                <span class="font-bold text-lg" :class="isActive ? 'text-white' : 'text-base-content/40'">
                  {{ isActive ? 'ON' : 'OFF' }}
                </span>
              </div>
            </div>
            <div class="p-3 rounded-full bg-primary/10 text-white">
              <svg xmlns="http://www.w3.org/2000/svg" class="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
            </div>
          </div>
        </div>

        <!-- 서버 상태 -->
        <div class="card bg-neutral shadow-lg border border-white/10 rounded-2xl">
          <div class="card-body p-6 flex flex-row items-center justify-between">
            <div>
              <h3 class="stat-title text-base-content/60 text-sm font-medium mb-1">서버 상태</h3>
              <div class="flex items-center gap-2">
                <div class="badge badge-sm" :class="serverStatus.main ? 'badge-success' : 'badge-error'"></div>
                <span class="font-bold text-lg">{{ serverStatus.main ? 'Online' : 'Offline' }}</span>
              </div>
            </div>
            <div class="p-3 rounded-full" :class="serverStatus.main ? 'bg-success/10 text-success' : 'bg-error/10 text-error'">
              <svg xmlns="http://www.w3.org/2000/svg" class="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 12h14M5 12a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v4a2 2 0 01-2 2M5 12a2 2 0 01-2 2v4a2 2 0 012 2h14a2 2 0 012-2v-4a2 2 0 01-2-2m-2-4h.01M17 16h.01" /></svg>
            </div>
          </div>
        </div>

        <!-- 오늘 출근 -->
        <div class="card bg-neutral shadow-lg border border-white/10 rounded-2xl">
          <div class="card-body p-6 flex flex-row items-center justify-between">
            <div>
              <h3 class="stat-title text-base-content/60 text-sm font-medium mb-1">오늘 출근</h3>
              <span class="font-mono font-bold text-lg tracking-tight">
                {{ todayStatus.punchIn || '--:--' }}
              </span>
            </div>
            <div class="p-3 rounded-full bg-warning/10 text-warning">
              <svg xmlns="http://www.w3.org/2000/svg" class="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z" /></svg>
            </div>
          </div>
        </div>

        <!-- 오늘 퇴근 -->
        <div class="card bg-neutral shadow-lg border border-white/10 rounded-2xl">
          <div class="card-body p-6 flex flex-row items-center justify-between">
            <div>
              <h3 class="stat-title text-base-content/60 text-sm font-medium mb-1">오늘 퇴근</h3>
              <span class="font-mono font-bold text-lg tracking-tight">
                {{ todayStatus.punchOut || '--:--' }}
              </span>
            </div>
            <div class="p-3 rounded-full bg-info/10 text-info">
              <svg xmlns="http://www.w3.org/2000/svg" class="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z" /></svg>
            </div>
          </div>
        </div>
      </div>

      <!-- 메인 콘텐츠: 로그와 달력 -->
      <div class="grid grid-cols-1 lg:grid-cols-12 gap-6 xl:gap-8 items-start">
        <!-- 왼쪽: 로그 (모바일: 전체, 데스크톱: 5/12) -->
        <div class="lg:col-span-5 xl:col-span-4">
          <div class="card bg-neutral shadow-lg border border-white/10 rounded-2xl overflow-hidden">
            <div class="card-body p-0">
              <div class="p-4 border-b border-base-content/5 flex justify-between items-center bg-base-200/30 rounded-t-xl">
                <h3 class="font-bold text-lg flex items-center gap-2">
                  <svg xmlns="http://www.w3.org/2000/svg" class="w-5 h-5 text-primary" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
                  실시간 로그
                </h3>
                <span class="badge badge-sm badge-ghost">{{ logs.length }}개</span>
              </div>
              <!-- LOGS TABLE PART ALREADY HANDLED -->


              <div class="overflow-y-auto max-h-[400px] lg:max-h-[500px] scrollbar-thin scrollbar-thumb-base-300 scrollbar-track-base-100">
                <table class="table table-pin-rows table-fixed w-full">
                  <thead>
                    <tr class="bg-base-200/50 text-base-content/70">
                      <th class="w-32 text-center">시간</th>
                      <th class="w-24 text-center">상태</th>
                      <th class="w-auto">메시지</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="(log, index) in reversedLogs" :key="index" class="hover:bg-base-200/50 transition-colors border-b border-base-content/5 last:border-0 cursor-pointer" @click="showDetailModal(log)">
                      <td class="font-mono text-xs text-center opacity-70">{{ formatTime(log.timestamp) }}</td>
                      <td class="text-center">
                         <div class="badge badge-xs sm:badge-sm font-medium whitespace-nowrap" :class="getBadgeVariant(log.status)">
                          {{ translateStatus(log.status) }}
                        </div>
                      </td>
                      <td class="text-xs sm:text-sm leading-relaxed min-w-0 overflow-hidden">
                        <div class="truncate w-full block" :title="translateMessage(log.message, log)">
                          {{ translateMessage(log.message, log) }}
                        </div>
                      </td>
                    </tr>
                    <tr v-if="reversedLogs.length === 0">
                      <td colspan="3" class="text-center py-10 text-base-content/40">
                        <div class="flex flex-col items-center gap-2">
                          <svg xmlns="http://www.w3.org/2000/svg" class="w-8 h-8 opacity-20" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" /></svg>
                          <span>로그가 없습니다</span>
                        </div>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </div>

        <!-- 오른쪽: 달력 (모바일: 전체, 데스크톱: 8/12) -->
        <div class="lg:col-span-7 xl:col-span-8">
          <div class="card bg-neutral shadow-lg border border-white/10 rounded-2xl overflow-hidden">
            <div class="card-body p-4 sm:p-6">
              <div class="flex flex-col sm:flex-row justify-between items-center mb-6 gap-4">
                <h3 class="font-bold text-xl flex items-center gap-2">
                  <svg xmlns="http://www.w3.org/2000/svg" class="w-6 h-6 text-secondary" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" /></svg>
                  <span class="text-white font-extrabold">
                    {{ currentYear }}년 {{ currentMonth }}월
                  </span>
                </h3>
                <div class="join shadow-sm border border-base-content/10 rounded-btn">
                  <button class="join-item btn btn-sm btn-ghost hover:bg-base-200" @click="prevMonth">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" /></svg>
                  </button>
                  <button class="join-item btn btn-sm btn-ghost font-mono min-w-[60px]" @click="resetToToday">오늘</button>
                  <button class="join-item btn btn-sm btn-ghost hover:bg-base-200" @click="nextMonth">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" /></svg>
                  </button>
                </div>
              </div>

              <!-- 달력 그리드 -->
              <div class="grid grid-cols-7 gap-[1px] bg-white/5 rounded-xl overflow-hidden border border-white/10">
                <!-- 요일 헤더 -->
                <div v-for="(day, index) in weekDays" :key="day"
                     class="bg-base-300 p-2 sm:p-3 text-center text-xs font-bold uppercase tracking-wider flex items-center justify-center text-white/70"
                     :class="{'!text-error': index === 0, '!text-info': index === 6}">
                  {{ day }}
                </div>

                <!-- 날짜 셀 -->
                <div v-for="(date, index) in calendarDays" :key="index"
                     @click="date.isCurrentMonth && handleDateClick(date)"
                     class="bg-base-200 p-1 sm:p-2 relative transition-all duration-200 group flex flex-col min-h-[80px] sm:min-h-[100px]"
                     :class="{
                       'bg-base-300/50 text-base-content/25': !date.isCurrentMonth,
                       'hover:bg-base-content/10 cursor-pointer': date.isCurrentMonth,
                       'cursor-default': !date.isCurrentMonth
                     }">

                  <div class="flex justify-between items-start">
                    <span class="text-sm font-medium w-6 h-6 flex items-center justify-center rounded-full"
                          :class="{
                            'bg-primary text-primary-content font-bold shadow-md': isToday(date),
                            'text-error': date.dayOfWeek === 0 && !isToday(date),
                            'text-info': date.dayOfWeek === 6 && !isToday(date)
                          }">
                      {{ date.day }}
                    </span>

                    <div v-if="date.isCurrentMonth && togglingDates.has(`${currentYear}-${String(currentMonth).padStart(2, '0')}-${String(date.day).padStart(2, '0')}`)" class="loading loading-spinner loading-xs text-primary"></div>
                  </div>

                  <!-- 스케줄 텍스트 표시 -->
                   <div v-if="date.isCurrentMonth && date.status" class="mt-1 sm:mt-2 flex-1 flex flex-col justify-end">
                      <div class="text-[10px] sm:text-xs truncate font-semibold text-center rounded-md px-1.5 py-1"
                           :class="{
                             'bg-primary/20 text-primary-content border border-primary/30': date.status.includes('출근'),
                             'bg-base-300 text-base-content/50 border border-base-content/10': date.status.includes('휴무'),
                             'bg-secondary/20 text-secondary border border-secondary/30': !date.status.includes('출근') && !date.status.includes('휴무') && date.status
                           }">
                        {{ date.status }}
                      </div>
                   </div>
                </div>
              </div>

              <!-- 범례 -->
              <div class="mt-4 flex flex-wrap gap-4 text-xs justify-center sm:justify-end text-base-content/60">
                 <div class="flex items-center gap-1.5">
                    <div class="w-2.5 h-2.5 rounded bg-primary/20 border border-primary/50"></div> 출근일
                 </div>
                 <div class="flex items-center gap-1.5">
                    <div class="w-2.5 h-2.5 rounded bg-base-300 border border-base-CONTENT/20"></div> 휴무일
                 </div>
              </div>

            </div>
          </div>
        </div>
      </div>

      <!-- 마지막 업데이트 정보 -->
      <div class="text-center mt-8">
        <div class="text-sm text-base-content/60">
          마지막 업데이트: {{ new Date().toLocaleString('ko-KR') }}
          <span class="loading loading-ring loading-xs ml-2"></span>
        </div>
      </div>
    </div>

    <!-- 상세 로그 모달 -->
    <div v-if="selectedLog" class="modal modal-open bg-black/40 backdrop-blur-sm transition-all duration-300 items-center justify-center">
      <div class="modal-box w-11/12 max-w-6xl h-[90vh] bg-base-100/95 backdrop-blur-xl border border-base-content/10 shadow-2xl p-0 overflow-hidden relative flex flex-col">
        <!-- 배경 장식 -->
        <div class="absolute top-0 right-0 w-72 h-72 bg-primary/8 rounded-full blur-3xl -translate-y-1/2 translate-x-1/2 pointer-events-none"></div>
        <div class="absolute bottom-0 left-0 w-56 h-56 bg-secondary/8 rounded-full blur-3xl translate-y-1/2 -translate-x-1/2 pointer-events-none"></div>

        <!-- 헤더 섹션 (고정) -->
        <div class="bg-base-200/50 p-6 border-b border-base-content/5 shrink-0 z-10 relative">
          <div class="flex items-center justify-between">
            <div class="flex items-center gap-4">
              <div class="w-12 h-12 rounded-xl bg-gradient-to-br from-primary to-secondary flex items-center justify-center shadow-lg shrink-0">
                <svg xmlns="http://www.w3.org/2000/svg" class="w-6 h-6 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                </svg>
              </div>
              <div class="flex flex-col gap-1">
                <div class="flex items-center gap-3">
                  <h3 class="text-xl font-bold text-white">
                    {{ translateActionType(selectedLog.action_type) }} 상세 로그
                  </h3>
                  <div :class="['badge badge-sm', getBadgeVariant(selectedLog.status)]">
                    {{ translateStatus(selectedLog.status) }}
                  </div>
                </div>
                <p class="text-xs text-base-content/50">{{ formatTime(selectedLog.timestamp) }} 실행 기록</p>
              </div>
            </div>
            <button @click="selectedLog = null" class="btn btn-sm btn-circle btn-ghost hover:bg-white/10">
              <svg xmlns="http://www.w3.org/2000/svg" class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>
        </div>

        <!-- 메인 콘텐츠 (스크롤 가능) -->
        <div class="p-6 overflow-y-auto flex-1 custom-scrollbar relative z-0">
          <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 h-full">
            <!-- 기본 정보 사이드바 -->
            <div class="lg:col-span-1 flex flex-col gap-6 h-full">
              <!-- 요약 정보 -->
              <div class="rounded-2xl bg-gradient-to-br from-primary/10 to-secondary/10 border border-white/10 shadow-lg p-6">
                <h4 class="font-bold text-white flex items-center gap-2 text-sm mb-5">
                  <span class="w-7 h-7 rounded-lg bg-primary/20 flex items-center justify-center text-xs">📊</span>
                  실행 요약
                </h4>
                <div class="flex flex-col gap-4 text-sm">
                  <div class="flex justify-between items-center">
                    <span class="font-medium text-base-content/60">사용자</span>
                    <span class="font-mono text-primary font-semibold">{{ selectedLog.user_id }}</span>
                  </div>
                  <div class="w-full h-px bg-white/5"></div>
                  <div class="flex justify-between items-center">
                    <span class="font-medium text-base-content/60">시작 시간</span>
                    <span class="font-mono text-white/90">{{ formatTime(selectedLog.timestamp) }}</span>
                  </div>
                  <div v-if="detailLogs.length > 0" class="w-full h-px bg-white/5"></div>
                  <div class="flex justify-between items-center" v-if="detailLogs.length > 0">
                    <span class="font-medium text-base-content/60">완료 시간</span>
                    <span class="font-mono text-white/90">{{ formatTime(getLastStageTime()) }}</span>
                  </div>
                  <div v-if="detailLogs.length > 0" class="w-full h-px bg-white/5"></div>
                  <div class="flex justify-between items-center" v-if="detailLogs.length > 0">
                    <span class="font-medium text-base-content/60">총 소요시간</span>
                    <span class="font-mono text-secondary font-semibold">{{ calculateDuration() }}</span>
                  </div>
                  <div class="w-full h-px bg-white/5"></div>
                  <div class="flex justify-between items-center">
                    <span class="font-medium text-base-content/60">단계 수</span>
                    <span class="font-mono text-accent font-semibold">{{ detailLogs.length }}단계</span>
                  </div>
                </div>
              </div>

              <!-- 메시지 -->
              <div class="rounded-2xl bg-base-200/30 border border-white/10 shadow p-6" v-if="selectedLog.message || selectedLog.status">
                <h4 class="font-bold text-white flex items-center gap-2 text-sm mb-5">
                  <span class="w-7 h-7 rounded-lg bg-info/20 flex items-center justify-center text-xs">💬</span>
                  결과 메시지
                </h4>
                <div :class="['alert', getMessageAlertClass(selectedLog.status), 'border-0']">
                  <span class="text-sm">{{ translateMessage(selectedLog.message, selectedLog) }}</span>
                </div>
              </div>

              <!-- 진행률 표시 -->
              <div class="rounded-2xl bg-base-200/30 border border-white/10 shadow p-6" v-if="detailLogs.length > 0">
                <h4 class="font-bold text-white flex items-center gap-2 text-sm mb-5">
                  <span class="w-7 h-7 rounded-lg bg-success/20 flex items-center justify-center text-xs">📈</span>
                  진행률
                </h4>
                <div class="flex flex-col gap-4">
                  <div class="flex justify-between text-sm">
                    <span class="text-base-content/60">완료된 단계</span>
                    <span class="font-mono text-white/90">{{ detailLogs.length }}/{{ getExpectedSteps() }}</span>
                  </div>
                  <progress
                    class="progress progress-primary w-full"
                    :value="detailLogs.length"
                    :max="getExpectedSteps()">
                  </progress>
                  <div class="flex justify-between items-center">
                    <div class="text-xs text-base-content/50">
                      {{ Math.round((detailLogs.length / getExpectedSteps()) * 100) }}% 완료
                    </div>
                    <div class="text-xs text-base-content/50">
                      남은 단계: {{ getExpectedSteps() - detailLogs.length }}개
                    </div>
                  </div>

                  <!-- 현재 상태 표시 -->
                  <div class="mt-1 p-3 bg-base-300/50 rounded-xl border border-white/5">
                    <div class="text-xs text-base-content/60 mb-1.5">현재 상태</div>
                    <div class="flex items-center gap-2">
                      <div :class="['w-2.5 h-2.5 rounded-full', getProcessStatusColor()]"></div>
                      <span class="text-sm font-semibold text-white">{{ getProcessStatusText() }}</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <!-- 메인 타임라인 -->
            <div class="lg:col-span-2 flex flex-col h-full">
              <div class="rounded-2xl bg-base-200/30 border border-white/10 shadow-lg overflow-hidden flex flex-col h-full">
                <div class="p-6 flex flex-col h-full">
                  <h4 class="font-bold text-white flex items-center gap-2 text-sm mb-5 shrink-0">
                    <span class="w-7 h-7 rounded-lg bg-warning/20 flex items-center justify-center text-xs">🔄</span>
                    단계별 실행 로그
                    <div class="badge badge-neutral badge-sm ml-1">{{ detailLogs.length }}단계</div>
                  </h4>

                  <!-- 로딩 상태 -->
                  <div v-if="isLoadingHeartbeat" class="flex-1 flex flex-col items-center justify-center text-center py-12">
                    <div class="loading loading-spinner loading-lg text-primary"></div>
                    <p class="text-base-content/60 mt-4">하트비트 로그를 불러오는 중...</p>
                    <p class="text-xs text-base-content/40 mt-2">로그 ID: {{ selectedLog?.id }}</p>
                  </div>

                  <!-- 데이터 없음 -->
                  <div v-else-if="!isLoadingHeartbeat && detailLogs.length === 0" class="flex-1 flex flex-col items-center justify-center text-center py-12">
                    <div class="text-warning text-5xl mb-4">⚠️</div>
                    <p class="text-base-content/60 font-medium">이 로그에 대한 하트비트 데이터가 없습니다.</p>
                    <p class="text-xs text-base-content/40 mt-3">로그 ID: {{ selectedLog?.id }}</p>
                  </div>

                  <!-- 타임라인 -->
                  <div v-else class="flex-1 overflow-y-auto pr-2 custom-scrollbar">
                    <div class="flex flex-col gap-4">
                      <div v-for="(detail, index) in detailLogs" :key="index"
                           class="flex items-start gap-4 p-4 rounded-xl bg-base-300/30 border border-white/5 hover:bg-base-300/50 hover:border-white/10 transition-all duration-200">
                        <!-- 단계 번호와 아이콘 -->
                        <div class="flex flex-col items-center gap-2">
                          <div :class="['w-9 h-9 rounded-full flex items-center justify-center text-xs font-bold text-white shadow-md', getStageColor(detail.stage)]">
                            {{ index + 1 }}
                          </div>
                          <div v-if="index < detailLogs.length - 1" class="w-0.5 h-6 bg-base-content/10"></div>
                        </div>

                        <!-- 내용 -->
                        <div class="flex-1 min-w-0 flex flex-col gap-2">
                          <div class="flex items-center justify-between">
                            <h5 class="font-semibold text-white">{{ translateStage(detail.stage) }}</h5>
                            <span class="text-xs font-mono text-base-content/50 bg-base-300/50 px-2 py-0.5 rounded">{{ formatTime(detail.timestamp) }}</span>
                          </div>
                          <div class="text-sm text-base-content/60">{{ getStageDescription(detail.stage) }}</div>
                          <div class="flex items-center gap-2 text-xs">
                            <div class="badge badge-outline badge-xs">{{ detail.stage }}</div>
                            <div class="badge badge-ghost badge-xs">PID: {{ detail.pid }}</div>
                          </div>
                        </div>

                        <!-- 소요 시간 -->
                        <div class="text-right shrink-0">
                          <div class="text-xs font-mono text-base-content/50">
                            {{ index > 0 ? calculateStepDuration(detailLogs[index-1].timestamp, detail.timestamp) : '시작' }}
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 비밀번호 변경 모달 -->
    <div v-if="showPasswordModal" class="modal modal-open" @click.self="closePasswordModal">
      <div class="modal-box max-w-md bg-gradient-to-br from-base-100 via-base-100 to-primary/5 border border-white/10 shadow-2xl backdrop-blur-xl relative overflow-hidden">
        <!-- 배경 장식 -->
        <div class="absolute top-0 right-0 w-64 h-64 bg-primary/10 rounded-full blur-3xl -translate-y-1/2 translate-x-1/2"></div>
        <div class="absolute bottom-0 left-0 w-48 h-48 bg-secondary/10 rounded-full blur-3xl translate-y-1/2 -translate-x-1/2"></div>

        <!-- 모든 콘텐츠를 flex gap으로 감싸서 간격 보장 -->
        <div class="relative flex flex-col gap-6">
          <!-- 헤더 -->
          <div class="flex items-center justify-between">
            <div class="flex items-center gap-3">
              <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-primary to-secondary flex items-center justify-center shadow-lg">
                <svg xmlns="http://www.w3.org/2000/svg" class="w-5 h-5 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                </svg>
              </div>
              <div>
                <h3 class="text-xl font-bold text-white">비밀번호 변경</h3>
                <p class="text-xs text-base-content/60">보안을 위해 정기적으로 변경하세요</p>
              </div>
            </div>
            <button @click="closePasswordModal" class="btn btn-sm btn-circle btn-ghost hover:bg-white/10">
              <svg xmlns="http://www.w3.org/2000/svg" class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>

          <!-- 에러 메시지 -->
          <div v-if="passwordError" class="alert alert-error shadow-lg border border-error/20 animate-shake">
            <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-5 w-5" fill="none" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            <span class="text-sm font-medium">{{ passwordError }}</span>
          </div>

          <!-- 입력 폼 -->
          <div class="flex flex-col gap-5">
            <!-- 현재 비밀번호 -->
            <div class="form-control">
              <label class="label pb-2">
                <span class="label-text font-semibold text-white flex items-center gap-2">
                  <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4 text-primary" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 7a2 2 0 012 2m4 0a6 6 0 01-7.743 5.743L11 17H9v2H7v2H4a1 1 0 01-1-1v-2.586a1 1 0 01.293-.707l5.964-5.964A6 6 0 1121 9z" />
                  </svg>
                  현재 비밀번호
                </span>
              </label>
              <input
                type="password"
                placeholder="현재 비밀번호를 입력하세요"
                class="input input-bordered w-full bg-base-200/50 backdrop-blur-sm border-white/10 focus:border-primary/50 focus:bg-base-200 transition-all duration-200 text-white placeholder:text-base-content/40"
                v-model="currentPassword"
                @keyup.enter="handleChangePassword"
              />
            </div>

            <!-- 구분선 -->
            <div class="divider text-xs text-base-content/40">새 비밀번호 설정</div>

            <!-- 새 비밀번호 -->
            <div class="form-control">
              <label class="label pb-2">
                <span class="label-text font-semibold text-white flex items-center gap-2">
                  <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4 text-secondary" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                  </svg>
                  새 비밀번호
                </span>
              </label>
              <input
                type="password"
                placeholder="새 비밀번호를 입력하세요"
                class="input input-bordered w-full bg-base-200/50 backdrop-blur-sm border-white/10 focus:border-secondary/50 focus:bg-base-200 transition-all duration-200 text-white placeholder:text-base-content/40"
                v-model="newPassword"
                @keyup.enter="handleChangePassword"
              />
              <label class="label pt-1">
                <span class="label-text-alt text-base-content/50 text-xs">최소 6자 이상 권장</span>
              </label>
            </div>

            <!-- 새 비밀번호 확인 -->
            <div class="form-control">
              <label class="label pb-2">
                <span class="label-text font-semibold text-white flex items-center gap-2">
                  <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4 text-accent" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                  비밀번호 확인
                </span>
              </label>
              <input
                type="password"
                placeholder="새 비밀번호를 다시 입력하세요"
                class="input input-bordered w-full bg-base-200/50 backdrop-blur-sm border-white/10 focus:border-accent/50 focus:bg-base-200 transition-all duration-200 text-white placeholder:text-base-content/40"
                v-model="confirmPassword"
                @keyup.enter="handleChangePassword"
              />
            </div>
          </div>

          <!-- 액션 버튼 -->
          <div class="flex gap-3">
            <button
              @click="closePasswordModal"
              class="btn flex-1 btn-outline border-white/20 hover:bg-white/10 hover:border-white/30 text-white"
            >
              <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
              </svg>
              취소
            </button>
            <button
              @click="handleChangePassword"
              :disabled="!currentPassword || !newPassword || !confirmPassword || isChangingPassword"
              class="btn flex-1 btn-primary bg-gradient-to-r from-primary to-secondary border-0 hover:scale-105 transition-all duration-200 shadow-lg disabled:opacity-50 disabled:scale-100"
            >
              <span v-if="isChangingPassword" class="loading loading-spinner loading-sm"></span>
              <svg v-else xmlns="http://www.w3.org/2000/svg" class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
              </svg>
              {{ isChangingPassword ? '변경 중...' : '비밀번호 변경' }}
            </button>
          </div>

          <!-- 보안 팁 -->
          <div class="p-3 bg-info/10 border border-info/20 rounded-lg">
            <div class="flex items-start gap-2">
              <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4 text-info mt-0.5 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
              <div class="text-xs text-base-content/70">
                <p class="font-semibold text-white">보안 팁</p>
                <ul class="list-disc list-inside flex flex-col gap-0.5 text-base-content/60">
                  <li>숫자, 영문, 특수문자를 조합하세요</li>
                  <li>개인정보는 사용하지 마세요</li>
                </ul>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 회원탈퇴 확인 모달 -->
    <div v-if="showDeleteModal" class="modal modal-open">
      <div class="modal-box max-w-md">
        <div class="flex items-center justify-between mb-6">
          <h3 class="text-xl font-bold text-error">⚠️ 회원탈퇴</h3>
          <button @click="showDeleteModal = false" class="btn btn-sm btn-circle btn-ghost">
            ✕
          </button>
        </div>

        <div class="flex flex-col gap-4">
          <div class="alert alert-error">
            <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z"></path>
            </svg>
            <div>
              <h4 class="font-bold">데이터 완전삭제 경고</h4>
              <p class="text-sm">모든 데이터가 영구적으로 삭제됩니다. 관리자도 복구할 수 없습니다.</p>
            </div>
          </div>

          <div class="bg-base-200 p-4 rounded-lg">
            <h4 class="font-semibold mb-2">삭제될 데이터:</h4>
            <ul class="text-sm flex flex-col gap-1 text-base-content/70">
              <li>• 계정 정보 (사용자 ID, 비밀번호)</li>
              <li>• 모든 출퇴근 기록</li>
              <li>• 상세 진행단계 로그 기록</li>
              <li>• 기타 모든 활동 기록</li>
            </ul>
          </div>

          <div class="bg-warning/10 p-4 rounded-lg border border-warning/20">
            <p class="text-sm font-medium">재가입 시에도 이전 데이터는 복구되지 않습니다.</p>
          </div>

          <div class="form-control">
            <label class="label cursor-pointer justify-start gap-3">
              <input
                type="checkbox"
                class="checkbox checkbox-error"
                v-model="deleteConfirmed"
              />
              <span class="text-sm">위 내용을 이해했으며, 회원탈퇴에 동의합니다.</span>
            </label>
          </div>
        </div>

        <div class="modal-action">
          <button @click="showDeleteModal = false" class="btn btn-ghost">
            취소
          </button>
          <button
            @click="handleDeleteAccount"
            :disabled="!deleteConfirmed"
            class="btn btn-error"
            :class="{ 'loading': isDeleting }"
          >
            {{ isDeleting ? '삭제 중...' : '회원탈퇴' }}
          </button>
        </div>
      </div>
    </div>
    <!-- 날짜 선택 모달 (출근/휴무 지정) - Redesigned -->
    <div v-if="showScheduleModal" class="modal modal-open bg-black/40 backdrop-blur-sm transition-all duration-300">
      <div class="modal-box max-w-md bg-base-100/95 backdrop-blur-xl border border-base-content/10 shadow-2xl p-0 overflow-hidden transform transition-all scale-100">
        <!-- 헤더 섹션 -->
        <div class="bg-base-200/50 p-6 border-b border-base-content/5 text-center relative">
          <button @click="showScheduleModal = false" class="btn btn-sm btn-circle btn-ghost absolute right-4 top-4">✕</button>

          <h3 class="font-extrabold text-2xl mb-1 text-white inline-block">
            {{ selectedDateInfo.dateStr }}
          </h3>
          <p class="text-sm font-medium text-base-content/60">
            {{ selectedDateInfo.isWorkday ? '현재: 정상 근무일 🏢' : '현재: 휴무일 🏠' }}
          </p>
        </div>

        <!-- 선택 카드 섹션 -->
        <div class="p-6 grid grid-cols-2 gap-4">
          <!-- 근무 카드 -->
          <button
            @click="updateSchedule('work')"
            class="group relative flex flex-col items-center justify-center p-6 rounded-2xl border-2 transition-all duration-200 hover:scale-[1.02] active:scale-95"
            :class="selectedDateInfo.isWorkday
              ? 'bg-primary/5 border-primary shadow-lg shadow-primary/10'
              : 'bg-base-100 border-base-200 hover:border-primary/50 hover:bg-primary/5'"
          >
            <div class="w-14 h-14 rounded-full flex items-center justify-center mb-3 transition-colors"
                 :class="selectedDateInfo.isWorkday ? 'bg-primary text-white' : 'bg-base-200 text-white group-hover:bg-primary group-hover:text-white'">
              <svg xmlns="http://www.w3.org/2000/svg" class="w-7 h-7" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 13.255A23.931 23.931 0 0112 15c-3.183 0-6.22-.62-9-1.745M16 6V4a2 2 0 00-2-2h-4a2 2 0 00-2 2v2m4 6h.01M5 20h14a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" /></svg>
            </div>
            <span class="font-bold text-lg mb-1" :class="selectedDateInfo.isWorkday ? 'text-primary' : 'text-white'">출근</span>
            <span class="text-xs text-white/50 text-center">정상 근무일로<br>설정합니다</span>

            <div v-if="selectedDateInfo.isWorkday" class="absolute top-3 right-3 text-primary">
              <svg xmlns="http://www.w3.org/2000/svg" class="w-5 h-5" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" /></svg>
            </div>
          </button>

          <!-- 휴무 카드 -->
          <button
            @click="updateSchedule('rest')"
            class="group relative flex flex-col items-center justify-center p-6 rounded-2xl border-2 transition-all duration-200 hover:scale-[1.02] active:scale-95"
            :class="!selectedDateInfo.isWorkday
              ? 'bg-secondary/5 border-secondary shadow-lg shadow-secondary/10'
              : 'bg-base-100 border-base-200 hover:border-secondary/50 hover:bg-secondary/5'"
          >
            <div class="w-14 h-14 rounded-full flex items-center justify-center mb-3 transition-colors"
                 :class="!selectedDateInfo.isWorkday ? 'bg-secondary text-white' : 'bg-base-200 text-white group-hover:bg-secondary group-hover:text-white'">
              <svg xmlns="http://www.w3.org/2000/svg" class="w-7 h-7" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z" /></svg>
            </div>
            <span class="font-bold text-lg mb-1" :class="!selectedDateInfo.isWorkday ? 'text-secondary' : 'text-white'">휴무</span>
            <span class="text-xs text-white/50 text-center">휴무일로<br>설정합니다</span>

            <div v-if="!selectedDateInfo.isWorkday" class="absolute top-3 right-3 text-secondary">
              <svg xmlns="http://www.w3.org/2000/svg" class="w-5 h-5" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" /></svg>
            </div>
          </button>
        </div>

        <div class="p-4 pt-0">
          <button @click="showScheduleModal = false" class="btn btn-ghost btn-block btn-sm text-base-content/50 hover:text-base-content">
            취소
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  line-height: 1.4;
  max-height: 2.8em;
  text-overflow: ellipsis;
  word-wrap: break-word;
  hyphens: auto;
}

/* Fallback for browsers that don't support -webkit-line-clamp */
@supports not (-webkit-line-clamp: 2) {
  .line-clamp-2 {
    position: relative;
    max-height: 2.8em;
    overflow: hidden;
  }

  .line-clamp-2::after {
    content: '...';
    position: absolute;
    right: 0;
    bottom: 0;
    background: linear-gradient(to right, transparent, var(--fallback-b1, oklch(var(--b1))) 50%);
    padding-left: 1rem;
  }
}
</style>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const authStore = useAuthStore()

const serverStatus = ref({
  main: false,
  watchdog: false
})

const todayStatus = ref({
  punchIn: '',
  punchOut: ''
})

const logs = ref<any[]>([])
const reversedLogs = computed(() => {
  return [...logs.value].sort((a, b) => new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime())
})
const selectedLog = ref<any>(null)
const detailLogs = ref<any[]>([])
const isLoadingHeartbeat = ref(false)
const isActive = ref(false)
const showDeleteModal = ref(false)
const deleteConfirmed = ref(false)
const isDeleting = ref(false)

// 날짜 선택 모달 관련
const showScheduleModal = ref(false)
const selectedDateInfo = ref({
  date: '',
  dateStr: '',
  status: '',
  isWorkday: false,
  day: 0
})

// 비밀번호 변경 관련
const showPasswordModal = ref(false)
const currentPassword = ref('')
const newPassword = ref('')
const confirmPassword = ref('')
const passwordError = ref('')
const isChangingPassword = ref(false)

let refreshInterval: number | null = null

const handleLogout = () => {
  authStore.logout()
  router.push('/login')
}

const fetchServerStatus = async () => {
  try {
    const response = await fetch('/api/web/server/status', {
      headers: authStore.getAuthHeaders()
    })
    const data = await response.json()
    if (data.success) {
      serverStatus.value = data.status
    }
  } catch (error) {
    console.error('Server status fetch error:', error)
    // 로컬 개발 환경용 모의 데이터
    if (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1') {
      serverStatus.value = {
        main: true,
        watchdog: true
      }
    }
  }
}

const fetchTodayStatus = async () => {
  try {
    const response = await fetch('/api/web/user/summary', {
      headers: authStore.getAuthHeaders()
    })
    const data = await response.json()
    if (data.success) {
      // API 응답 구조에 맞게 상태 업데이트
      todayStatus.value = {
        punchIn: data.status.punchIn,
        punchOut: data.status.punchOut
      }
    }
  } catch (error) {
    console.error('Today status fetch error:', error)
    // 로컬 개발 환경용 모의 데이터
    if (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1') {
      todayStatus.value = {
        punchIn: '08:55',
        punchOut: ''
      }
    }
  }
}

const fetchLogs = async () => {
  try {
    const response = await fetch('/api/web/user/attendance?limit=50', {
      headers: authStore.getAuthHeaders()
    })
    const data = await response.json()
    console.log('API response:', data) // 디버그용 로그
    if (data.success) {
      logs.value = data.logs || [] // 올바른 응답 구조로 수정
    } else {
      console.error('API error:', data.error)
    }
  } catch (error) {
    console.error('Logs fetch error:', error)
    // 로컬 개발 환경용 모의 데이터
    if (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1') {
      logs.value = [
        { id: 1, timestamp: new Date().toISOString(), status: 'INFO', message: '출근 체크가 완료되었습니다.', action_type: 'PUNCH_IN' },
        { id: 2, timestamp: new Date(Date.now() - 3600000).toISOString(), status: 'SUCCESS', message: '시스템 초기화 완료', action_type: 'SYSTEM' }
      ]
    }
  }
}

const fetchUserStatus = async () => {
  try {
    const response = await fetch('/api/web/user/status', {
      headers: authStore.getAuthHeaders()
    })
    const data = await response.json()
    if (data.success) {
      isActive.value = data.is_active
    }
  } catch (error) {
    console.error('User status fetch error:', error)
    // 로컬 개발 환경용 모의 데이터
    if (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1') {
      isActive.value = true
    }
  }
}

const updateUserStatus = async () => {
  try {
    const response = await fetch('/api/web/user/status', {
      method: 'PUT',
      headers: {
        ...authStore.getAuthHeaders(),
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ is_active: isActive.value })
    })
    const data = await response.json()
    if (data.success) {
      console.log('User status updated:', isActive.value)
    } else {
      console.error('Status update error:', data.error)
      // 실패시 원래 상태로 되돌리기
      isActive.value = !isActive.value
    }
  } catch (error) {
    console.error('Status update error:', error)
    // 실패시 원래 상태로 되돌리기
    isActive.value = !isActive.value
  }
}

const handleDeleteAccount = async () => {
  if (!deleteConfirmed.value) return

  isDeleting.value = true
  try {
    const response = await fetch('/api/web/user/delete', {
      method: 'DELETE',
      headers: authStore.getAuthHeaders()
    })
    const data = await response.json()

    if (data.success) {
      alert('계정이 완전히 삭제되었습니다.')
      authStore.logout()
      router.push('/login')
    } else {
      alert(`계정 삭제 실패: ${data.error}`)
    }
  } catch (error) {
    console.error('Account deletion error:', error)
    alert('계정 삭제 중 오류가 발생했습니다.')
  } finally {
    isDeleting.value = false
    showDeleteModal.value = false
    deleteConfirmed.value = false
  }
}

const closePasswordModal = () => {
  showPasswordModal.value = false
  currentPassword.value = ''
  newPassword.value = ''
  confirmPassword.value = ''
  passwordError.value = ''
}

const handleChangePassword = async () => {
  // 입력값 검증
  if (!currentPassword.value || !newPassword.value || !confirmPassword.value) {
    passwordError.value = '모든 필드를 입력해주세요.'
    return
  }

  if (newPassword.value !== confirmPassword.value) {
    passwordError.value = '새 비밀번호가 일치하지 않습니다.'
    return
  }

  if (newPassword.value.length < 4) {
    passwordError.value = '새 비밀번호는 최소 4자 이상이어야 합니다.'
    return
  }

  if (currentPassword.value === newPassword.value) {
    passwordError.value = '현재 비밀번호와 새 비밀번호가 동일합니다.'
    return
  }

  isChangingPassword.value = true
  passwordError.value = ''

  try {
    const response = await fetch('/api/web/user/password', {
      method: 'PUT',
      headers: {
        ...authStore.getAuthHeaders(),
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        current_password: currentPassword.value,
        new_password: newPassword.value
      })
    })

    const data = await response.json()

    if (data.success) {
      alert('비밀번호가 성공적으로 변경되었습니다.')
      closePasswordModal()
    } else {
      passwordError.value = data.error || '비밀번호 변경에 실패했습니다.'
    }
  } catch (error) {
    console.error('Password change error:', error)
    passwordError.value = '비밀번호 변경 중 오류가 발생했습니다.'
  } finally {
    isChangingPassword.value = false
  }
}

const getBadgeVariant = (status: string) => {
  switch (status) {
    case 'success':
    case '성공':
      return 'badge-success'
    case 'error':
    case 'failed':
    case '실패':
      return 'badge-error'
    case 'already_done':
    case '이미 완료':
      return 'badge-info'
    default:
      return 'badge-warning'
  }
}

const translateActionType = (type: string) => {
  const translations: Record<string, string> = {
    'punch_in': '출근',
    'punch_out': '퇴근'
  }
  return translations[type] || type
}

const translateStatus = (status: string) => {
  const translations: Record<string, string> = {
    'success': '성공',
    'error': '실패',
    'failed': '실패',
    'already_done': '이미 완료'
  }
  return translations[status] || status
}

const translateMessage = (message: string, log?: any) => {
  if (!message && log) {
    const action = log.action_type === 'punch_in' ? '출근' : log.action_type === 'punch_out' ? '퇴근' : ''
    const defaults: Record<string, string> = {
      'success': `${action} 처리가 정상적으로 완료되었습니다.`,
      'already_done': `${action} 이미 처리된 상태입니다.`,
      'failed': `${action} 처리 중 오류가 발생했습니다.`,
    }
    return defaults[log.status] || ''
  }
  if (!message) return ''

  const translations: Record<string, string> = {
    'Login successful': '로그인 성공',
    'Button clicked successfully': '버튼 클릭 성공',
    'Already punched in': '이미 출근 처리됨',
    'Already punched out': '이미 퇴근 처리됨',
    'Login failed': '로그인 실패',
    'Button not found': '버튼을 찾을 수 없음'
  }

  for (const [en, ko] of Object.entries(translations)) {
    if (message.includes(en)) {
      return message.replace(en, ko)
    }
  }

  return message
}

const formatTime = (timestamp: string) => {
  if (!timestamp) return '-'
  const date = new Date(timestamp)
  if (isNaN(date.getTime())) return '-'

  const month = String(date.getMonth() + 1).padStart(2, '0')
  const day = String(date.getDate()).padStart(2, '0')
  const hours = String(date.getHours()).padStart(2, '0')
  const minutes = String(date.getMinutes()).padStart(2, '0')
  const seconds = String(date.getSeconds()).padStart(2, '0')

  return `${month}-${day} ${hours}:${minutes}:${seconds}`
}





const showDetailModal = async (log: any) => {
  selectedLog.value = log

  // 더미 데이터 생성 (시각적 확인용) - 로컬 개발 환경에서만 동작
  if (!log.details || log.details.length === 0) {
    const dummyModules = import.meta.glob('@/utils/logDummyData.ts')
    const loader = dummyModules['/src/utils/logDummyData.ts']
    if (loader) {
      const mod = await loader() as { getDummyLogs: (timestamp: string) => any[] }
      detailLogs.value = mod.getDummyLogs(log.timestamp)
    } else {
      detailLogs.value = []
    }
  } else {
    detailLogs.value = [];
    isLoadingHeartbeat.value = true;
    await fetchDetailLogs(log.id);
  }
}

const fetchDetailLogs = async (logId: number) => {
  console.log(`🔍 하트비트 API 요청 시작: logId=${logId}`)

  try {
    // 요청 헤더 확인
    const headers = authStore.getAuthHeaders()
    console.log('📋 요청 헤더:', headers)

    // attendance_log_id를 기반으로 하트비트 조회
    const url = `/api/web/user/attendance/${logId}/heartbeat`
    console.log(`🌐 요청 URL: ${url}`)

    console.log('⏳ fetch 시작...')
    const response = await fetch(url, {
      headers: headers,
      method: 'GET'
    })

    console.log(`📡 응답 상태: ${response.status} ${response.statusText}`)
    console.log('📦 응답 헤더:', [...response.headers.entries()])

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`)
    }

    console.log('🔄 JSON 파싱 시작...')
    const data = await response.json()
    console.log('✅ Heartbeat API 응답:', data)

    if (data.success) {
      detailLogs.value = data.heartbeats || []
      console.log(`📊 하트비트 로그 ${detailLogs.value.length}개 로드됨`)
    } else {
      console.error('❌ API 에러:', data.error)
      detailLogs.value = []
    }
  } catch (error: any) {
    console.error('💥 하트비트 로그 fetch 에러:', error)
    console.error('에러 스택:', error.stack)
    detailLogs.value = []

    // 사용자에게 에러 표시
    alert(`하트비트 로그를 불러오는데 실패했습니다: ${error.message}`)
  } finally {
    isLoadingHeartbeat.value = false
  }
}

const getStageColor = (stage: string) => {
  // 완료 단계 (성공적으로 끝난 작업)
  if (stage.includes('complete') || stage.includes('success') || stage.includes('clicked_success') || stage.includes('created') || stage.includes('loaded')) return 'bg-success'

  // 오류/실패 단계
  if (stage.includes('failed') || stage.includes('error') || stage.includes('오류')) return 'bg-error'

  // 이미 완료된 상태 (스킵)
  if (stage.includes('already_completed')) return 'bg-info'

  // 상태 확인 단계
  if (stage.includes('checking') || stage.includes('not_completed_yet')) return 'bg-secondary'

  // 시작 단계
  if (stage.includes('start') || stage.includes('init')) return 'bg-primary'

  // 진행중/대기 단계
  if (stage.includes('wait') || stage.includes('load') || stage.includes('fill') || stage.includes('navigation')) return 'bg-warning'

  // 기본
  return 'bg-info'
}

const translateStage = (stage: string) => {
  const stageTranslations: Record<string, string> = {
    'process_start': '🚀 프로세스 시작',
    'playwright_init': '🎭 Playwright 초기화',
    'browser_started': '🌐 브라우저 시작',
    'context_created': '📄 브라우저 컨텍스트 생성',
    'page_creation_start': '📋 페이지 생성 시작',
    'page_creation_attempt_1': '📋 페이지 생성 시도 #1',
    'page_created': '📄 페이지 생성 완료',
    'login_start': '🔐 로그인 시작',
    'page_navigation': '🧭 페이지 이동',
    'page_loaded': '📥 페이지 로드 완료',
    'login_form_loaded': '📝 로그인 폼 로드',
    'userid_filled': '👤 사용자 ID 입력',
    'password_filled': '🔑 비밀번호 입력',
    'login_button_click': '🖱️ 로그인 버튼 클릭',
    'main_page_wait': '⏳ 메인 페이지 대기',
    'main_page_loaded': '🏠 메인 페이지 로드',
    'page_load_wait': '⏳ 페이지 로드 대기',
    'page_load_complete': '✅ 페이지 로드 완료',
    'login_success': '🎉 로그인 성공',
    'page_stabilize_wait': '⏳ 페이지 안정화 대기',
    'checking_punch_in_status': '🔍 출근 상태 확인',
    'checking_punch_out_status': '🔍 퇴근 상태 확인',
    'punch_in_already_completed': '✅ 출근 이미 완료됨',
    'punch_out_already_completed': '✅ 퇴근 이미 완료됨',
    'punch_in_not_completed_yet': '⏰ 출근 미완료 상태',
    'punch_out_not_completed_yet': '⏰ 퇴근 미완료 상태',
    'popup_close_start': '❌ 팝업 닫기 시작',
    'popup_close_complete': '✅ 팝업 닫기 완료',
    'button_click_start': '🎯 버튼 클릭 시작',
    'button_clicked_success': '✅ 버튼 클릭 성공',
    'process_complete': '🏁 프로세스 완료'
  }
  return stageTranslations[stage] || stage
}

const getStageDescription = (stage: string) => {
  const descriptions: Record<string, string> = {
    'process_start': '출퇴근 자동화 프로세스를 시작합니다',
    'playwright_init': 'Playwright 브라우저 자동화 엔진을 초기화합니다',
    'browser_started': 'Chromium 브라우저를 백그라운드에서 실행합니다',
    'context_created': '격리된 브라우저 컨텍스트를 생성합니다',
    'page_creation_start': '새로운 웹 페이지 생성을 시작합니다',
    'page_creation_attempt_1': '페이지 생성을 시도합니다',
    'page_created': '웹 페이지가 성공적으로 생성되었습니다',
    'login_start': '회사 로그인 페이지로 이동을 시작합니다',
    'page_navigation': '로그인 페이지로 이동중입니다',
    'page_loaded': '로그인 페이지 로드가 완료되었습니다',
    'login_form_loaded': '로그인 폼이 화면에 표시되었습니다',
    'userid_filled': '사용자 ID를 입력필드에 채웠습니다',
    'password_filled': '비밀번호를 입력필드에 채웠습니다',
    'login_button_click': '로그인 버튼을 클릭했습니다',
    'main_page_wait': '로그인 후 메인 페이지 로드를 기다립니다',
    'main_page_loaded': '메인 페이지가 성공적으로 로드되었습니다',
    'page_load_wait': '페이지의 모든 요소가 로드되길 기다립니다',
    'page_load_complete': '페이지 로드가 완전히 완료되었습니다',
    'login_success': '로그인이 성공적으로 완료되었습니다',
    'page_stabilize_wait': '페이지가 안정화되길 기다립니다',
    'checking_punch_in_status': '현재 출근 상태를 확인합니다',
    'checking_punch_out_status': '현재 퇴근 상태를 확인합니다',
    'punch_in_already_completed': '이미 출근 처리가 완료된 상태입니다',
    'punch_out_already_completed': '이미 퇴근 처리가 완료된 상태입니다',
    'punch_in_not_completed_yet': '출근 처리가 아직 완료되지 않았습니다',
    'punch_out_not_completed_yet': '퇴근 처리가 아직 완료되지 않았습니다',
    'popup_close_start': '방해되는 팝업창들을 닫기 시작합니다',
    'popup_close_complete': '모든 팝업창이 성공적으로 닫혔습니다',
    'button_click_start': '출퇴근 버튼을 찾고 클릭을 시도합니다',
    'button_clicked_success': '출퇴근 버튼 클릭이 성공했습니다',
    'process_complete': '모든 과정이 성공적으로 완료되었습니다'
  }
  return descriptions[stage] || '단계를 실행중입니다'
}

const getMessageAlertClass = (status: string) => {
  switch (status) {
    case 'success':
      return 'alert-soft alert-success'
    case 'error':
    case 'failed':
      return 'alert-soft alert-error'
    case 'already_done':
      return 'alert-soft alert-info'
    default:
      return 'alert-soft alert-warning'
  }
}

const getLastStageTime = () => {
  if (detailLogs.value.length === 0) return ''
  return detailLogs.value[detailLogs.value.length - 1].timestamp
}

const calculateDuration = () => {
  if (detailLogs.value.length === 0) return '0초'
  const start = new Date(detailLogs.value[0].timestamp)
  const end = new Date(detailLogs.value[detailLogs.value.length - 1].timestamp)
  const diff = Math.round((end.getTime() - start.getTime()) / 1000)
  return `${diff}초`
}

const calculateStepDuration = (prevTime: string, currentTime: string) => {
  const prev = new Date(prevTime)
  const current = new Date(currentTime)
  const diff = Math.round((current.getTime() - prev.getTime()) / 1000)
  return `+${diff}초`
}

const getExpectedSteps = () => {
  if (!selectedLog.value) return 30

  const actionType = selectedLog.value.action_type
  const status = selectedLog.value.status
  const currentSteps = detailLogs.value.length

  // 완료된 프로세스인 경우, 실제 실행된 단계 수를 사용
  if (status === 'success' || status === 'already_done' || status === 'failed') {
    // 완료된 프로세스는 현재 단계 수가 실제 총 단계 수
    return Math.max(currentSteps, 20) // 최소 20단계는 보장
  }

  // 진행중인 프로세스인 경우, 예상 단계 수 계산
  if (actionType === 'punch_in') {
    // 출근 프로세스: 평균 25-30단계
    return 30  // 여유있게 설정
  } else if (actionType === 'punch_out') {
    // 퇴근 프로세스: 평균 27-32단계
    return 32  // 여유있게 설정
  }

  // 기본값
  return 30
}

const getProcessStatusColor = () => {
  if (!selectedLog.value) return 'bg-gray-400'

  const status = selectedLog.value.status
  const currentSteps = detailLogs.value.length
  const totalSteps = getExpectedSteps()

  // 완료 상태
  if (status === 'success') return 'bg-success'
  if (status === 'already_done') return 'bg-info'
  if (status === 'failed') return 'bg-error'

  // 진행중 상태 (in_progress)
  if (status === 'in_progress') {
    if (currentSteps === 0) return 'bg-warning' // 시작 전
    if (currentSteps >= totalSteps * 0.8) return 'bg-success' // 거의 완료
    if (currentSteps >= totalSteps * 0.5) return 'bg-primary' // 중간 진행
    return 'bg-warning' // 초기 진행
  }

  return 'bg-gray-400'
}

const getProcessStatusText = () => {
  if (!selectedLog.value) return '상태 불명'

  const status = selectedLog.value.status
  const currentSteps = detailLogs.value.length
  const totalSteps = getExpectedSteps()
  const actionType = selectedLog.value.action_type === 'punch_in' ? '출근' : '퇴근'

  // 완료 상태
  if (status === 'success') return `${actionType} 성공 완료`
  if (status === 'already_done') return `${actionType} 이미 완료됨`
  if (status === 'failed') return `${actionType} 처리 실패`

  // 진행중 상태
  if (status === 'in_progress') {
    if (currentSteps === 0) return `${actionType} 처리 대기중`
    if (currentSteps >= totalSteps * 0.8) return `${actionType} 처리 거의 완료`
    if (currentSteps >= totalSteps * 0.5) return `${actionType} 처리 진행중`
    return `${actionType} 처리 시작됨`
  }

  return '상태 확인중'
}

// ==================== 달력 관련 ====================

const schedules = ref<any[]>([])
const scheduleCache = ref(new Map<string, any[]>()) // 월별 스케줄 캐시 (key: "YYYY-MM")
const yearlyCache = ref(new Map<number, any[]>()) // 연도별 스케줄 캐시 (key: YYYY)

const togglingDates = ref(new Set<string>()) // 토글 중인 날짜들을 추적
const currentYear = ref(new Date().getFullYear())
const currentMonth = ref(new Date().getMonth() + 1)



// 달력 함수들
const changeMonth = (direction: number) => {
  const oldYear = currentYear.value
  const newMonth = currentMonth.value + direction

  if (newMonth > 12) {
    currentYear.value += 1
    currentMonth.value = 1
  } else if (newMonth < 1) {
    currentYear.value -= 1
    currentMonth.value = 12
  } else {
    currentMonth.value = newMonth
  }

  // 연도가 바뀌면 새로운 1년치 데이터 백그라운드 로드
  if (oldYear !== currentYear.value) {
    setTimeout(() => {
      fetchYearlySchedules(currentYear.value)
    }, 10)
  }

  fetchSchedules()
}

const prevMonth = () => changeMonth(-1)
const nextMonth = () => changeMonth(1)
const resetToToday = () => {
  const now = new Date()
  const current = new Date(currentYear.value, currentMonth.value - 1)

  if (current.getFullYear() !== now.getFullYear() || current.getMonth() !== now.getMonth()) {
    currentYear.value = now.getFullYear()
    currentMonth.value = now.getMonth() + 1
    changeMonth(0) // Refresh
  }
}

const isToday = (date: any) => {
  if (!date.isCurrentMonth) return false
  const now = new Date()
  return now.getDate() === date.day &&
         currentMonth.value === now.getMonth() + 1 &&
         currentYear.value === now.getFullYear()
}

const weekDays = ['일', '월', '화', '수', '목', '금', '토']

const calendarDays = computed(() => {
  const year = currentYear.value
  const month = currentMonth.value - 1
  const firstDay = new Date(year, month, 1)
  const lastDay = new Date(year, month + 1, 0)

  const days = []

  // Previous month days
  const startDayOfWeek = firstDay.getDay()
  for (let i = 0; i < startDayOfWeek; i++) {
    const d = new Date(year, month, -startDayOfWeek + 1 + i)
    days.push({
      day: d.getDate(),
      isCurrentMonth: false,
      dayOfWeek: d.getDay()
    })
  }

  // Current month days
  for (let i = 1; i <= lastDay.getDate(); i++) {
    const d = new Date(year, month, i)
    const dateStr = `${year}-${String(month + 1).padStart(2, '0')}-${String(i).padStart(2, '0')}`

    days.push({
      day: i,
      isCurrentMonth: true,
      dayOfWeek: d.getDay(),
      dateStr: dateStr,
      status: getDateScheduleText(i)
    })
  }

  // Next month days
  const remaining = 42 - days.length
  for (let i = 1; i <= remaining; i++) {
    const d = new Date(year, month + 1, i)
    days.push({
      day: i,
      isCurrentMonth: false,
      dayOfWeek: d.getDay()
    })
  }

  return days
})

// 1년치 스케줄 프리로드
const fetchYearlySchedules = async (year: number) => {
  if (yearlyCache.value.has(year)) {
    return yearlyCache.value.get(year) || []
  }

  try {
    const response = await fetch(`/api/web/schedules/yearly?year=${year}`, {
      headers: authStore.getAuthHeaders()
    })
    const data = await response.json()
    if (data.success) {
      const yearlySchedules = data.schedules || []
      yearlyCache.value.set(year, yearlySchedules)

      // 월별로 나누어 캐시에 저장
      const monthlyGroups = new Map<string, any[]>()
      yearlySchedules.forEach((schedule: any) => {
        const monthKey = schedule.date.substring(0, 7) // "YYYY-MM"
        if (!monthlyGroups.has(monthKey)) {
          monthlyGroups.set(monthKey, [])
        }
        monthlyGroups.get(monthKey)!.push(schedule)
      })

      // 월별 캐시 업데이트
      monthlyGroups.forEach((schedules, monthKey) => {
        scheduleCache.value.set(monthKey, schedules)
      })

      return yearlySchedules
    }
  } catch (error) {
    console.error('연간 스케줄 조회 오류:', error)
  }
  return []
}

// 빠른 월별 스케줄 로드 (캐시 우선)
const fetchSchedules = async () => {
  const monthKey = `${currentYear.value}-${currentMonth.value.toString().padStart(2, '0')}`

  // 1. 캐시에서 먼저 확인
  if (scheduleCache.value.has(monthKey)) {
    schedules.value = scheduleCache.value.get(monthKey) || []
    return
  }

  // 2. 이번 달 스케줄만 빠르게 가져오기 (즉시 표시)
  try {
    const response = await fetch(`/api/web/schedules?year=${currentYear.value}&month=${currentMonth.value}`, {
      headers: authStore.getAuthHeaders()
    })
    const data = await response.json()
    if (data.success) {
      schedules.value = data.schedules || []
      scheduleCache.value.set(monthKey, schedules.value)
    }
  } catch (error) {
    console.error('스케줄 조회 오류:', error)
  }

  // 3. 백그라운드에서 1년치 프리로드 (성능 향상)
  setTimeout(() => {
    fetchYearlySchedules(currentYear.value)
  }, 100)
}

const getDateSchedule = (date: number) => {
  const dateStr = `${currentYear.value}-${currentMonth.value.toString().padStart(2, '0')}-${date.toString().padStart(2, '0')}`
  return schedules.value.find(s => s.date === dateStr)
}



const getDateScheduleText = (date: number) => {
  const schedule = getDateSchedule(date)
  if (!schedule) {
    const dateObj = new Date(currentYear.value, currentMonth.value - 1, date)
    const isWeekend = dateObj.getDay() === 0 || dateObj.getDay() === 6
    return isWeekend ? '휴무' : '출근'
  }
  return schedule.is_workday ? '출근' : '휴무'
}

const handleDateClick = (dateInfo: any) => {
  if (!dateInfo.isCurrentMonth) return

  const dateStr = dateInfo.dateStr
  const status = getDateScheduleText(dateInfo.day)
  const isWorkday = status === '출근'

  selectedDateInfo.value = {
    date: `${currentYear.value}년 ${currentMonth.value}월 ${dateInfo.day}일`,
    dateStr: dateStr,
    status: status,
    isWorkday: isWorkday,
    day: dateInfo.day
  }

  showScheduleModal.value = true
}

const updateSchedule = async (type: 'work' | 'rest') => {
  const targetIsWorkday = type === 'work'

  // 현재 상태와 같으면 변경하지 않음 (선택은 했으니 모달은 닫음)
  if (selectedDateInfo.value.isWorkday === targetIsWorkday) {
    showScheduleModal.value = false
    return
  }

  // 상태가 다르면 토글 실행
  // API가 토글형식이라 현재 상태의 반대로 요청하면 원하는 상태가 됨
  await toggleDateSchedule(selectedDateInfo.value.day)
  showScheduleModal.value = false
}

const toggleDateSchedule = async (date: number) => {
  const dateStr = `${currentYear.value}-${currentMonth.value.toString().padStart(2, '0')}-${date.toString().padStart(2, '0')}`

  // 이미 토글 중이면 무시
  if (togglingDates.value.has(dateStr)) {
    return
  }

  // 토글 시작
  togglingDates.value.add(dateStr)

  try {
    // 1. 즉시 로컬 상태 업데이트 (낙관적 업데이트)
    const existingSchedule = schedules.value.find(s => s.date === dateStr)
    if (existingSchedule) {
      // 기존 스케줄이 있으면 토글
      existingSchedule.is_workday = !existingSchedule.is_workday
      existingSchedule.schedule_type = 'custom'
    } else {
      // 기존 스케줄이 없으면 새로 추가 (평일 기본값의 반대)
      const dateObj = new Date(currentYear.value, currentMonth.value - 1, date)
      const isWeekend = dateObj.getDay() === 0 || dateObj.getDay() === 6
      const newWorkday = isWeekend // 주말이면 출근으로, 평일이면 휴무로

      schedules.value.push({
        date: dateStr,
        is_workday: newWorkday,
        schedule_type: 'custom'
      })
    }

    // 2. 백그라운드에서 서버에 요청
    const response = await fetch('/api/web/schedules/toggle', {
      method: 'POST',
      headers: {
        ...authStore.getAuthHeaders(),
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ date: dateStr })
    })

    const data = await response.json()
    if (!data.success) {
      // 서버 요청 실패시 롤백
      console.error('서버 업데이트 실패, 롤백합니다')
      await fetchSchedules()
    }
  } catch (error) {
    console.error('스케줄 토글 오류:', error)
    // 네트워크 오류시 롤백
    await fetchSchedules()
  } finally {
    // 토글 완료
    togglingDates.value.delete(dateStr)
  }
}


onMounted(() => {
  // 초기 데이터 로드
  fetchServerStatus()
  fetchTodayStatus()
  fetchLogs()
  fetchUserStatus()
  fetchSchedules()

  // 30초마다 데이터 새로고침
  refreshInterval = setInterval(() => {
    fetchServerStatus()
    fetchTodayStatus()
    fetchLogs()
    fetchUserStatus()
  }, 30000)
})

onUnmounted(() => {
  if (refreshInterval) {
    clearInterval(refreshInterval)
  }
})
</script>
