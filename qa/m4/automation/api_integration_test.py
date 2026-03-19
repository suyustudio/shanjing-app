#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
API 集成测试脚本

功能：测试后端 API 接口的功能和性能
版本：v1.0
日期：2026-03-19
"""

import json
import time
import requests
import statistics
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass
from concurrent.futures import ThreadPoolExecutor
import argparse


# 配置
CONFIG = {
    "base_url": "https://api.shanjing.app",
    "timeout": 10,
}


@dataclass
class APITestResult:
    """API 测试结果"""
    api_name: str
    method: str
    endpoint: str
    status_code: int
    response_time: float
    success: bool
    error_message: Optional[str] = None


class ShanjingAPIClient:
    """API 客户端"""
    
    def __init__(self, base_url: str = None):
        self.base_url = base_url or CONFIG["base_url"]
        self.session = requests.Session()
        self.token: Optional[str] = None
        
    def authenticate(self) -> bool:
        """认证"""
        try:
            response = self.session.post(
                f"{self.base_url}/api/auth/login",
                json={"username": "test", "password": "test"},
                timeout=CONFIG["timeout"]
            )
            if response.status_code == 200:
                self.token = response.json().get("token")
                self.session.headers["Authorization"] = f"Bearer {self.token}"
                return True
            return False
        except Exception as e:
            print(f"认证失败: {e}")
            return False
    
    def request(self, method: str, endpoint: str, **kwargs) -> Tuple[int, float, dict]:
        """发送请求"""
        url = f"{self.base_url}{endpoint}"
        start = time.time()
        try:
            response = self.session.request(method, url, timeout=CONFIG["timeout"], **kwargs)
            resp_time = time.time() - start
            data = response.json() if response.content else {}
            return response.status_code, resp_time, data
        except Exception as e:
            return 0, time.time() - start, {"error": str(e)}


def run_api_tests(base_url: str = None):
    """运行 API 测试"""
    client = ShanjingAPIClient(base_url)
    results = []
    
    print("🧪 API 集成测试开始\n")
    
    # 认证
    if not client.authenticate():
        print("⚠️  认证失败，使用无认证测试模式")
    else:
        print("✅ 认证成功\n")
    
    # API 测试列表
    tests = [
        # 路线 API
        ("获取路线列表", "GET", "/api/trails", None),
        ("获取路线详情", "GET", "/api/trails/R001", None),
        ("下载离线包", "POST", "/api/trails/R001/download", {"include_map": True}),
        
        # 用户 API
        ("获取紧急联系人", "GET", "/api/user/emergency-contact", None),
        ("添加紧急联系人", "POST", "/api/user/emergency-contact", 
         {"name": "测试", "phone": "13800138000"}),
        ("更新紧急联系人", "PUT", "/api/user/emergency-contact/1",
         {"name": "更新", "phone": "13800138001"}),
        ("删除紧急联系人", "DELETE", "/api/user/emergency-contact/1", None),
        
        # 分享 API
        ("生成分享卡片", "POST", "/api/share/card",
         {"route_id": "R001", "platform": "xiaohongshu"}),
        
        # SOS API
        ("触发 SOS", "POST", "/api/sos/trigger",
         {"location": {"lat": 30.2741, "lng": 120.1551}, "test_mode": True}),
    ]
    
    for name, method, endpoint, data in tests:
        print(f"▶️  {name}...", end=" ")
        status, resp_time, resp_data = client.request(method, endpoint, json=data)
        
        success = 200 <= status < 300
        status_emoji = "✅" if success else "❌"
        
        print(f"{status_emoji} {status} ({resp_time:.2f}s)")
        
        results.append(APITestResult(
            api_name=name,
            method=method,
            endpoint=endpoint,
            status_code=status,
            response_time=resp_time,
            success=success,
            error_message=resp_data.get("error") if not success else None
        ))
    
    # 生成报告
    print("\n" + "="*60)
    print("📊 API 测试报告")
    print("="*60)
    
    total = len(results)
    passed = sum(1 for r in results if r.success)
    failed = total - passed
    avg_time = statistics.mean([r.response_time for r in results])
    
    print(f"总测试数: {total}")
    print(f"✅ 通过: {passed}")
    print(f"❌ 失败: {failed}")
    print(f"平均响应时间: {avg_time:.2f}s")
    
    if failed > 0:
        print("\n❌ 失败详情:")
        for r in results:
            if not r.success:
                print(f"  - {r.api_name}: HTTP {r.status_code} - {r.error_message}")
    
    return results


def main():
    parser = argparse.ArgumentParser(description="API 集成测试脚本")
    parser.add_argument("--url", help="API 基础 URL", default=CONFIG["base_url"])
    parser.add_argument("--output", help="输出文件路径")
    
    args = parser.parse_args()
    
    results = run_api_tests(args.url)
    
    if args.output:
        output_data = [{
            "api_name": r.api_name,
            "method": r.method,
            "endpoint": r.endpoint,
            "status_code": r.status_code,
            "response_time": r.response_time,
            "success": r.success,
            "error_message": r.error_message
        } for r in results]
        
        with open(args.output, 'w', encoding='utf-8') as f:
            json.dump(output_data, f, ensure_ascii=False, indent=2)
        print(f"\n📄 报告已保存至: {args.output}")


if __name__ == "__main__":
    main()
