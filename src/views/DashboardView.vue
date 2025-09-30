<template>
  <div class="min-h-screen bg-base-100">
    <!-- 헤더 -->
    <div class="navbar bg-base-100 shadow-lg border-b">
      <div class="flex-1">
        <div class="flex items-center gap-3">
          <div class="avatar placeholder">
            <div class="bg-primary/10 text-primary rounded-full w-10 flex items-center justify-center">
              <IconStar :size="20" />
            </div>
          </div>
          <div>
            <h1 class="text-xl font-bold text-base-content">출퇴근</h1>
            <p class="text-xs text-base-content/70">실시간 출퇴근 모니터링 시스템</p>
          </div>
        </div>
      </div>
      <div class="flex-none gap-2">
        <div class="dropdown dropdown-end">
          <div tabindex="0" role="button" class="btn btn-ghost btn-circle avatar placeholder">
            <div class="bg-base-300 text-base-content rounded-full w-8">
              <span class="text-xs">👤</span>
            </div>
          </div>
          <ul tabindex="0" class="mt-3 z-[1] p-2 shadow menu menu-sm dropdown-content bg-base-100 text-base-content rounded-box w-52 border">
            <li class="menu-title">
              <span class="text-base-content/70">{{ authStore.user?.username }}님</span>
            </li>
            <li><a @click="handleLogout" class="text-error">로그아웃</a></li>
          </ul>
        </div>
      </div>
    </div>

    <!-- 메인 컨테이너 -->
    <div class="container mx-auto p-6 max-w-7xl">
      <!-- 상태 카드 섹션 -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <!-- 서버 상태 -->
        <div class="stats shadow bg-base-200">
          <div class="stat">
            <div class="stat-figure text-primary">
              <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M2 5a2 2 0 012-2h12a2 2 0 012 2v2a2 2 0 01-2 2H4a2 2 0 01-2-2V5zm14 1a1 1 0 11-2 0 1 1 0 012 0zM2 13a2 2 0 012-2h12a2 2 0 012 2v2a2 2 0 01-2 2H4a2 2 0 01-2-2v-2zm14 1a1 1 0 11-2 0 1 1 0 012 0z"></path>
              </svg>
            </div>
            <div class="stat-title text-base-content/70">서버상태</div>
            <div class="stat-value text-lg">
              <div :class="['badge badge-lg', serverStatus.main ? 'badge-success' : 'badge-error']">
                {{ serverStatus.main ? '온라인' : '오프라인' }}
              </div>
            </div>
          </div>
        </div>

        <!-- 와치독 상태 -->
        <!-- <div class="stats shadow bg-base-200">
          <div class="stat">
            <div class="stat-figure text-secondary">
              <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M6.267 3.455a3.066 3.066 0 001.745-.723 3.066 3.066 0 013.976 0 3.066 3.066 0 001.745.723 3.066 3.066 0 012.812 2.812c.051.643.304 1.254.723 1.745a3.066 3.066 0 010 3.976 3.066 3.066 0 00-.723 1.745 3.066 3.066 0 01-2.812 2.812 3.066 3.066 0 00-1.745.723 3.066 3.066 0 01-3.976 0 3.066 3.066 0 00-1.745-.723 3.066 3.066 0 01-2.812-2.812 3.066 3.066 0 00-.723-1.745 3.066 3.066 0 010-3.976 3.066 3.066 0 00.723-1.745 3.066 3.066 0 012.812-2.812zm7.44 5.252a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"></path>
              </svg>
            </div>
            <div class="stat-title text-base-content/70">와치독</div>
            <div class="stat-value text-lg">
              <div :class="['badge badge-lg', serverStatus.watchdog ? 'badge-success' : 'badge-error']">
                {{ serverStatus.watchdog ? '활성' : '비활성' }}
              </div>
            </div>
          </div>
        </div> -->

        <!-- 오늘 출근 -->
        <div class="stats shadow bg-base-200">
          <div class="stat">
            <div class="stat-figure text-success">
              <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-12a1 1 0 10-2 0v4a1 1 0 00.293.707l2.828 2.829a1 1 0 101.415-1.415L11 9.586V6z"></path>
              </svg>
            </div>
            <div class="stat-title text-base-content/70">출근</div>
            <div class="stat-value text-lg">
              <div :class="['badge badge-lg', todayStatus.punchIn ? 'badge-success' : 'badge-warning']">
                {{ todayStatus.punchIn || '대기중' }}
              </div>
            </div>
          </div>
        </div>

        <!-- 오늘 퇴근 -->
        <div class="stats shadow bg-base-200">
          <div class="stat">
            <div class="stat-figure text-info">
              <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-12a1 1 0 10-2 0v4a1 1 0 00.293.707l2.828 2.829a1 1 0 101.415-1.415L11 9.586V6z"></path>
              </svg>
            </div>
            <div class="stat-title text-base-content/70">퇴근</div>
            <div class="stat-value text-lg">
              <div :class="['badge badge-lg', todayStatus.punchOut ? 'badge-success' : 'badge-warning']">
                {{ todayStatus.punchOut || '대기중' }}
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 상세 로그 섹션 -->
      <div class="grid grid-cols-1 gap-6">
        <!-- 상세 로그 테이블 -->
        <div class="card bg-base-200 shadow-xl">
          <div class="card-body">
            <h2 class="card-title text-primary">
              <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M3 4a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm0 4a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm0 4a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm0 4a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1z"></path>
              </svg>
              상세 로그
              <div class="badge badge-secondary badge-sm">{{ logs.length }}</div>
            </h2>
            <div class="divider my-2"></div>
            <div class="overflow-x-auto max-h-80 md:max-h-96 lg:max-h-[700px]">
              <table class="table table-zebra table-sm">
                <thead class="sticky top-0 bg-base-200">
                  <tr>
                    <th class="text-primary">시간</th>
                    <th class="text-primary">타입</th>
                    <th class="text-primary">상태</th>
                    <th class="text-primary">메시지</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-if="logs.length === 0">
                    <td colspan="4" class="text-center py-8 text-base-content/60">
                      로그가 없습니다
                    </td>
                  </tr>
                  <tr v-for="log in logs" :key="log.id" class="hover cursor-pointer" @click="showDetailModal(log)">
                    <td class="font-mono text-xs">{{ formatDateTime(log.timestamp) }}</td>
                    <td>
                      <div class="flex items-center gap-2">
                        <span class="text-sm">{{ log.action_type === 'punch_in' ? '📥' : '📤' }}</span>
                        <span class="font-medium text-base-content">{{ translateActionType(log.action_type) }}</span>
                      </div>
                    </td>
                    <td>
                      <div :class="['badge badge-sm', getBadgeVariant(log.status)]">
                        {{ translateStatus(log.status) }}
                      </div>
                    </td>
                    <td class="max-w-xs truncate" :title="translateMessage(log.message)">
                      {{ translateMessage(log.message) }}
                    </td>
                  </tr>
                </tbody>
              </table>
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
    <div v-if="selectedLog" class="modal modal-open">
      <div class="modal-box max-w-6xl max-h-[90vh]">
        <div class="flex items-center justify-between mb-6">
          <div class="flex items-center gap-3">
            <div :class="['badge badge-lg', getBadgeVariant(selectedLog.status)]">
              {{ translateStatus(selectedLog.status) }}
            </div>
            <h3 class="text-xl font-bold text-base-content">
              {{ translateActionType(selectedLog.action_type) }} 상세 로그
            </h3>
          </div>
          <button @click="selectedLog = null" class="btn btn-sm btn-circle btn-ghost">
            ✕
          </button>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
          <!-- 기본 정보 사이드바 -->
          <div class="lg:col-span-1 space-y-4">
            <!-- 요약 정보 -->
            <div class="card bg-gradient-to-br from-primary/10 to-secondary/10 shadow-lg">
              <div class="card-body p-4">
                <h4 class="font-bold text-base-content mb-3 flex items-center gap-2">
                  📊 실행 요약
                </h4>
                <div class="space-y-3 text-sm">
                  <div class="flex justify-between">
                    <span class="font-medium text-base-content/70">사용자:</span>
                    <span class="font-mono text-primary">{{ selectedLog.user_id }}</span>
                  </div>
                  <div class="flex justify-between">
                    <span class="font-medium text-base-content/70">시작 시간:</span>
                    <span class="font-mono">{{ formatTime(selectedLog.timestamp) }}</span>
                  </div>
                  <div class="flex justify-between" v-if="detailLogs.length > 0">
                    <span class="font-medium text-base-content/70">완료 시간:</span>
                    <span class="font-mono">{{ formatTime(getLastStageTime()) }}</span>
                  </div>
                  <div class="flex justify-between" v-if="detailLogs.length > 0">
                    <span class="font-medium text-base-content/70">총 소요시간:</span>
                    <span class="font-mono text-secondary">{{ calculateDuration() }}</span>
                  </div>
                  <div class="flex justify-between">
                    <span class="font-medium text-base-content/70">단계 수:</span>
                    <span class="font-mono text-accent">{{ detailLogs.length }}단계</span>
                  </div>
                </div>
              </div>
            </div>

            <!-- 메시지 -->
            <div class="card bg-base-100 shadow" v-if="selectedLog.message">
              <div class="card-body p-4">
                <h4 class="font-bold text-base-content mb-3 flex items-center gap-2">
                  💬 결과 메시지
                </h4>
                <div :class="['alert', getMessageAlertClass(selectedLog.status)]">
                  <span class="text-sm">{{ translateMessage(selectedLog.message) }}</span>
                </div>
              </div>
            </div>

            <!-- 진행률 표시 -->
            <div class="card bg-base-100 shadow" v-if="detailLogs.length > 0">
              <div class="card-body p-4">
                <h4 class="font-bold text-base-content mb-3 flex items-center gap-2">
                  📈 진행률
                </h4>
                <div class="space-y-2">
                  <div class="flex justify-between text-sm">
                    <span>완료된 단계</span>
                    <span class="font-mono">{{ detailLogs.length }}/{{ getExpectedSteps() }}</span>
                  </div>
                  <progress
                    class="progress progress-primary w-full"
                    :value="detailLogs.length"
                    :max="getExpectedSteps()">
                  </progress>
                  <div class="text-xs text-base-content/60 text-center">
                    {{ Math.round((detailLogs.length / getExpectedSteps()) * 100) }}% 완료
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- 메인 타임라인 -->
          <div class="lg:col-span-2">
            <div class="card bg-base-100 shadow-lg">
              <div class="card-body p-6">
                <h4 class="font-bold text-base-content mb-4 flex items-center gap-2">
                  🔄 단계별 실행 로그
                  <div class="badge badge-neutral badge-sm">{{ detailLogs.length }}단계</div>
                </h4>

                <!-- 로딩 상태 -->
                <div v-if="isLoadingHeartbeat" class="text-center py-8">
                  <div class="loading loading-spinner loading-lg text-primary"></div>
                  <p class="text-base-content/60 mt-4">하트비트 로그를 불러오는 중...</p>
                  <p class="text-xs text-base-content/40 mt-2">로그 ID: {{ selectedLog?.id }}</p>
                </div>

                <!-- 데이터 없음 -->
                <div v-else-if="!isLoadingHeartbeat && detailLogs.length === 0" class="text-center py-8">
                  <div class="text-warning text-4xl mb-4">⚠️</div>
                  <p class="text-base-content/60">이 로그에 대한 하트비트 데이터가 없습니다.</p>
                  <p class="text-xs text-base-content/40 mt-2">로그 ID: {{ selectedLog?.id }}</p>
                </div>

                <!-- 타임라인 -->
                <div v-else class="overflow-y-auto max-h-[500px] pr-2">
                  <div class="space-y-3">
                    <div v-for="(detail, index) in detailLogs" :key="index"
                         class="flex items-start gap-4 p-3 rounded-lg hover:bg-base-200/50 transition-colors">
                      <!-- 단계 번호와 아이콘 -->
                      <div class="flex flex-col items-center">
                        <div :class="['w-8 h-8 rounded-full flex items-center justify-center text-xs font-bold text-white', getStageColor(detail.stage)]">
                          {{ index + 1 }}
                        </div>
                        <div v-if="index < detailLogs.length - 1" class="w-0.5 h-8 bg-base-300 mt-2"></div>
                      </div>

                      <!-- 내용 -->
                      <div class="flex-1 min-w-0">
                        <div class="flex items-center justify-between mb-1">
                          <h5 class="font-semibold text-base-content">{{ translateStage(detail.stage) }}</h5>
                          <span class="text-xs font-mono text-base-content/60">{{ formatTime(detail.timestamp) }}</span>
                        </div>
                        <div class="text-sm text-base-content/70 mb-2">{{ getStageDescription(detail.stage) }}</div>
                        <div class="flex items-center gap-2 text-xs">
                          <div class="badge badge-outline badge-xs">{{ detail.stage }}</div>
                          <div class="badge badge-ghost badge-xs">PID: {{ detail.pid }}</div>
                        </div>
                      </div>

                      <!-- 소요 시간 -->
                      <div class="text-right">
                        <div class="text-xs text-base-content/60">
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
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import IconStar from '@/components/icons/IconStar.vue'

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
const selectedLog = ref<any>(null)
const detailLogs = ref<any[]>([])
const isLoadingHeartbeat = ref(false)

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

const translateMessage = (message: string) => {
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
  return isNaN(date.getTime()) ? '-' : date.toLocaleTimeString('ko-KR')
}

const formatDateTime = (timestamp: string) => {
  if (!timestamp) return '-'
  const date = new Date(timestamp)
  return isNaN(date.getTime()) ? '-' : date.toLocaleString('ko-KR')
}

const showDetailModal = async (log: any) => {
  selectedLog.value = log
  detailLogs.value = [] // 이전 데이터 클리어
  isLoadingHeartbeat.value = true
  await fetchDetailLogs(log.id)
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
  // 완료 단계
  if (stage.includes('complete') || stage.includes('success') || stage.includes('clicked_success')) return 'bg-success'
  // 오류/실패 단계
  if (stage.includes('failed') || stage.includes('error') || stage.includes('오류')) return 'bg-error'
  // 시작 단계
  if (stage.includes('start') || stage.includes('init')) return 'bg-primary'
  // 진행중 단계
  if (stage.includes('wait') || stage.includes('load') || stage.includes('fill')) return 'bg-warning'
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
      return 'alert-success'
    case 'error':
    case 'failed':
      return 'alert-error'
    case 'already_done':
      return 'alert-info'
    default:
      return 'alert-warning'
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
  // 일반적인 성공 시나리오의 예상 단계 수
  return selectedLog.value?.status === 'success' ? 25 : 30
}

onMounted(() => {
  // 초기 데이터 로드
  fetchServerStatus()
  fetchTodayStatus()
  fetchLogs()

  // 30초마다 데이터 새로고침
  refreshInterval = setInterval(() => {
    fetchServerStatus()
    fetchTodayStatus()
    fetchLogs()
  }, 30000)
})

onUnmounted(() => {
  if (refreshInterval) {
    clearInterval(refreshInterval)
  }
})
</script>