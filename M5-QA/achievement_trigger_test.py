#!/usr/bin/env python3
"""
成就系统触发测试脚本
用于批量验证成就触发条件的正确性

使用方法:
    python achievement_trigger_test.py --env=test --user=user_test_001
"""

import argparse
import json
import requests
import sys
from datetime import datetime, timedelta
from typing import Dict, List, Optional

# API 配置
API_BASE_URL = {
    'dev': 'http://localhost:3000/api/v1',
    'test': 'https://api-test.shanjing.app/api/v1',
    'prod': 'https://api.shanjing.app/api/v1'
}

class AchievementTriggerTester:
    """成就触发测试器"""
    
    def __init__(self, env: str = 'test', api_key: Optional[str] = None):
        self.base_url = API_BASE_URL.get(env, API_BASE_URL['test'])
        self.headers = {
            'Content-Type': 'application/json',
            'Authorization': f'Bearer {api_key}' if api_key else ''
        }
        self.results = []
    
    def _api_call(self, method: str, endpoint: str, data: Dict = None) -> Dict:
        """调用 API"""
        url = f"{self.base_url}/{endpoint}"
        try:
            if method == 'GET':
                response = requests.get(url, headers=self.headers, timeout=30)
            elif method == 'POST':
                response = requests.post(url, json=data, headers=self.headers, timeout=30)
            elif method == 'PUT':
                response = requests.put(url, json=data, headers=self.headers, timeout=30)
            else:
                raise ValueError(f"Unsupported method: {method}")
            
            response.raise_for_status()
            return response.json()
        except requests.RequestException as e:
            print(f"❌ API 调用失败: {e}")
            return {'error': str(e)}
    
    def reset_user_progress(self, user_id: str) -> bool:
        """重置用户进度（测试专用接口）"""
        print(f"🔄 重置用户 {user_id} 的进度...")
        result = self._api_call('POST', f'test/reset-user/{user_id}')
        success = 'error' not in result
        print(f"{'✅' if success else '❌'} 重置{'成功' if success else '失败'}")
        return success
    
    def set_user_progress(self, user_id: str, **kwargs) -> bool:
        """设置用户进度"""
        print(f"⚙️ 设置用户进度: {kwargs}")
        result = self._api_call('POST', f'test/set-progress/{user_id}', kwargs)
        success = 'error' not in result
        print(f"{'✅' if success else '❌'} 设置{'成功' if success else '失败'}")
        return success
    
    def get_user_achievements(self, user_id: str) -> List[Dict]:
        """获取用户已解锁成就"""
        result = self._api_call('GET', f'users/{user_id}/achievements')
        return result.get('data', [])
    
    def get_user_progress(self, user_id: str) -> Dict:
        """获取用户进度"""
        result = self._api_call('GET', f'users/{user_id}/progress')
        return result.get('data', {})
    
    def trigger_achievement_check(self, user_id: str, activity_type: str, data: Dict) -> Dict:
        """触发成就检查"""
        payload = {
            'user_id': user_id,
            'activity_type': activity_type,
            'data': data
        }
        return self._api_call('POST', 'achievements/check', payload)
    
    def test_first_hike_achievement(self, user_id: str) -> bool:
        """测试首次徒步成就"""
        print("\n📋 测试: 首次徒步成就 (TC-ACH-001)")
        
        # 重置用户
        if not self.reset_user_progress(user_id):
            return False
        
        # 触发成就检查
        result = self.trigger_achievement_check(
            user_id=user_id,
            activity_type='trail_complete',
            data={'trail_id': 'trail_001', 'distance': 5000}
        )
        
        unlocked = result.get('unlocked', [])
        achievement_ids = [a['id'] for a in unlocked]
        
        # 验证
        if 'first_001' in achievement_ids:
            print("✅ 首次徒步成就解锁成功")
            self.results.append({'test': 'TC-ACH-001', 'result': 'PASS'})
            return True
        else:
            print(f"❌ 首次徒步成就未解锁，实际解锁: {achievement_ids}")
            self.results.append({'test': 'TC-ACH-001', 'result': 'FAIL'})
            return False
    
    def test_distance_achievements(self, user_id: str) -> bool:
        """测试里程累计成就"""
        print("\n📋 测试: 里程累计成就 (TC-ACH-002~005)")
        
        test_cases = [
            {'distance': 9500, 'add': 500, 'expected': 'dist_001', 'name': '初出茅庐(10km)'},
            {'distance': 48500, 'add': 1500, 'expected': 'dist_002', 'name': '行路人(50km)'},
            {'distance': 98500, 'add': 1500, 'expected': 'dist_003', 'name': '远行者(100km)'},
            {'distance': 498500, 'add': 1500, 'expected': 'dist_004', 'name': '千里行者(500km)'},
            {'distance': 998500, 'add': 1500, 'expected': 'dist_005', 'name': '万里长征(1000km)'},
        ]
        
        all_passed = True
        for case in test_cases:
            print(f"  🔄 测试 {case['name']}...")
            
            # 设置初始进度
            self.set_user_progress(user_id, total_distance=case['distance'])
            
            # 触发成就检查
            result = self.trigger_achievement_check(
                user_id=user_id,
                activity_type='trail_complete',
                data={'trail_id': 'trail_test', 'distance': case['add']}
            )
            
            unlocked = [a['id'] for a in result.get('unlocked', [])]
            
            if case['expected'] in unlocked:
                print(f"    ✅ {case['name']} 解锁成功")
                self.results.append({'test': f"distance_{case['expected']}", 'result': 'PASS'})
            else:
                print(f"    ❌ {case['name']} 未解锁，实际: {unlocked}")
                self.results.append({'test': f"distance_{case['expected']}", 'result': 'FAIL'})
                all_passed = False
        
        return all_passed
    
    def test_trail_collector_achievements(self, user_id: str) -> bool:
        """测试路线收集成就"""
        print("\n📋 测试: 路线收集成就 (TC-ACH-006)")
        
        test_cases = [
            {'unique': 4, 'expected': 'trail_001_ach', 'name': '路线探索者(5条)'},
            {'unique': 14, 'expected': 'trail_002_ach', 'name': '路线达人(15条)'},
            {'unique': 29, 'expected': 'trail_003_ach', 'name': '路线专家(30条)'},
            {'unique': 49, 'expected': 'trail_004_ach', 'name': '路线大师(50条)'},
            {'unique': 99, 'expected': 'trail_005_ach', 'name': '路线传奇(100条)'},
        ]
        
        all_passed = True
        for case in test_cases:
            print(f"  🔄 测试 {case['name']}...")
            
            self.set_user_progress(user_id, unique_trails=case['unique'], total_trails=case['unique'])
            
            result = self.trigger_achievement_check(
                user_id=user_id,
                activity_type='trail_complete',
                data={'trail_id': 'trail_new', 'is_new_trail': True}
            )
            
            unlocked = [a['id'] for a in result.get('unlocked', [])]
            
            if case['expected'] in unlocked:
                print(f"    ✅ {case['name']} 解锁成功")
                self.results.append({'test': f"trail_{case['expected']}", 'result': 'PASS'})
            else:
                print(f"    ❌ {case['name']} 未解锁")
                all_passed = False
        
        return all_passed
    
    def test_streak_achievements(self, user_id: str) -> bool:
        """测试连续打卡成就"""
        print("\n📋 测试: 连续打卡成就 (TC-ACH-007)")
        
        test_cases = [
            {'streak': 2, 'expected': 'streak_001', 'name': '坚持不懈(3天)'},
            {'streak': 6, 'expected': 'streak_002', 'name': '习惯养成(7天)'},
            {'streak': 29, 'expected': 'streak_003', 'name': '持之以恒(30天)'},
        ]
        
        all_passed = True
        for case in test_cases:
            print(f"  🔄 测试 {case['name']}...")
            
            # 设置连续打卡天数
            self._api_call('POST', f'test/set-streak/{user_id}', {'days': case['streak']})
            
            result = self.trigger_achievement_check(
                user_id=user_id,
                activity_type='trail_complete',
                data={'trail_id': 'trail_001'}
            )
            
            unlocked = [a['id'] for a in result.get('unlocked', [])]
            
            if case['expected'] in unlocked:
                print(f"    ✅ {case['name']} 解锁成功")
                self.results.append({'test': f"streak_{case['expected']}", 'result': 'PASS'})
            else:
                print(f"    ❌ {case['name']} 未解锁")
                all_passed = False
        
        return all_passed
    
    def test_share_achievements(self, user_id: str) -> bool:
        """测试分享达人成就"""
        print("\n📋 测试: 分享达人成就 (TC-ACH-008)")
        
        test_cases = [
            {'shares': 4, 'expected': 'share_001', 'name': '乐于分享(5次)', 'field': 'total_shares'},
            {'shares': 19, 'expected': 'share_002', 'name': '内容创作者(20次)', 'field': 'total_shares'},
            {'likes': 99, 'expected': 'share_003', 'name': '户外博主(100赞)', 'field': 'total_likes'},
            {'likes': 499, 'expected': 'share_004', 'name': '意见领袖(500赞)', 'field': 'total_likes'},
        ]
        
        all_passed = True
        for case in test_cases:
            print(f"  🔄 测试 {case['name']}...")
            
            if 'shares' in case:
                self.set_user_progress(user_id, total_shares=case['shares'])
                activity_type = 'share'
            else:
                self.set_user_progress(user_id, total_likes=case['likes'])
                activity_type = 'like_received'
            
            result = self.trigger_achievement_check(
                user_id=user_id,
                activity_type=activity_type,
                data={}
            )
            
            unlocked = [a['id'] for a in result.get('unlocked', [])]
            
            if case['expected'] in unlocked:
                print(f"    ✅ {case['name']} 解锁成功")
                self.results.append({'test': f"share_{case['expected']}", 'result': 'PASS'})
            else:
                print(f"    ❌ {case['name']} 未解锁")
                all_passed = False
        
        return all_passed
    
    def test_duplicate_unlock(self, user_id: str) -> bool:
        """测试重复解锁 (TC-BND-001)"""
        print("\n📋 测试: 重复解锁处理 (TC-BND-001)")
        
        # 先解锁首次成就
        self.reset_user_progress(user_id)
        self.trigger_achievement_check(
            user_id=user_id,
            activity_type='trail_complete',
            data={'trail_id': 'trail_001'}
        )
        
        # 获取当前成就数
        achievements_before = len(self.get_user_achievements(user_id))
        
        # 再次触发
        result = self.trigger_achievement_check(
            user_id=user_id,
            activity_type='trail_complete',
            data={'trail_id': 'trail_002'}
        )
        
        achievements_after = len(self.get_user_achievements(user_id))
        
        # 验证没有重复解锁 first_001
        unlocked = [a['id'] for a in result.get('unlocked', [])]
        
        if 'first_001' not in unlocked and achievements_after == achievements_before:
            print("✅ 重复解锁处理正确")
            self.results.append({'test': 'TC-BND-001', 'result': 'PASS'})
            return True
        else:
            print(f"❌ 重复解锁检测失败")
            self.results.append({'test': 'TC-BND-001', 'result': 'FAIL'})
            return False
    
    def test_concurrent_unlock(self, user_id: str) -> bool:
        """测试并发解锁 (TC-BND-003)"""
        print("\n📋 测试: 多成就同时触发 (TC-BND-003)")
        
        # 设置同时满足多个成就条件
        self.set_user_progress(
            user_id,
            total_distance=9999,  # 接近 10km
            unique_trails=4,
            total_trails=4
        )
        
        # 完成一条新路线
        result = self.trigger_achievement_check(
            user_id=user_id,
            activity_type='trail_complete',
            data={'trail_id': 'trail_new', 'distance': 100, 'is_new_trail': True}
        )
        
        unlocked = [a['id'] for a in result.get('unlocked', [])]
        
        # 验证多个成就同时解锁
        if 'dist_001' in unlocked and 'trail_001_ach' in unlocked:
            print(f"✅ 并发解锁成功，解锁成就: {unlocked}")
            self.results.append({'test': 'TC-BND-003', 'result': 'PASS'})
            return True
        else:
            print(f"❌ 并发解锁失败，实际解锁: {unlocked}")
            self.results.append({'test': 'TC-BND-003', 'result': 'FAIL'})
            return False
    
    def run_all_tests(self, user_id: str) -> Dict:
        """运行所有测试"""
        print("=" * 60)
        print("🚀 开始成就系统触发测试")
        print("=" * 60)
        
        start_time = datetime.now()
        
        tests = [
            ('首次徒步成就', self.test_first_hike_achievement),
            ('里程累计成就', self.test_distance_achievements),
            ('路线收集成就', self.test_trail_collector_achievements),
            ('连续打卡成就', self.test_streak_achievements),
            ('分享达人成就', self.test_share_achievements),
            ('重复解锁测试', self.test_duplicate_unlock),
            ('并发解锁测试', self.test_concurrent_unlock),
        ]
        
        results = []
        for name, test_func in tests:
            try:
                passed = test_func(user_id)
                results.append({'name': name, 'passed': passed})
            except Exception as e:
                print(f"❌ 测试异常: {e}")
                results.append({'name': name, 'passed': False, 'error': str(e)})
        
        end_time = datetime.now()
        duration = (end_time - start_time).total_seconds()
        
        # 生成报告
        report = {
            'timestamp': datetime.now().isoformat(),
            'duration': duration,
            'total': len(results),
            'passed': sum(1 for r in results if r['passed']),
            'failed': sum(1 for r in results if not r['passed']),
            'results': results,
            'details': self.results
        }
        
        self._print_report(report)
        return report
    
    def _print_report(self, report: Dict):
        """打印测试报告"""
        print("\n" + "=" * 60)
        print("📊 测试报告")
        print("=" * 60)
        print(f"总测试数: {report['total']}")
        print(f"通过: {report['passed']} ✅")
        print(f"失败: {report['failed']} ❌")
        print(f"耗时: {report['duration']:.2f}秒")
        print("-" * 60)
        
        for result in report['results']:
            status = "✅" if result['passed'] else "❌"
            print(f"{status} {result['name']}")
        
        print("=" * 60)


def main():
    parser = argparse.ArgumentParser(description='成就系统触发测试脚本')
    parser.add_argument('--env', choices=['dev', 'test', 'prod'], default='test',
                       help='测试环境')
    parser.add_argument('--user', default='user_test_001',
                       help='测试用户ID')
    parser.add_argument('--api-key', default=None,
                       help='API认证密钥')
    parser.add_argument('--output', '-o', default='achievement_test_report.json',
                       help='报告输出文件')
    
    args = parser.parse_args()
    
    # 创建测试器
    tester = AchievementTriggerTester(env=args.env, api_key=args.api_key)
    
    # 运行测试
    report = tester.run_all_tests(args.user)
    
    # 保存报告
    with open(args.output, 'w', encoding='utf-8') as f:
        json.dump(report, f, ensure_ascii=False, indent=2)
    
    print(f"\n📄 报告已保存: {args.output}")
    
    # 返回退出码
    sys.exit(0 if report['failed'] == 0 else 1)


if __name__ == '__main__':
    main()
