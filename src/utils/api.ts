import { useAuthStore } from '../stores/auth'

// API 요청 래퍼 함수 - 401 오류 시 자동 로그아웃
export const apiRequest = async (url: string, options: RequestInit = {}) => {
  const authStore = useAuthStore()

  // 인증 헤더 자동 추가
  const headers = {
    'Content-Type': 'application/json',
    ...authStore.getAuthHeaders(),
    ...options.headers,
  }

  try {
    const response = await fetch(url, {
      ...options,
      headers,
    })

    // 401 Unauthorized - 토큰 만료 또는 인증 실패
    if (response.status === 401) {
      console.log('401 Unauthorized - 자동 로그아웃 실행')
      authStore.logout()
      window.location.href = '/login'
      throw new Error('인증이 만료되었습니다. 다시 로그인해주세요.')
    }

    return response
  } catch (error) {
    // 네트워크 오류 등은 그대로 전파
    throw error
  }
}

// GET 요청 헬퍼
export const apiGet = async (url: string) => {
  return apiRequest(url, { method: 'GET' })
}

// POST 요청 헬퍼
export const apiPost = async (url: string, data?: any) => {
  return apiRequest(url, {
    method: 'POST',
    body: data ? JSON.stringify(data) : undefined,
  })
}

// PUT 요청 헬퍼
export const apiPut = async (url: string, data?: any) => {
  return apiRequest(url, {
    method: 'PUT',
    body: data ? JSON.stringify(data) : undefined,
  })
}

// DELETE 요청 헬퍼
export const apiDelete = async (url: string) => {
  return apiRequest(url, { method: 'DELETE' })
}