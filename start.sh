#!/bin/bash

# Auto Chultae Dashboard 서버 관리 스크립트
# Usage: ./start.sh [start|stop|restart|status|logs]

cd "$(dirname "$0")"

PROJECT_NAME="auto_chultae_dashboard"
PORT=6500
PID_FILE="$PWD/.${PROJECT_NAME}.pid"
LOG_DIR="$PWD/logs"
DATE=$(date +"%Y-%m-%d")
TIME=$(date +"%H:%M:%S")
LOG_FILE="$LOG_DIR/$DATE/server.log"
ACCESS_LOG="$LOG_DIR/$DATE/access.log"
ERROR_LOG="$LOG_DIR/$DATE/error.log"

# 로그 디렉토리 생성
create_log_dirs() {
    mkdir -p "$LOG_DIR/$DATE"
    echo "📁 로그 디렉토리 생성: $LOG_DIR/$DATE"
}

# 로그 메시지 함수
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

# 포트에서 실행 중인 프로세스 찾기 및 종료
kill_port_processes() {
    local port="$1"
    echo "🔍 포트 $port에서 실행 중인 프로세스를 확인합니다..."

    # lsof를 사용하여 포트를 사용하는 프로세스 찾기
    local pids=$(lsof -ti :$port 2>/dev/null)

    if [ -n "$pids" ]; then
        echo "⚠️  포트 $port에서 실행 중인 프로세스를 발견했습니다:"
        for pid in $pids; do
            local process_info=$(ps -p "$pid" -o pid,ppid,cmd --no-headers 2>/dev/null)
            if [ -n "$process_info" ]; then
                echo "   PID $pid: $process_info"
                log_message "WARN" "포트 $port 사용 중인 프로세스 발견 (PID: $pid)"
            fi
        done

        echo "🛑 기존 프로세스들을 종료합니다..."
        for pid in $pids; do
            if ps -p "$pid" > /dev/null 2>&1; then
                echo "   PID $pid 종료 중..."
                kill "$pid" 2>/dev/null
                log_message "INFO" "포트 $port 프로세스 종료 시도 (PID: $pid)"

                # 프로세스 종료 대기 (최대 5초)
                local count=0
                while ps -p "$pid" > /dev/null 2>&1 && [ $count -lt 5 ]; do
                    sleep 1
                    count=$((count + 1))
                done

                # 강제 종료가 필요한 경우
                if ps -p "$pid" > /dev/null 2>&1; then
                    echo "   PID $pid 강제 종료..."
                    kill -9 "$pid" 2>/dev/null
                    log_message "WARN" "포트 $port 프로세스 강제 종료 (PID: $pid)"
                else
                    log_message "INFO" "포트 $port 프로세스 정상 종료 (PID: $pid)"
                fi
            fi
        done

        # 최종 확인
        local remaining_pids=$(lsof -ti :$port 2>/dev/null)
        if [ -n "$remaining_pids" ]; then
            echo "❌ 일부 프로세스가 여전히 실행 중입니다. 수동으로 확인하세요."
            log_message "ERROR" "포트 $port 정리 실패 - 일부 프로세스 남아있음"
            return 1
        else
            echo "✅ 포트 $port가 정리되었습니다."
            log_message "INFO" "포트 $port 정리 완료"
        fi
    else
        echo "✅ 포트 $port는 사용 중이지 않습니다."
    fi

    return 0
}

# 서버 상태 확인
check_status() {
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE")
        if ps -p "$pid" > /dev/null 2>&1; then
            echo "✅ 서버가 실행 중입니다 (PID: $pid, Port: $PORT)"
            echo "🌐 URL: http://localhost:$PORT"
            return 0
        else
            echo "❌ PID 파일은 존재하지만 프로세스가 실행되지 않습니다"
            rm -f "$PID_FILE"
            return 1
        fi
    else
        echo "❌ 서버가 실행되지 않습니다"
        return 1
    fi
}

# 서버 시작
start_server() {
    create_log_dirs

    echo "🚀 Auto Chultae Dashboard 서버를 시작합니다..."
    log_message "INFO" "서버 시작 프로세스 시작"

    # 기존 관리되는 서버가 있다면 안전하게 종료
    if check_status > /dev/null 2>&1; then
        echo "🔄 기존 관리되는 서버를 안전하게 종료합니다..."
        local pid=$(cat "$PID_FILE")
        log_message "INFO" "기존 서버 종료 시작 (PID: $pid)"

        # 기존 서버 종료
        stop_server_internal
        sleep 2
    fi

    # 포트 6500에서 실행 중인 모든 프로세스 정리
    kill_port_processes "$PORT"

    # Node.js 버전 확인
    echo "📋 Node.js 버전 확인 중..."
    local node_version=$(node --version)
    log_message "INFO" "Node.js 버전: $node_version"

    # npm 패키지 설치
    echo "📦 패키지 설치 중..."
    log_message "INFO" "패키지 설치 시작"
    if npm install >> "$LOG_FILE" 2>> "$ERROR_LOG"; then
        log_message "INFO" "패키지 설치 완료"
    else
        log_message "ERROR" "패키지 설치 실패"
        return 1
    fi

    # 프로덕션 빌드
    echo "🔨 프로덕션 빌드 중..."
    log_message "INFO" "프로덕션 빌드 시작"
    if npm run build >> "$LOG_FILE" 2>> "$ERROR_LOG"; then
        log_message "INFO" "프로덕션 빌드 완료"
    else
        log_message "ERROR" "프로덕션 빌드 실패"
        return 1
    fi

    # 서버 백그라운드 시작
    echo "🌐 서버를 포트 $PORT에서 백그라운드로 시작합니다..."
    log_message "INFO" "서버 시작 (포트: $PORT)"

    nohup npm run preview > "$ACCESS_LOG" 2> "$ERROR_LOG" &
    local server_pid=$!
    echo $server_pid > "$PID_FILE"

    # 서버 시작 확인 (3초 대기)
    sleep 3
    if ps -p "$server_pid" > /dev/null 2>&1; then
        log_message "INFO" "서버 시작 성공 (PID: $server_pid)"
        echo "✅ 서버가 백그라운드에서 실행 중입니다"
        echo "📋 PID: $server_pid"
        echo "🌐 URL: http://localhost:$PORT"
        echo "📝 로그 위치: $LOG_DIR/$DATE/"
        echo "   - 서버 로그: $LOG_FILE"
        echo "   - 접근 로그: $ACCESS_LOG"
        echo "   - 에러 로그: $ERROR_LOG"
    else
        log_message "ERROR" "서버 시작 실패"
        rm -f "$PID_FILE"
        echo "❌ 서버 시작에 실패했습니다. 에러 로그를 확인하세요: $ERROR_LOG"
        return 1
    fi
}

# 서버 중지 (내부용 - 메시지 최소화)
stop_server_internal() {
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE")
        if ps -p "$pid" > /dev/null 2>&1; then
            log_message "INFO" "기존 서버 종료 시도 (PID: $pid)"
            kill "$pid"

            # 프로세스 종료 대기 (최대 8초)
            local count=0
            while ps -p "$pid" > /dev/null 2>&1 && [ $count -lt 8 ]; do
                sleep 1
                count=$((count + 1))
            done

            if ps -p "$pid" > /dev/null 2>&1; then
                kill -9 "$pid" 2>/dev/null
                log_message "WARN" "기존 서버 강제 종료 (PID: $pid)"
            else
                log_message "INFO" "기존 서버 정상 종료 (PID: $pid)"
            fi

            rm -f "$PID_FILE"
        else
            rm -f "$PID_FILE"
        fi
    fi
}

# 서버 중지 (외부용)
stop_server() {
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE")
        if ps -p "$pid" > /dev/null 2>&1; then
            echo "🛑 서버를 중지합니다 (PID: $pid)..."
            log_message "INFO" "서버 중지 요청 (PID: $pid)"
            kill "$pid"

            # 프로세스 종료 대기 (최대 10초)
            local count=0
            while ps -p "$pid" > /dev/null 2>&1 && [ $count -lt 10 ]; do
                sleep 1
                count=$((count + 1))
            done

            if ps -p "$pid" > /dev/null 2>&1; then
                echo "⚠️  강제 종료합니다..."
                kill -9 "$pid"
                log_message "WARN" "서버 강제 종료 (PID: $pid)"
            else
                log_message "INFO" "서버 정상 종료 (PID: $pid)"
            fi

            rm -f "$PID_FILE"
            echo "✅ 서버가 중지되었습니다"
        else
            echo "❌ PID 파일은 존재하지만 프로세스가 실행되지 않습니다"
            rm -f "$PID_FILE"
        fi
    else
        echo "❌ 서버가 실행되지 않습니다"
    fi
}

# 로그 보기
show_logs() {
    local log_type="${1:-server}"
    case "$log_type" in
        "server"|"s")
            if [ -f "$LOG_FILE" ]; then
                echo "📋 서버 로그 (실시간): $LOG_FILE"
                tail -f "$LOG_FILE"
            else
                echo "❌ 서버 로그 파일이 없습니다: $LOG_FILE"
            fi
            ;;
        "access"|"a")
            if [ -f "$ACCESS_LOG" ]; then
                echo "📋 접근 로그 (실시간): $ACCESS_LOG"
                tail -f "$ACCESS_LOG"
            else
                echo "❌ 접근 로그 파일이 없습니다: $ACCESS_LOG"
            fi
            ;;
        "error"|"e")
            if [ -f "$ERROR_LOG" ]; then
                echo "📋 에러 로그 (실시간): $ERROR_LOG"
                tail -f "$ERROR_LOG"
            else
                echo "❌ 에러 로그 파일이 없습니다: $ERROR_LOG"
            fi
            ;;
        *)
            echo "사용법: $0 logs [server|access|error]"
            echo "  server (s): 서버 로그"
            echo "  access (a): 접근 로그"
            echo "  error (e): 에러 로그"
            ;;
    esac
}

# 사용법 표시
show_usage() {
    echo "사용법: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  start     서버 시작"
    echo "  stop      서버 중지"
    echo "  restart   서버 재시작"
    echo "  status    서버 상태 확인"
    echo "  logs [type]  로그 보기 (server|access|error)"
    echo ""
    echo "Examples:"
    echo "  $0 start          # 서버 시작"
    echo "  $0 stop           # 서버 중지"
    echo "  $0 status         # 상태 확인"
    echo "  $0 logs server    # 서버 로그 실시간 보기"
}

# 메인 로직
case "${1:-restart}" in
    "start")
        start_server
        ;;
    "stop")
        create_log_dirs
        stop_server
        ;;
    "restart")
        create_log_dirs
        echo "🔄 서버를 재시작합니다..."
        log_message "INFO" "서버 재시작 요청"
        start_server
        ;;
    "status")
        check_status
        ;;
    "logs")
        show_logs "$2"
        ;;
    "help"|"-h"|"--help")
        show_usage
        ;;
    *)
        echo "❌ 알 수 없는 명령어: $1"
        show_usage
        exit 1
        ;;
esac
