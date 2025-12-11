#!/bin/bash
# MCP服务器控制脚本

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
PID_FILE="$SCRIPT_DIR/mcp_server.pid"
LOG_FILE="$PROJECT_DIR/log/server.log"

start() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p $PID > /dev/null 2>&1; then
            echo "MCP服务器已在运行 (PID: $PID)"
            return 1
        else
            echo "删除过期的PID文件"
            rm -f "$PID_FILE"
        fi
    fi
    
    echo "启动MCP服务器..."
    cd "$PROJECT_DIR"
    bundle exec ruby "$SCRIPT_DIR/mcp_server.rb" --daemon
    sleep 2
    
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        echo "MCP服务器已启动 (PID: $PID)"
        echo "日志文件: $LOG_FILE"
    else
        echo "启动失败，请检查日志"
        return 1
    fi
}

stop() {
    if [ ! -f "$PID_FILE" ]; then
        echo "MCP服务器未运行"
        return 1
    fi
    
    PID=$(cat "$PID_FILE")
    if ps -p $PID > /dev/null 2>&1; then
        echo "停止MCP服务器 (PID: $PID)..."
        kill $PID
        sleep 2
        
        if ps -p $PID > /dev/null 2>&1; then
            echo "强制停止..."
            kill -9 $PID
        fi
        
        rm -f "$PID_FILE"
        echo "MCP服务器已停止"
    else
        echo "进程不存在，清理PID文件"
        rm -f "$PID_FILE"
    fi
}

status() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p $PID > /dev/null 2>&1; then
            echo "MCP服务器正在运行 (PID: $PID)"
            echo "端口: 8080"
            return 0
        else
            echo "MCP服务器未运行 (PID文件存在但进程不存在)"
            return 1
        fi
    else
        echo "MCP服务器未运行"
        return 1
    fi
}

restart() {
    stop
    sleep 1
    start
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    status)
        status
        ;;
    restart)
        restart
        ;;
    *)
        echo "用法: $0 {start|stop|status|restart}"
        exit 1
        ;;
esac
