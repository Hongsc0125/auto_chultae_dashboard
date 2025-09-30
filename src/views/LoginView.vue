<template>
  <div class="min-h-screen bg-base-200 flex items-center justify-center p-4">
    <div class="w-full max-w-md">
      <!-- 로고 & 제목 -->
      <div class="text-center mb-8">
        <div class="avatar mb-4">
          <div class="w-16 rounded-full bg-primary/10">
            <div class="flex items-center justify-center h-full">
              <IconStar :size="32" />
            </div>
          </div>
        </div>
        <h1 class="text-3xl font-bold text-base-content mb-2">출퇴근 너무 귀찮아</h1>
        <p class="text-base-content/70">스마트 출퇴근 관리 시스템</p>
      </div>

      <!-- 로그인 카드 -->
      <div class="card bg-base-100 shadow-lg">
        <div class="card-body p-6">
          <h2 class="card-title text-xl font-bold text-center justify-center mb-6 text-base-content">
            로그인 (회사 아이디/비밀번호)
          </h2>

          <form @submit.prevent="handleLogin" class="space-y-4">
            <!-- 사용자 ID -->
            <div class="form-control">
              <label class="label">
                <span class="label-text font-medium flex items-center gap-2">
                  <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z"></path>
                  </svg>
                  사용자 ID
                </span>
              </label>
              <input
                id="username"
                v-model="loginForm.username"
                type="text"
                required
                placeholder="사용자 ID를 입력하세요"
                class="input input-bordered w-full focus:input-primary"
                :class="{ 'input-error': error && !loginForm.username }"
              />
            </div>

            <!-- 비밀번호 -->
            <div class="form-control">
              <label class="label">
                <span class="label-text font-medium flex items-center gap-2">
                  <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M5 9V7a5 5 0 0110 0v2a2 2 0 012 2v5a2 2 0 01-2 2H5a2 2 0 01-2-2v-5a2 2 0 012-2zm8-2v2H7V7a3 3 0 016 0z"></path>
                  </svg>
                  비밀번호
                </span>
              </label>
              <input
                id="password"
                v-model="loginForm.password"
                type="password"
                required
                placeholder="비밀번호를 입력하세요"
                class="input input-bordered w-full focus:input-primary"
                :class="{ 'input-error': error && !loginForm.password }"
              />
            </div>

            <!-- 에러 메시지 -->
            <div v-if="error" class="alert alert-error">
              <svg class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
              </svg>
              <span>{{ error }}</span>
            </div>

            <!-- 로그인 버튼 -->
            <button
              type="submit"
              :disabled="loading"
              class="btn btn-primary w-full"
            >
              <span v-if="loading" class="loading loading-spinner loading-sm"></span>
              {{ loading ? '로그인 중...' : '로그인' }}
            </button>
          </form>

          <!-- 구분선 -->
          <div class="divider">또는</div>

          <!-- 회원가입 링크 -->
          <div class="text-center">
            <p class="text-base-content/70 mb-4">
              신청한적 없다면?
            </p>
            <button
              @click="showRegister = true"
              class="btn btn-outline"
            >
              <svg class="w-4 h-4 mr-2" fill="currentColor" viewBox="0 0 20 20">
                <path d="M8 9a3 3 0 100-6 3 3 0 000 6zM8 11a6 6 0 016 6H2a6 6 0 016-6zM16 7a1 1 0 10-2 0v1h-1a1 1 0 100 2h1v1a1 1 0 102 0v-1h1a1 1 0 100-2h-1V7z"></path>
              </svg>
              출퇴근 자동화 신청
            </button>
          </div>
        </div>
      </div>

      <!-- 푸터 정보 -->
      <div class="text-center mt-8 text-base-content/60">
        <p class="text-sm text-base-content/60">© 2025 출퇴근 자동화 power by 홍성철 프로</p>
      </div>
    </div>

    <!-- 회원가입 모달 -->
    <div v-if="showRegister" class="modal modal-open">
      <div class="modal-box relative max-w-md">
        <!-- 모달 헤더 -->
        <div class="flex items-center justify-between mb-6">
          <h3 class="text-xl font-bold text-base-content">회원가입</h3>
          <button
            @click="showRegister = false"
            class="btn btn-sm btn-circle btn-ghost"
          >
            ✕
          </button>
        </div>

        <form @submit.prevent="handleRegister" class="space-y-4">
          <!-- 사용자 ID -->
          <div class="form-control">
            <label class="label">
              <span class="label-text font-medium flex items-center gap-2">
                <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z"></path>
                </svg>
                사용자 ID
              </span>
            </label>
            <input
              id="reg-username"
              v-model="registerForm.username"
              type="text"
              required
              placeholder="사용자 ID를 입력하세요"
              class="input input-bordered w-full focus:input-primary"
              :class="{ 'input-error': registerError && !registerForm.username }"
            />
          </div>

          <!-- 비밀번호 -->
          <div class="form-control">
            <label class="label">
              <span class="label-text font-medium flex items-center gap-2">
                <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M5 9V7a5 5 0 0110 0v2a2 2 0 012 2v5a2 2 0 01-2 2H5a2 2 0 01-2-2v-5a2 2 0 012-2zm8-2v2H7V7a3 3 0 016 0z"></path>
                </svg>
                비밀번호
              </span>
            </label>
            <input
              id="reg-password"
              v-model="registerForm.password"
              type="password"
              required
              placeholder="비밀번호를 입력하세요"
              class="input input-bordered w-full focus:input-primary"
              :class="{ 'input-error': registerError && !registerForm.password }"
            />
          </div>

          <!-- 이메일 -->
          <div class="form-control">
            <label class="label">
              <span class="label-text font-medium flex items-center gap-2">
                <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                  <path d="M2.003 5.884L10 9.882l7.997-3.998A2 2 0 0016 4H4a2 2 0 00-1.997 1.884z"></path>
                  <path d="M18 8.118l-8 4-8-4V14a2 2 0 002 2h12a2 2 0 002-2V8.118z"></path>
                </svg>
                이메일
              </span>
            </label>
            <input
              id="reg-email"
              v-model="registerForm.email"
              type="email"
              required
              placeholder="이메일을 입력하세요"
              class="input input-bordered w-full focus:input-primary"
              :class="{ 'input-error': registerError && !registerForm.email }"
            />
          </div>

          <!-- 에러 메시지 -->
          <div v-if="registerError" class="alert alert-error">
            <svg class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
            </svg>
            <span>{{ registerError }}</span>
          </div>

          <!-- 확인사항 -->
          <div class="alert alert-info mb-4">
            <svg class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
            </svg>
            <div class="text-sm">
              <div class="font-medium mb-1">🔒 확인사항</div>
              <div>입력된 회사 계정 정보는 자동화 서비스 제공을 위해<br>시스템 관리자에게 공유됩니다.</div>
            </div>
          </div>

          <!-- 이용약관 동의 -->
          <div class="space-y-3">
            <div class="form-control">
              <label class="label cursor-pointer justify-start gap-3">
                <input
                  type="checkbox"
                  class="checkbox checkbox-primary"
                  v-model="termsAgreed"
                />
                <span class="text-sm">
                  <span class="font-medium">서비스 이용약관</span>에 동의합니다.
                </span>
              </label>
            </div>

            <div class="form-control">
              <label class="label cursor-pointer justify-start gap-3">
                <input
                  type="checkbox"
                  class="checkbox checkbox-primary"
                  v-model="privacyAgreed"
                />
                <span class="text-sm">
                  <span class="font-medium">개인정보 처리방침</span>에 동의합니다.
                </span>
              </label>
            </div>

            <div class="form-control">
              <label class="label cursor-pointer justify-start gap-3">
                <input
                  type="checkbox"
                  class="checkbox checkbox-primary"
                  v-model="automationAgreed"
                />
                <span class="text-sm">
                  출퇴근 <span class="font-medium">자동화 서비스 이용</span>에 동의합니다.
                </span>
              </label>
            </div>

            <div class="bg-warning/10 p-3 rounded-lg border border-warning/20">
              <div class="text-xs text-warning-content">
                ⚠️ 자동화 서비스는 회사 계정 정보를 이용하여 자동으로 출퇴근 처리를 수행합니다.
                계정 정보는 암호화되어 안전하게 저장되며, 서비스 목적 외에는 사용되지 않습니다.
              </div>
            </div>
          </div>

          <!-- 회원가입 버튼 -->
          <button
            type="submit"
            :disabled="registerLoading || !allAgreed"
            class="btn btn-primary w-full"
            :class="{ 'btn-disabled': !allAgreed }"
          >
            <span v-if="registerLoading" class="loading loading-spinner loading-sm"></span>
            {{ registerLoading ? '가입 중...' : allAgreed ? '회원가입' : '모든 약관에 동의해주세요' }}
          </button>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import IconStar from '@/components/icons/IconStar.vue'

const router = useRouter()
const authStore = useAuthStore()

const loading = ref(false)
const error = ref('')
const showRegister = ref(false)
const registerLoading = ref(false)
const registerError = ref('')

// 약관 동의 체크박스
const termsAgreed = ref(false)
const privacyAgreed = ref(false)
const automationAgreed = ref(false)

// 모든 약관 동의 여부 계산
const allAgreed = computed(() => {
  return termsAgreed.value && privacyAgreed.value && automationAgreed.value
})

const loginForm = reactive({
  username: '',
  password: ''
})

const registerForm = reactive({
  username: '',
  password: '',
  email: ''
})

const handleLogin = async () => {
  loading.value = true
  error.value = ''

  try {
    const success = await authStore.login(loginForm.username, loginForm.password)
    if (success) {
      router.push('/dashboard')
    }
  } catch (err: any) {
    error.value = err.message || '로그인에 실패했습니다.'
  } finally {
    loading.value = false
  }
}

const handleRegister = async () => {
  // 약관 동의 체크
  if (!allAgreed.value) {
    registerError.value = '모든 약관에 동의해야 회원가입이 가능합니다.'
    return
  }

  registerLoading.value = true
  registerError.value = ''

  try {
    const success = await authStore.register(
      registerForm.username,
      registerForm.password,
      registerForm.email
    )
    if (success) {
      showRegister.value = false
      // 동의 상태 초기화
      termsAgreed.value = false
      privacyAgreed.value = false
      automationAgreed.value = false
      // 자동 로그인
      loginForm.username = registerForm.username
      loginForm.password = registerForm.password
      await handleLogin()
    }
  } catch (err: any) {
    registerError.value = err.message || '회원가입에 실패했습니다.'
  } finally {
    registerLoading.value = false
  }
}
</script>

<style scoped>
.bg-grid-white\/10 {
  background-image: url("data:image/svg+xml,%3csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3e%3cg fill='none' fill-rule='evenodd'%3e%3cg fill='%23ffffff' fill-opacity='0.1'%3e%3cpath d='M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z'/%3e%3c/g%3e%3c/g%3e%3c/svg%3e");
}
</style>