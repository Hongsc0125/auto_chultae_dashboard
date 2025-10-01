#!/bin/bash

# Auto Chultae Dashboard 서버 종료 스크립트
# Usage: ./stop.sh [all|managed|port]

PROJECT_NAME="auto_chultae_dashboard"
PORT=6500
PID_FILE="$PWD/.${PROJECT_NAME}.pid"
LOG_DIR="$PWD/logs"
DATE=$(date +"%Y-%m-%d")
LOG_FILE="$LOG_DIR/$DATE/server.log"

# 로그 디렉토리 생성
create_log_dirs() {
    mkdir -p "$LOG_DIR/$DATE"
}

# 로그 메시지 함수
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

# 관리되는 서버 상태 확인
check_managed_server() {
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE")
        if ps -p "$pid" > /dev/null 2>&1; then
            echo "✅ 관리되는 서버가 실행 중입니다 (PID: $pid, Port: $PORT)"
            return 0
        else
            echo "❌ PID 파일은 존재하지만 프로세스가 실행되지 않습니다"
            rm -f "$PID_FILE"
            return 1
        fi
    else
        echo "❌ 관리되는 서버가 실행되지 않습니다"
        return 1
    fi
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

# 관리되는 서버 종료
stop_managed_server() {
    create_log_dirs

    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE")
        if ps -p "$pid" > /dev/null 2>&1; then
            echo "🛑 관리되는 서버를 중지합니다 (PID: $pid)..."
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
            echo "✅ 관리되는 서버가 중지되었습니다"
        else
            echo "❌ PID 파일은 존재하지만 프로세스가 실행되지 않습니다"
            rm -f "$PID_FILE"
        fi
    else
        echo "❌ 관리되는 서버가 실행되지 않습니다"
    fi
}

# 모든 관련 프로세스 종료
stop_all_processes() {
    create_log_dirs

    echo "🛑 모든 Auto Chultae Dashboard 관련 프로세스를 종료합니다..."
    log_message "INFO" "전체 프로세스 종료 시작"

    # 1. 관리되는 서버 종료
    echo ""
    echo "🔸 단계 1: 관리되는 서버 종료"
    stop_managed_server

    # 2. 포트 6500 정리
    echo ""
    echo "🔸 단계 2: 포트 $PORT 정리"
    kill_port_processes "$PORT"

    # 3. 프로젝트 관련 Node.js 프로세스 정리
    echo ""
    echo "🔸 단계 3: 프로젝트 관련 Node.js 프로세스 정리"
    local node_pids=$(ps aux | grep -E "(vite|vue|$PROJECT_NAME)" | grep -v grep | awk '{print $2}' 2>/dev/null)

    if [ -n "$node_pids" ]; then
        echo "🔍 프로젝트 관련 Node.js 프로세스를 발견했습니다:"
        for pid in $node_pids; do
            local process_info=$(ps -p "$pid" -o pid,cmd --no-headers 2>/dev/null)
            if [ -n "$process_info" ]; then
                echo "   $process_info"
            fi
        done

        echo "🛑 프로젝트 관련 프로세스들을 종료합니다..."
        for pid in $node_pids; do
            if ps -p "$pid" > /dev/null 2>&1; then
                kill "$pid" 2>/dev/null
                log_message "INFO" "프로젝트 관련 프로세스 종료 (PID: $pid)"
                sleep 1

                if ps -p "$pid" > /dev/null 2>&1; then
                    kill -9 "$pid" 2>/dev/null
                    log_message "WARN" "프로젝트 관련 프로세스 강제 종료 (PID: $pid)"
                fi
            fi
        done
    else
        echo "✅ 추가 프로젝트 관련 프로세스가 없습니다."
    fi

    echo ""
    echo "🏁 모든 프로세스 정리가 완료되었습니다."
    log_message "INFO" "전체 프로세스 종료 완료"
}

# 사용법 표시
show_usage() {
    echo "사용법: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  managed   관리되는 서버만 중지 (기본값)"
    echo "  port      포트 $PORT의 모든 프로세스 중지"
    echo "  all       모든 관련 프로세스 중지"
    echo "  status    현재 서버 상태 확인"
    echo ""
    echo "Examples:"
    echo "  $0              # 관리되는 서버만 중지"
    echo "  $0 managed      # 관리되는 서버만 중지"
    echo "  $0 port         # 포트 6500의 모든 프로세스 중지"
    echo "  $0 all          # 모든 관련 프로세스 중지"
    echo "  $0 status       # 서버 상태 확인"
}

# 메인 로직
case "${1:-all}" in
    "managed"|"")
        stop_managed_server
        ;;
    "port")
        create_log_dirs
        kill_port_processes "$PORT"
        ;;
    "all")
        stop_all_processes
        ;;
    "status")
        check_managed_server
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