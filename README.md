# AWS DevOps 학습 환경 - VS Code Server
EC2에서 실행되는 완전한 DevOps 학습 환경입니다.

## 🚀 빠른 시작

1. 아래 버튼을 클릭하여 배포를 시작하세요:

<a href="https://console.aws.amazon.com/cloudformation/home?region=ap-northeast-2#/stacks/create/review?templateURL=https://seungdobae-cloudformations.s3.ap-northeast-2.amazonaws.com/cloudformation.yaml&stackName=VSCode-Server-Stack&param_InstanceType=t3.medium&param_VolumeSize=20" target="_blank">
  <img src="https://img.shields.io/badge/Deploy%20to-AWS-orange?style=for-the-badge&logo=amazon-aws" alt="Deploy to AWS">
</a>

2. 필수 파라미터를 입력하세요:
   - **KeyPairName**: 기존 EC2 키페어 선택
   - **VsCodePassword**: VS Code 접속 비밀번호 (8자 이상)

3. 스택 생성 후 Outputs 탭에서 VS Code URL을 확인하세요

4. 브라우저에서 해당 URL로 접속하여 학습을 시작하세요!

## 🖥️ 시스템 정보
- **OS**: Ubuntu 22.04 LTS (Jammy Jellyfish)
- **AMI**: ami-0f3a440bbcff3d043
- **리전**: 서울 리전(ap-northeast-2) 전용
- **기본 사용자**: ubuntu

**주의사항:**
- 서울 리전(ap-northeast-2)에서만 작동합니다
- 키페어를 미리 생성해두세요
- 비밀번호는 8자 이상으로 설정하세요
- 인스턴스 생성 후 약 20-25분 정도 기다리세요

## 🛠️ 설치된 도구들

### AWS 도구
- **AWS CLI v2** - AWS 서비스 관리
- **AWS CDK** - Infrastructure as Code
- **aws-runas** - AWS 역할 전환

### Kubernetes 도구
- **kubectl** - Kubernetes 클러스터 관리
- **Helm** - Kubernetes 패키지 매니저
- **krew** - kubectl 플러그인 매니저
- **kubectx/kubens** - 컨텍스트/네임스페이스 전환 (`kubectl ctx`, `kubectl ns`)
- **kubecolor** - kubectl 출력 색상화
- **kube-ps1** - 터미널 프롬프트에 K8s 정보 표시

### Infrastructure & DevOps
- **Terraform** - Infrastructure as Code
- **Docker** - 컨테이너 플랫폼
- **Git** - 버전 관리

### 개발 도구
- **Node.js 18** - JavaScript 런타임
- **Python 3** - 프로그래밍 언어
- **jq** - JSON 프로세서
- **Starship** - 터미널 프롬프트 꾸미기

### 편의 도구
- **VS Code Server** - 웹 기반 IDE
- **vim, nano** - 텍스트 에디터
- **htop, tree** - 시스템 모니터링

## 💡 사용 팁

### 터미널 별칭
```bash
k          # kubectl
kc         # kubecolor  
kctx       # kubectl ctx (컨텍스트 전환)
kns        # kubectl ns (네임스페이스 전환)
ll         # ls -la
```

### Kubernetes 컨텍스트 관리
```bash
# 컨텍스트 목록 보기
kubectl ctx

# 컨텍스트 전환
kubectl ctx my-cluster

# 네임스페이스 전환
kubectl ns my-namespace
```

### krew 플러그인 관리
```bash
# 사용 가능한 플러그인 검색
kubectl krew search

# 플러그인 설치
kubectl krew install tree
kubectl krew install neat
```

## 💰 비용 안내
- t3.medium 인스턴스: 시간당 약 $0.04 (서울 리전 기준)
- 사용하지 않을 때는 인스턴스를 중지하거나 스택을 삭제하세요

## 🔧 문제 해결
- 배포 실패 시 CloudFormation 이벤트 탭을 확인하세요
- VS Code 접속이 안 될 경우 10-15분 더 기다려보세요
- 보안 그룹에서 8080 포트가 열려있는지 확인하세요

## 📝 접속 정보
- **VS Code Server**: `http://PUBLIC_IP:8080`
- **SSH 접속**: `ssh -i your-key.pem ubuntu@PUBLIC_IP`
- **VS Code 사용자**: ubuntu
- **비밀번호**: 배포 시 설정한 비밀번호