#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
埋点事件自动化验证脚本

功能：自动化触发埋点事件，验证事件参数完整性
版本：v1.0
日期：2026-03-19
"""

import json
import time
import asyncio
import argparse
from datetime import datetime
from typing import Dict, List, Optional
from dataclasses import dataclass, asdict
from http.server import HTTPServer, BaseHTTPRequestHandler
import threading
import requests


# ==================== 配置 ====================

CONFIG = {
    "app_package": "com.shanjing.app",
    "mock_server_port": 9999,
    "adb_path": "adb",
    "test_device": None,  # 自动检测
    "timeout": 30,
}


# ==================== 数据模型 ====================

@dataclass
class AnalyticsEvent:
    """埋点事件模型"""
    event_name: str
    event_type: str
    timestamp: int
    user_id: str
    params: Dict
    
    def to_dict(self):
        return asdict(self)


@dataclass
class TestResult:
    """测试结果模型"""
    test_case: str
    status: str  # PASS / FAIL / SKIP
    message: str
    duration: float
    details: Optional[Dict] = None


# ==================== Mock 埋点服务器 ====================

class AnalyticsMockHandler(BaseHTTPRequestHandler):
    """Mock 埋点接收服务器"""
    
    received_events: List[Dict] = []
    
    def log_message(self, format, *args):
        # 静默日志
        pass
    
    def do_POST(self):
        if self.path == "/analytics":
            content_length = int(self.headers.get('Content-Length', 0))
            post_data = self.rfile.read(content_length)
            
            try:
                event_data = json.loads(post_data.decode('utf-8'))
                self.received_events.append(event_data)
                
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                self.wfile.write(json.dumps({"status": "ok"}).encode())
            except Exception as e:
                self.send_response(400)
                self.end_headers()
        else:
            self.send_response(404)
            self.end_headers()
    
    def do_GET(self):
        if self.path == "/events":
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps(self.received_events).encode())
        elif self.path == "/clear":
            self.received_events.clear()
            self.send_response(200)
            self.end_headers()
        else:
            self.send_response(404)
            self.end_headers()


class MockAnalyticsServer:
    """Mock 埋点服务器管理器"""
    
    def __init__(self, port: int = 9999):
        self.port = port
        self.server = None
        self.thread = None
        self.handler = AnalyticsMockHandler
        
    def start(self):
        """启动 Mock 服务器"""
        self.server = HTTPServer(('0.0.0.0', self.port), self.handler)
        self.thread = threading.Thread(target=self.server.serve_forever)
        self.thread.daemon = True
        self.thread.start()
        print(f"✅ Mock 埋点服务器已启动: http://localhost:{self.port}")
        
    def stop(self):
        """停止 Mock 服务器"""
        if self.server:
            self.server.shutdown()
            print("✅ Mock 埋点服务器已停止")
    
    def clear_events(self):
        """清空已接收事件"""
        self.handler.received_events.clear()
        
    def get_events(self) -> List[Dict]:
        """获取已接收事件"""
        return self.handler.received_events.copy()
    
    def wait_for_event(self, event_name: str, timeout: int = 10) -> Optional[Dict]:
        """等待特定事件"""
        start_time = time.time()
        while time.time() - start_time < timeout:
            for event in self.handler.received_events:
                if event.get('event_name') == event_name:
                    return event
            time.sleep(0.5)
        return None


# ==================== 测试验证器 ====================

class EventValidator:
    """埋点事件验证器"""
    
    # 事件参数规范定义
    EVENT_SCHEMAS = {
        "sos_triggered": {
            "required": ["trigger_location", "contact_count", "send_method", 
                        "send_success", "trigger_time"],
            "optional": ["route_id"],
            "types": {
                "trigger_location": dict,
                "contact_count": int,
                "send_method": str,
                "send_success": bool,
                "trigger_time": int,
                "route_id": str,
            }
        },
        "trip_shared": {
            "required": ["share_type", "route_id"],
            "optional": ["include_location", "recipient_count"],
            "types": {
                "share_type": str,
                "route_id": str,
                "include_location": bool,
                "recipient_count": int,
            },
            "enums": {
                "share_type": ["wechat", "moments", "copy_link"]
            }
        },
        "emergency_contact_updated": {
            "required": ["action", "contact_count"],
            "optional": [],
            "types": {
                "action": str,
                "contact_count": int,
            },
            "enums": {
                "action": ["add", "update", "delete"]
            }
        },
        "navigation_interrupted": {
            "required": ["reason", "duration", "route_id", "interrupt_time"],
            "optional": [],
            "types": {
                "reason": str,
                "duration": int,
                "route_id": str,
                "interrupt_time": int,
            },
            "enums": {
                "reason": ["call", "app_kill", "gps_lost"]
            }
        }
    }
    
    def validate(self, event: Dict) -> TestResult:
        """验证单个事件"""
        event_name = event.get('event_name')
        
        if not event_name:
            return TestResult(
                test_case="事件名称检查",
                status="FAIL",
                message="事件缺少 event_name 字段",
                duration=0
            )
        
        schema = self.EVENT_SCHEMAS.get(event_name)
        if not schema:
            return TestResult(
                test_case=f"未知事件: {event_name}",
                status="SKIP",
                message=f"未定义的事件类型: {event_name}",
                duration=0
            )
        
        params = event.get('params', {})
        errors = []
        
        # 检查必填参数
        for field in schema['required']:
            if field not in params:
                errors.append(f"缺少必填参数: {field}")
        
        # 检查参数类型
        for field, expected_type in schema.get('types', {}).items():
            if field in params:
                actual_type = type(params[field])
                if actual_type != expected_type:
                    errors.append(f"参数 {field} 类型错误: 期望 {expected_type.__name__}, 实际 {actual_type.__name__}")
        
        # 检查枚举值
        for field, allowed_values in schema.get('enums', {}).items():
            if field in params:
                if params[field] not in allowed_values:
                    errors.append(f"参数 {field} 值错误: {params[field]} 不在允许值 {allowed_values} 中")
        
        # 特殊验证
        if event_name == "sos_triggered":
            location = params.get('trigger_location', {})
            if 'lat' not in location or 'lng' not in location:
                errors.append("trigger_location 必须包含 lat 和 lng")
        
        if errors:
            return TestResult(
                test_case=f"{event_name} 参数验证",
                status="FAIL",
                message="; ".join(errors),
                duration=0,
                details={"event": event, "errors": errors}
            )
        
        return TestResult(
            test_case=f"{event_name} 参数验证",
            status="PASS",
            message="所有参数验证通过",
            duration=0,
            details={"event": event}
        )


# ==================== 测试执行器 ====================

class AnalyticsTestRunner:
    """埋点测试执行器"""
    
    def __init__(self):
        self.server = MockAnalyticsServer()
        self.validator = EventValidator()
        self.results: List[TestResult] = []
        
    def setup(self):
        """测试前准备"""
        self.server.start()
        self.server.clear_events()
        print("\n🧪 开始埋点自动化测试...\n")
        
    def teardown(self):
        """测试后清理"""
        self.server.stop()
        
    def run_test(self, test_name: str, event_name: str, trigger_func):
        """运行单个测试"""
        print(f"▶️ 执行测试: {test_name}")
        start_time = time.time()
        
        try:
            # 触发事件
            trigger_func()
            
            # 等待事件上报
            event = self.server.wait_for_event(event_name, timeout=10)
            
            if not event:
                result = TestResult(
                    test_case=test_name,
                    status="FAIL",
                    message=f"超时: 未收到 {event_name} 事件",
                    duration=time.time() - start_time
                )
            else:
                # 验证事件
                result = self.validator.validate(event)
                result.test_case = test_name
                result.duration = time.time() - start_time
                
        except Exception as e:
            result = TestResult(
                test_case=test_name,
                status="FAIL",
                message=f"异常: {str(e)}",
                duration=time.time() - start_time
            )
        
        self.results.append(result)
        status_emoji = "✅" if result.status == "PASS" else "❌" if result.status == "FAIL" else "⏭️"
        print(f"  {status_emoji} {result.status}: {result.message}")
        return result
    
    def generate_report(self, format: str = "console") -> str:
        """生成测试报告"""
        total = len(self.results)
        passed = sum(1 for r in self.results if r.status == "PASS")
        failed = sum(1 for r in self.results if r.status == "FAIL")
        skipped = sum(1 for r in self.results if r.status == "SKIP")
        
        if format == "console":
            lines = [
                "\n" + "=" * 60,
                "📊 埋点测试报告",
                "=" * 60,
                f"总测试数: {total}",
                f"✅ 通过: {passed}",
                f"❌ 失败: {failed}",
                f"⏭️ 跳过: {skipped}",
                f"通过率: {passed/total*100:.1f}%" if total > 0 else "通过率: N/A",
                "=" * 60,
            ]
            
            if failed > 0:
                lines.append("\n❌ 失败详情:")
                for r in self.results:
                    if r.status == "FAIL":
                        lines.append(f"  - {r.test_case}: {r.message}")
            
            return "\n".join(lines)
        
        elif format == "json":
            return json.dumps({
                "summary": {
                    "total": total,
                    "passed": passed,
                    "failed": failed,
                    "skipped": skipped,
                    "pass_rate": passed/total if total > 0 else 0
                },
                "results": [{
                    "test_case": r.test_case,
                    "status": r.status,
                    "message": r.message,
                    "duration": r.duration,
                    "details": r.details
                } for r in self.results]
            }, ensure_ascii=False, indent=2)
        
        elif format == "html":
            html_template = """
<!DOCTYPE html>
<html>
<head>
    <title>埋点测试报告</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        h1 { color: #333; }
        .summary { background: #f5f5f5; padding: 20px; border-radius: 8px; margin: 20px 0; }
        .pass { color: #4CAF50; }
        .fail { color: #f44336; }
        .skip { color: #ff9800; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background: #4CAF50; color: white; }
        tr:hover { background: #f5f5f5; }
    </style>
</head>
<body>
    <h1>📊 埋点测试报告</h1>
    <div class="summary">
        <h2>测试摘要</h2>
        <p>总测试数: <strong>{total}</strong></p>
        <p class="pass">✅ 通过: {passed}</p>
        <p class="fail">❌ 失败: {failed}</p>
        <p class="skip">⏭️ 跳过: {skipped}</p>
        <p>通过率: <strong>{pass_rate:.1f}%</strong></p>
    </div>
    <table>
        <tr>
            <th>测试用例</th>
            <th>状态</th>
            <th>耗时(秒)</th>
            <th>说明</th>
        </tr>
        {rows}
    </table>
</body>
</html>
"""
            rows = ""
            for r in self.results:
                status_class = "pass" if r.status == "PASS" else "fail" if r.status == "FAIL" else "skip"
                rows += f"<tr><td>{r.test_case}</td><td class='{status_class}'>{r.status}</td><td>{r.duration:.2f}</td><td>{r.message}</td></tr>"
            
            return html_template.format(
                total=total, passed=passed, failed=failed, skipped=skipped,
                pass_rate=passed/total*100 if total > 0 else 0,
                rows=rows
            )
        
        return ""


# ==================== 模拟触发函数 ====================

def mock_trigger_sos():
    """模拟触发 SOS"""
    # 这里应该调用 ADB 命令或 Flutter Driver 实际触发
    # 示例: 发送模拟请求到 Mock 服务器
    event = {
        "event_name": "sos_triggered",
        "event_type": "function",
        "timestamp": int(time.time() * 1000),
        "user_id": "test_user_001",
        "params": {
            "trigger_location": {"lat": 30.2741, "lng": 120.1551},
            "contact_count": 2,
            "send_method": "both",
            "send_success": True,
            "trigger_time": int(time.time() * 1000),
            "route_id": "R001"
        }
    }
    requests.post("http://localhost:9999/analytics", json=event)


def mock_trigger_share():
    """模拟触发分享"""
    event = {
        "event_name": "trip_shared",
        "event_type": "function",
        "timestamp": int(time.time() * 1000),
        "user_id": "test_user_001",
        "params": {
            "share_type": "wechat",
            "route_id": "R001",
            "include_location": True,
            "recipient_count": 2
        }
    }
    requests.post("http://localhost:9999/analytics", json=event)


def mock_trigger_contact_update():
    """模拟触发联系人更新"""
    event = {
        "event_name": "emergency_contact_updated",
        "event_type": "function",
        "timestamp": int(time.time() * 1000),
        "user_id": "test_user_001",
        "params": {
            "action": "add",
            "contact_count": 2
        }
    }
    requests.post("http://localhost:9999/analytics", json=event)


def mock_trigger_navigation_interrupted():
    """模拟触发导航中断"""
    event = {
        "event_name": "navigation_interrupted",
        "event_type": "exception",
        "timestamp": int(time.time() * 1000),
        "user_id": "test_user_001",
        "params": {
            "reason": "call",
            "duration": 300,
            "route_id": "R001",
            "interrupt_time": int(time.time() * 1000)
        }
    }
    requests.post("http://localhost:9999/analytics", json=event)


# ==================== 主程序 ====================

def main():
    parser = argparse.ArgumentParser(description="埋点事件自动化验证脚本")
    parser.add_argument("--all", action="store_true", help="运行所有测试")
    parser.add_argument("--event", choices=["sos_triggered", "trip_shared", 
                                           "emergency_contact_updated", "navigation_interrupted"],
                       help="运行指定事件测试")
    parser.add_argument("--report", choices=["console", "json", "html"], default="console",
                       help="报告格式")
    parser.add_argument("--output", help="报告输出文件路径")
    
    args = parser.parse_args()
    
    runner = AnalyticsTestRunner()
    
    try:
        runner.setup()
        
        if args.all or args.event is None:
            # 运行全部测试
            tests = [
                ("SOS 触发埋点", "sos_triggered", mock_trigger_sos),
                ("行程分享埋点", "trip_shared", mock_trigger_share),
                ("联系人更新埋点", "emergency_contact_updated", mock_trigger_contact_update),
                ("导航中断埋点", "navigation_interrupted", mock_trigger_navigation_interrupted),
            ]
        else:
            # 运行指定测试
            test_map = {
                "sos_triggered": ("SOS 触发埋点", "sos_triggered", mock_trigger_sos),
                "trip_shared": ("行程分享埋点", "trip_shared", mock_trigger_share),
                "emergency_contact_updated": ("联系人更新埋点", "emergency_contact_updated", mock_trigger_contact_update),
                "navigation_interrupted": ("导航中断埋点", "navigation_interrupted", mock_trigger_navigation_interrupted),
            }
            tests = [test_map[args.event]]
        
        for test_name, event_name, trigger_func in tests:
            runner.run_test(test_name, event_name, trigger_func)
            time.sleep(1)  # 间隔避免冲突
        
        # 生成报告
        report = runner.generate_report(args.report)
        print(report)
        
        if args.output:
            with open(args.output, 'w', encoding='utf-8') as f:
                f.write(report)
            print(f"\n📄 报告已保存至: {args.output}")
        
    finally:
        runner.teardown()


if __name__ == "__main__":
    main()
