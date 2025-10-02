import { defineStore } from 'pinia'
import { ref, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'

interface User {
  id: string
  username: string
  email: string
}

export const useAuthStore = defineStore('auth', () => {
  const user = ref<User | null>(null)
  const token = ref<string | null>(null)
  const isAuthenticated = ref(false)

  // 자동 로그아웃 관련 변수
  let inactivityTimer: NodeJS.Timeout | null = null
  let tokenExpiryTimer: NodeJS.Timeout | null = null
  const INACTIVITY_TIMEOUT = 30 * 60 * 1000 // 30분 비활성
  const TOKEN_EXPIRY_TIME = 8 * 60 * 60 * 1000 // 8시간 토큰 만료

  // 자동 로그아웃 실행
  const performAutoLogout = (reason: string) => {
    console.log(`자동 로그아웃: ${reason}`)
    logout()
    // 현재 페이지가 로그인 페이지가 아닌 경우에만 리다이렉트
    if (window.location.pathname !== '/login') {
      window.location.href = '/login'
    }
  }

  // 비활성 타이머 초기화
  const resetInactivityTimer = () => {
    if (inactivityTimer) {
      clearTimeout(inactivityTimer)
    }

    if (isAuthenticated.value) {
      inactivityTimer = setTimeout(() => {
        performAutoLogout('30분 비활성으로 인한 자동 로그아웃')
      }, INACTIVITY_TIMEOUT)
    }
  }

  // 토큰 만료 타이머 설정
  const setTokenExpiryTimer = () => {
    if (tokenExpiryTimer) {
      clearTimeout(tokenExpiryTimer)
    }

    tokenExpiryTimer = setTimeout(() => {
      performAutoLogout('토큰 만료로 인한 자동 로그아웃')
    }, TOKEN_EXPIRY_TIME)
  }

  // 활동 감지 이벤트 등록
  const setupActivityListeners = () => {
    const events = ['mousedown', 'mousemove', 'keypress', 'scroll', 'touchstart', 'click']

    const resetTimer = () => {
      if (isAuthenticated.value) {
        resetInactivityTimer()
      }
    }

    events.forEach(event => {
      document.addEventListener(event, resetTimer, true)
    })

    // 컴포넌트 언마운트 시 이벤트 리스너 제거
    const cleanup = () => {
      events.forEach(event => {
        document.removeEventListener(event, resetTimer, true)
      })
      if (inactivityTimer) clearTimeout(inactivityTimer)
      if (tokenExpiryTimer) clearTimeout(tokenExpiryTimer)
    }

    return cleanup
  }

  // 토큰을 localStorage에서 초기화
  const initAuth = () => {
    const savedToken = localStorage.getItem('auth_token')
    const savedUser = localStorage.getItem('auth_user')
    const savedLoginTime = localStorage.getItem('auth_login_time')

    if (savedToken && savedUser && savedLoginTime) {
      const loginTime = parseInt(savedLoginTime)
      const now = Date.now()
      const elapsed = now - loginTime

      // 토큰이 만료되었는지 확인
      if (elapsed >= TOKEN_EXPIRY_TIME) {
        performAutoLogout('토큰 만료로 인한 자동 로그아웃')
        return
      }

      token.value = savedToken
      user.value = JSON.parse(savedUser)
      isAuthenticated.value = true

      // 남은 시간만큼 토큰 만료 타이머 설정
      const remainingTime = TOKEN_EXPIRY_TIME - elapsed
      if (tokenExpiryTimer) clearTimeout(tokenExpiryTimer)
      tokenExpiryTimer = setTimeout(() => {
        performAutoLogout('토큰 만료로 인한 자동 로그아웃')
      }, remainingTime)

      // 활동 감지 시작
      setupActivityListeners()
      resetInactivityTimer()
    }
  }

  const login = async (username: string, password: string): Promise<boolean> => {
    try {
      const response = await fetch('/api/web/auth/login', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ user_id: username, password }),
      })

      const data = await response.json()

      if (response.ok && data.success) {
        token.value = data.access_token
        user.value = data.user
        isAuthenticated.value = true

        // localStorage에 저장 (로그인 시간 포함)
        const loginTime = Date.now().toString()
        localStorage.setItem('auth_token', data.access_token)
        localStorage.setItem('auth_user', JSON.stringify(data.user))
        localStorage.setItem('auth_login_time', loginTime)

        // 자동 로그아웃 타이머 설정
        setTokenExpiryTimer()
        setupActivityListeners()
        resetInactivityTimer()

        return true
      } else {
        throw new Error(data.message || '로그인에 실패했습니다.')
      }
    } catch (error) {
      console.error('Login error:', error)
      throw error
    }
  }

  const register = async (username: string, password: string, email: string): Promise<boolean> => {
    try {
      const response = await fetch('/api/web/auth/register', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ user_id: username, password, email }),
      })

      const data = await response.json()

      if (response.ok && data.success) {
        return true
      } else {
        throw new Error(data.message || '회원가입에 실패했습니다.')
      }
    } catch (error) {
      console.error('Register error:', error)
      throw error
    }
  }

  const logout = () => {
    token.value = null
    user.value = null
    isAuthenticated.value = false

    // 타이머 정리
    if (inactivityTimer) {
      clearTimeout(inactivityTimer)
      inactivityTimer = null
    }
    if (tokenExpiryTimer) {
      clearTimeout(tokenExpiryTimer)
      tokenExpiryTimer = null
    }

    // localStorage에서 제거
    localStorage.removeItem('auth_token')
    localStorage.removeItem('auth_user')
    localStorage.removeItem('auth_login_time')
  }

  const getAuthHeaders = (): Record<string, string> => {
    if (token.value) {
      return {
        'Authorization': `Bearer ${token.value}`,
        'Content-Type': 'application/json',
      }
    }
    return {
      'Content-Type': 'application/json',
    }
  }

  return {
    user,
    token,
    isAuthenticated,
    initAuth,
    login,
    register,
    logout,
    getAuthHeaders,
    resetInactivityTimer,
    setupActivityListeners
  }
})