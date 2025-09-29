import { defineStore } from 'pinia'
import { ref } from 'vue'

interface User {
  id: string
  username: string
  email: string
}

export const useAuthStore = defineStore('auth', () => {
  const user = ref<User | null>(null)
  const token = ref<string | null>(null)
  const isAuthenticated = ref(false)

  // 토큰을 localStorage에서 초기화
  const initAuth = () => {
    const savedToken = localStorage.getItem('auth_token')
    const savedUser = localStorage.getItem('auth_user')

    if (savedToken && savedUser) {
      token.value = savedToken
      user.value = JSON.parse(savedUser)
      isAuthenticated.value = true
    }
  }

  const login = async (username: string, password: string): Promise<boolean> => {
    try {
      const response = await fetch('http://localhost:9000/api/web/auth/login', {
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

        // localStorage에 저장
        localStorage.setItem('auth_token', data.access_token)
        localStorage.setItem('auth_user', JSON.stringify(data.user))

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
      const response = await fetch('http://localhost:9000/api/web/auth/register', {
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

    // localStorage에서 제거
    localStorage.removeItem('auth_token')
    localStorage.removeItem('auth_user')
  }

  const getAuthHeaders = () => {
    if (token.value) {
      return {
        'Authorization': `Bearer ${token.value}`,
        'Content-Type': 'application/json',
      }
    }
    return {}
  }

  return {
    user,
    token,
    isAuthenticated,
    initAuth,
    login,
    register,
    logout,
    getAuthHeaders
  }
})