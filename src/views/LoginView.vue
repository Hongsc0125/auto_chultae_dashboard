<template>
  <div class="min-h-screen bg-base-200 flex items-center justify-center p-4 relative overflow-hidden">
    <!-- 배경 장식 -->
    <div class="absolute inset-0 w-full h-full bg-base-300">
      <div class="absolute top-0 -left-4 w-72 h-72 bg-primary/20 rounded-full mix-blend-multiply filter blur-xl opacity-70 animate-blob"></div>
      <div class="absolute top-0 -right-4 w-72 h-72 bg-secondary/20 rounded-full mix-blend-multiply filter blur-xl opacity-70 animate-blob animation-delay-2000"></div>
      <div class="absolute -bottom-8 left-20 w-72 h-72 bg-accent/20 rounded-full mix-blend-multiply filter blur-xl opacity-70 animate-blob animation-delay-4000"></div>
    </div>

    <div class="w-full max-w-md relative z-10">
      <!-- 헤더 섹션 -->
      <div class="text-center mb-8">
        <div class="inline-flex items-center justify-center w-20 h-20 rounded-2xl bg-base-100/50 backdrop-blur-md shadow-xl mb-6 ring-1 ring-white/10">
          <IconStar :size="40" class="text-primary drop-shadow-md" />
        </div>
        <h1 class="text-3xl font-bold bg-clip-text text-transparent bg-gradient-to-r from-primary to-secondary mb-2">
          귀찮은 출퇴근
        </h1>
        <p class="text-base-content/60 font-medium">더 이상 수동으로 찍지 마세요</p>
      </div>

      <!-- 로그인 카드 -->
      <div class="card bg-base-100/70 backdrop-blur-lg shadow-2xl border border-white/10">
        <div class="card-body p-8">
          <h2 class="text-xl font-bold text-center mb-6">로그인</h2>

          <form @submit.prevent="handleLogin" class="space-y-5">
            <div class="form-control">
              <label class="label">
                <span class="label-text font-semibold">아이디</span>
              </label>
              <div class="relative">
                <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <svg class="w-5 h-5 text-base-content/40" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                  </svg>
                </div>
                <input
                  type="text"
                  v-model="loginForm.username"
                  placeholder="아이디를 입력하세요"
                  class="input input-bordered w-full pl-10 bg-base-200/50 focus:bg-base-100 transition-colors"
                  :class="{ 'input-error': error && !loginForm.username }"
                  required
                />
              </div>
            </div>

            <div class="form-control">
              <label class="label">
                <span class="label-text font-semibold">비밀번호</span>
              </label>
              <div class="relative">
                <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <svg class="w-5 h-5 text-base-content/40" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                  </svg>
                </div>
                <input
                  type="password"
                  v-model="loginForm.password"
                  placeholder="비밀번호를 입력하세요"
                  class="input input-bordered w-full pl-10 bg-base-200/50 focus:bg-base-100 transition-colors"
                  :class="{ 'input-error': error && !loginForm.password }"
                  required
                />
              </div>
            </div>

            <div v-if="error" class="alert alert-error text-sm py-2 shadow-lg animate-shake">
              <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-5 w-5" fill="none" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
              <span>{{ error }}</span>
            </div>

            <button
              type="submit"
              class="btn btn-primary w-full shadow-lg hover:shadow-primary/30 transition-all duration-300"
              :disabled="loading"
            >
              <span v-if="loading" class="loading loading-spinner loading-sm"></span>
              {{ loading ? '로그인 중...' : '로그인' }}
            </button>
          </form>

          <div class="divider my-6 text-xs text-base-content/40">처음이신가요?</div>

          <button
            @click="showRegister = true"
            class="btn btn-outline btn-block hover:bg-base-content hover:text-base-100 transition-colors"
          >
            회원가입
          </button>
        </div>
      </div>

      <p class="text-center mt-8 text-xs text-base-content/40 font-medium">
        © 2026 Auto Chultae. All rights reserved.
      </p>
    </div>

    <!-- 회원가입 모달 -->
    <dialog class="modal modal-bottom sm:modal-middle" :class="{ 'modal-open': showRegister }">
      <div class="modal-box bg-base-100/90 backdrop-blur border border-white/10">
        <h3 class="font-bold text-lg mb-6 flex items-center gap-2">
          <IconStar :size="24" class="text-secondary" />
          회원가입
        </h3>

        <form @submit.prevent="handleRegister" class="space-y-4">
           <!-- 사용자 ID -->
           <div class="form-control">
            <label class="label">
              <span class="label-text">아이디</span>
            </label>
            <input
              v-model="registerForm.username"
              type="text"
              placeholder="아이디"
              class="input input-bordered w-full"
              :class="{ 'input-error': registerError && !registerForm.username }"
              required
            />
          </div>

          <!-- 비밀번호 -->
          <div class="form-control">
            <label class="label">
              <span class="label-text">비밀번호</span>
            </label>
            <input
              v-model="registerForm.password"
              type="password"
              placeholder="비밀번호"
              class="input input-bordered w-full"
              :class="{ 'input-error': registerError && !registerForm.password }"
              required
            />
          </div>

          <!-- 이메일 -->
          <div class="form-control">
            <label class="label">
              <span class="label-text">이메일</span>
            </label>
            <input
              v-model="registerForm.email"
              type="email"
              placeholder="이메일 (선택사항)"
              class="input input-bordered w-full"
            />
          </div>

          <!-- 에러 메시지 -->
          <div v-if="registerError" class="alert alert-error text-sm py-2">
            <span>{{ registerError }}</span>
          </div>

          <!-- 약관 동의 -->
          <div class="form-control mt-4">
            <label class="label cursor-pointer justify-start gap-3 p-0">
              <input type="checkbox" v-model="termsAgreed" class="checkbox checkbox-primary checkbox-sm" />
              <span class="label-text text-sm">서비스 이용약관 및 자동화 정책에 동의합니다.</span>
            </label>
            <p class="text-xs text-base-content/60 mt-2 ml-8">
              ※ 본 서비스는 사용자의 계정 정보를 이용하여 출퇴근을 자동화합니다.
            </p>
          </div>

          <div class="modal-action">
            <button type="button" class="btn btn-ghost" @click="showRegister = false">취소</button>
            <button
              type="submit"
              class="btn btn-primary"
              :disabled="registerLoading || !termsAgreed"
            >
              <span v-if="registerLoading" class="loading loading-spinner"></span>
              가입하기
            </button>
          </div>
        </form>
      </div>
      <form method="dialog" class="modal-backdrop">
        <button @click="showRegister = false">close</button>
      </form>
    </dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import IconStar from '@/components/icons/IconStar.vue' // 아이콘 컴포넌트 경로 확인 필요

const router = useRouter()
const authStore = useAuthStore()

const loading = ref(false)
const error = ref('')
const showRegister = ref(false)
const registerLoading = ref(false)
const registerError = ref('')
const termsAgreed = ref(false)

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
  if (!termsAgreed.value) {
    registerError.value = '약관에 동의해주세요.'
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
      // 자동 로그인 시도
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
.animate-blob {
  animation: blob 7s infinite;
}
.animation-delay-2000 {
  animation-delay: 2s;
}
.animation-delay-4000 {
  animation-delay: 4s;
}
@keyframes blob {
  0% { transform: translate(0px, 0px) scale(1); }
  33% { transform: translate(30px, -50px) scale(1.1); }
  66% { transform: translate(-20px, 20px) scale(0.9); }
  100% { transform: translate(0px, 0px) scale(1); }
}

@keyframes shake {
  0%, 100% { transform: translateX(0); }
  10%, 30%, 50%, 70%, 90% { transform: translateX(-5px); }
  20%, 40%, 60%, 80% { transform: translateX(5px); }
}
.animate-shake {
  animation: shake 0.5s cubic-bezier(.36,.07,.19,.97) both;
}
</style>
