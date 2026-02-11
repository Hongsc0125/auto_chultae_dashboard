import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      redirect: '/dashboard'
    },
    {
      path: '/login',
      name: 'login',
      component: () => import('../views/LoginView.vue'),
    },
    {
      path: '/dashboard',
      name: 'dashboard',
      component: () => import('../views/DashboardView.vue'),
      meta: { requiresAuth: true }
    },
  ],
})

// 라우트 가드
router.beforeEach((to, from, next) => {
  const authStore = useAuthStore()
  const isLocalhost = window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1'

  // 로컬 개발 환경이고 대시보드로 이동하려는 경우 인증 우회
  if (isLocalhost && to.matched.some(record => record.meta.requiresAuth)) {
    // 가짜 사용자 정보 설정 (필요한 경우)
    if (!authStore.user) {
      authStore.user = {
        id: 'dev-id',
        username: 'Developer',
        email: 'dev@example.com'
      }
      authStore.isAuthenticated = true
    }
    next()
    return
  }

  // 인증이 필요한 페이지인지 확인
  if (to.meta.requiresAuth && !authStore.isAuthenticated) {
    next('/login')
  } else if (to.path === '/login' && authStore.isAuthenticated) {
    next('/dashboard')
  } else {
    next()
  }
})

export default router
