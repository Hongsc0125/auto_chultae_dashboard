<template>
  <div class="min-h-screen bg-base-100">
    <!-- 헤더 -->
    <div class="navbar bg-base-100 shadow-lg border-b">
      <div class="flex-1">
        <div class="flex items-center gap-3">
          <div class="avatar placeholder">
            <div class="bg-primary/10 text-primary rounded-full w-10">
              <span class="text-sm">🏢</span>
            </div>
          </div>
          <div>
            <h1 class="text-xl font-bold text-base-content">출근 대시보드</h1>
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
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        <!-- 서버 상태 -->
        <div class="stats shadow bg-base-200">
          <div class="stat">
            <div class="stat-figure text-primary">
              <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M2 5a2 2 0 012-2h12a2 2 0 012 2v2a2 2 0 01-2 2H4a2 2 0 01-2-2V5zm14 1a1 1 0 11-2 0 1 1 0 012 0zM2 13a2 2 0 012-2h12a2 2 0 012 2v2a2 2 0 01-2 2H4a2 2 0 01-2-2v-2zm14 1a1 1 0 11-2 0 1 1 0 012 0z"></path>
              </svg>
            </div>
            <div class="stat-title text-base-content/70">메인 서버</div>
            <div class="stat-value text-lg">
              <div :class="['badge badge-lg', serverStatus.main ? 'badge-success' : 'badge-error']">
                {{ serverStatus.main ? '온라인' : '오프라인' }}
              </div>
            </div>
          </div>
        </div>

        <!-- 와치독 상태 -->
        <div class="stats shadow bg-base-200">
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
        </div>

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
      <div class="modal-box max-w-4xl">
        <div class="flex items-center justify-between mb-6">
          <h3 class="text-xl font-bold text-base-content">상세 로그</h3>
          <button @click="selectedLog = null" class="btn btn-sm btn-circle btn-ghost">
            ✕
          </button>
        </div>

        <div class="space-y-4">
          <!-- 기본 정보 -->
          <div class="card bg-base-100 shadow">
            <div class="card-body p-4">
              <h4 class="font-bold text-base-content mb-3">기본 정보</h4>
              <div class="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
                <div>
                  <span class="font-medium text-base-content/70">시간:</span>
                  <span class="text-base-content ml-2">{{ formatDateTime(selectedLog.timestamp) }}</span>
                </div>
                <div>
                  <span class="font-medium text-base-content/70">타입:</span>
                  <span class="text-base-content ml-2">{{ translateActionType(selectedLog.action_type) }}</span>
                </div>
                <div>
                  <span class="font-medium text-base-content/70">상태:</span>
                  <div :class="['badge badge-sm ml-2', getBadgeVariant(selectedLog.status)]">
                    {{ translateStatus(selectedLog.status) }}
                  </div>
                </div>
                <div>
                  <span class="font-medium text-base-content/70">사용자:</span>
                  <span class="text-base-content ml-2">{{ selectedLog.user_id }}</span>
                </div>
              </div>
            </div>
          </div>

          <!-- 상세 로그 정보 -->
          <div class="card bg-base-100 shadow" v-if="detailLogs.length > 0">
            <div class="card-body p-4">
              <h4 class="font-bold text-base-content mb-3">단계별 실행 로그</h4>
              <div class="timeline timeline-vertical">
                <div v-for="(detail, index) in detailLogs" :key="index" class="timeline-item">
                  <div class="timeline-start text-xs text-base-content/60">
                    {{ formatTime(detail.timestamp) }}
                  </div>
                  <div class="timeline-middle">
                    <div :class="['w-3 h-3 rounded-full', getStageColor(detail.stage)]"></div>
                  </div>
                  <div class="timeline-end">
                    <div class="font-medium text-base-content">{{ detail.stage }}</div>
                    <div class="text-xs text-base-content/70">{{ detail.action_type }}</div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- 에러 메시지 -->
          <div class="card bg-base-100 shadow" v-if="selectedLog.message">
            <div class="card-body p-4">
              <h4 class="font-bold text-base-content mb-3">메시지</h4>
              <div class="bg-base-200 p-3 rounded text-sm text-base-content">
                {{ translateMessage(selectedLog.message) }}
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

let refreshInterval: NodeJS.Timeout | null = null

const handleLogout = () => {
  authStore.logout()
  router.push('/login')
}

const fetchServerStatus = async () => {
  try {
    const response = await fetch('http://localhost:9000/api/web/server-status', {
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
    const response = await fetch('http://localhost:9000/api/web/today-status', {
      headers: authStore.getAuthHeaders()
    })
    const data = await response.json()
    if (data.success) {
      todayStatus.value = data.status
    }
  } catch (error) {
    console.error('Today status fetch error:', error)
  }
}

const fetchLogs = async () => {
  try {
    const response = await fetch('http://localhost:9000/api/web/logs?limit=50', {
      headers: authStore.getAuthHeaders()
    })
    const data = await response.json()
    if (data.success) {
      logs.value = data.logs
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
  await fetchDetailLogs(log.id)
}

const fetchDetailLogs = async (logId: number) => {
  try {
    // attendance_log_id를 기반으로 하트비트 조회
    const response = await fetch(`http://localhost:9000/api/web/heartbeats?log_id=${logId}`, {
      headers: authStore.getAuthHeaders()
    })
    const data = await response.json()
    if (data.success) {
      detailLogs.value = data.heartbeats
    }
  } catch (error) {
    console.error('Detail logs fetch error:', error)
    detailLogs.value = []
  }
}

const getStageColor = (stage: string) => {
  if (stage.includes('성공') || stage.includes('완료')) return 'bg-success'
  if (stage.includes('실패') || stage.includes('오류')) return 'bg-error'
  if (stage.includes('시작') || stage.includes('대기')) return 'bg-warning'
  return 'bg-info'
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