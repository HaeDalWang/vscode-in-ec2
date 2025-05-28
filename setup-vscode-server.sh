#!/bin/bash

# VS Code Server 설치 스크립트
# Ubuntu 22.04용
# 사용법: sudo ./setup-vscode-server.sh [PASSWORD]

# 에러 발생 시에도 계속 진행하도록 변경
set +e  # 에러 발생 시 스크립트 중단하지 않음

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 로그 함수
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 명령어 실행 및 에러 처리 함수
run_command() {
    local cmd="$1"
    local description="$2"
    
    log_info "$description"
    if eval "$cmd"; then
        log_success "$description 완료"
        return 0
    else
        log_error "$description 실패 (계속 진행)"
        return 1
    fi
}

# 파라미터 설정
VSCODE_PASSWORD=${1:-"vscode123!"}  # 기본 비밀번호
UBUNTU_USER="ubuntu"

log_info "VS Code Server 설치를 시작합니다..."
log_info "비밀번호: $VSCODE_PASSWORD"

# 루트 권한 확인
if [[ $EUID -ne 0 ]]; then
   log_error "이 스크립트는 root 권한으로 실행해야 합니다."
   exit 1
fi

# 시스템 업데이트
export DEBIAN_FRONTEND=noninteractive
run_command "apt update -y" "시스템 업데이트"

# 기본 패키지 설치
run_command "apt install -y curl wget git docker.io unzip build-essential" "기본 패키지 설치"

# Node.js 설치 (code-server 필요)
run_command "curl -fsSL https://deb.nodesource.com/setup_18.x | bash -" "Node.js 저장소 추가"
run_command "apt install -y nodejs" "Node.js 설치"

# code-server 설치
run_command "curl -fsSL https://code-server.dev/install.sh | sh" "code-server 설치"

# student 사용자 생성 및 권한 설정
log_info "사용자 '$UBUNTU_USER' 생성 및 권한 설정 중..."
if ! id "$UBUNTU_USER" &>/dev/null; then
    run_command "useradd -m -s /bin/bash $UBUNTU_USER" "사용자 생성"
else
    log_warning "사용자 '$UBUNTU_USER'가 이미 존재합니다."
fi

run_command "usermod -aG sudo $UBUNTU_USER" "sudo 그룹 추가"
run_command "usermod -aG docker $UBUNTU_USER" "docker 그룹 추가"
run_command "mkdir -p /home/$UBUNTU_USER/.config/code-server" "code-server 설정 디렉토리 생성"

# code-server 설정
log_info "code-server 설정 중..."
cat > /home/$UBUNTU_USER/.config/code-server/config.yaml << EOF
bind-addr: 0.0.0.0:8080
auth: password
password: $VSCODE_PASSWORD
cert: false
EOF

# 소유권 설정
chown -R $UBUNTU_USER:$UBUNTU_USER /home/$UBUNTU_USER/.config

# systemd 서비스 생성
log_info "systemd 서비스 생성 중..."
cat > /etc/systemd/system/code-server.service << EOF
[Unit]
Description=code-server
After=network.target

[Service]
Type=simple
User=$UBUNTU_USER
WorkingDirectory=/home/$UBUNTU_USER
ExecStart=/usr/bin/code-server
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Docker 활성화 및 시작
run_command "systemctl enable docker" "Docker 서비스 활성화"
run_command "systemctl start docker" "Docker 서비스 시작"

# code-server 활성화 및 시작
run_command "systemctl daemon-reload" "systemd 데몬 리로드"
run_command "systemctl enable code-server" "code-server 서비스 활성화"
run_command "systemctl start code-server" "code-server 서비스 시작"

# 개발 도구 설치
run_command "apt install -y python3 python3-pip vim nano htop tree" "추가 개발 도구 설치"

# AWS 관련 도구 설치
log_info "AWS CLI v2 설치 중..."
if run_command "curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o 'awscliv2.zip'" "AWS CLI 다운로드"; then
    run_command "unzip awscliv2.zip" "AWS CLI 압축 해제"
    run_command "./aws/install" "AWS CLI 설치"
    run_command "rm -rf aws awscliv2.zip" "AWS CLI 임시 파일 정리"
fi

run_command "npm install -g aws-cdk" "AWS CDK 설치"

# AWS SAM CLI 설치
log_info "AWS SAM CLI 설치 중..."
curl -LO https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip
unzip aws-sam-cli-linux-x86_64.zip -d sam-installation
./sam-installation/install
rm -rf sam-installation aws-sam-cli-linux-x86_64.zip

# kubectl 최신 버전 설치
log_info "kubectl 설치 중..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/

# Helm 최신 버전 설치
log_info "Helm 설치 중..."
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Kubernetes 관련 도구 설치
log_info "Kubernetes 관련 도구 설치 중..."
# kubectx, kubens 설치
curl -LO https://github.com/ahmetb/kubectx/releases/latest/download/kubectx
curl -LO https://github.com/ahmetb/kubectx/releases/latest/download/kubens
chmod +x kubectx kubens
mv kubectx kubens /usr/local/bin/

# k9s 설치 (Kubernetes 클러스터 관리 도구)
log_info "k9s 설치 중..."
K9S_VER=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep tag_name | cut -d '"' -f 4)
curl -LO "https://github.com/derailed/k9s/releases/download/${K9S_VER}/k9s_Linux_amd64.tar.gz"
tar -xzf k9s_Linux_amd64.tar.gz
mv k9s /usr/local/bin/
rm k9s_Linux_amd64.tar.gz

# Istio CLI 설치
log_info "Istio CLI 설치 중..."
curl -L https://istio.io/downloadIstio | sh -
mv istio-*/bin/istioctl /usr/local/bin/
rm -rf istio-*

# aws-runas 설치
log_info "aws-runas 설치 중..."
AWS_RUNAS_VER=$(curl -s https://api.github.com/repos/mmmorris1975/aws-runas/releases/latest | grep tag_name | cut -d '"' -f 4)
curl -LO "https://github.com/mmmorris1975/aws-runas/releases/download/${AWS_RUNAS_VER}/aws-runas-${AWS_RUNAS_VER}-linux-amd64.zip"
unzip "aws-runas-${AWS_RUNAS_VER}-linux-amd64.zip"
mv aws-runas /usr/local/bin/
rm "aws-runas-${AWS_RUNAS_VER}-linux-amd64.zip"

# JSON/YAML 파서 설치
log_info "JSON/YAML 파서 설치 중..."
run_command "apt install -y jq" "jq 설치"

# yq 최신 버전 설치
YQ_VER=$(curl -s https://api.github.com/repos/mikefarah/yq/releases/latest | grep tag_name | cut -d '"' -f 4)
curl -LO "https://github.com/mikefarah/yq/releases/download/${YQ_VER}/yq_linux_amd64"
chmod +x yq_linux_amd64
mv yq_linux_amd64 /usr/local/bin/yq

# 컨테이너 관련 도구
log_info "Docker Compose 설치 중..."
DOCKER_COMPOSE_VER=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)
curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VER}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# AWS 및 클라우드 관련 Python 패키지 설치
log_info "Python 패키지 설치 중..."
pip3 install boto3 botocore requests kubernetes docker-py awscli-cwlogs
pip3 install ansible ansible-lint
pip3 install pyyaml jsonschema
pip3 install awscli-plugin-endpoint

# Git 설정 및 유용한 도구들
log_info "Git 설정 중..."
git config --global init.defaultBranch main

# Starship 프롬프트 설치 (터미널 꾸미기)
log_info "Starship 프롬프트 설치 중..."
curl -sS https://starship.rs/install.sh | sh -s -- -y

# student 사용자 환경 설정
log_info "사용자 환경 설정 중..."
su - $UBUNTU_USER -c "
echo 'export PATH=/usr/local/bin:\$PATH' >> ~/.bashrc
echo 'eval \"\$(starship init bash)\"' >> ~/.bashrc
echo 'alias k=kubectl' >> ~/.bashrc
echo 'alias ll=\"ls -la\"' >> ~/.bashrc
echo 'alias la=\"ls -A\"' >> ~/.bashrc
echo 'alias l=\"ls -CF\"' >> ~/.bashrc
echo 'complete -F __start_kubectl k' >> ~/.bashrc
"

# 권한 설정
chown -R $UBUNTU_USER:$UBUNTU_USER /home/$UBUNTU_USER

# 서비스 상태 확인
log_info "서비스 상태 확인 중..."
sleep 5

if systemctl is-active --quiet code-server; then
    log_success "code-server 서비스가 정상적으로 실행 중입니다."
else
    log_error "code-server 서비스 시작에 실패했습니다."
    systemctl status code-server
fi

if systemctl is-active --quiet docker; then
    log_success "Docker 서비스가 정상적으로 실행 중입니다."
else
    log_error "Docker 서비스 시작에 실패했습니다."
fi

# 설치 완료 정보 출력
log_success "=== VS Code Server 설치 완료! ==="
echo ""
log_info "접속 정보:"
echo "  - URL: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo 'YOUR_PUBLIC_IP'):8080"
echo "  - 사용자: $UBUNTU_USER"
echo "  - 비밀번호: $VSCODE_PASSWORD"
echo ""
log_info "설치된 도구들:"
echo "  - VS Code Server"
echo "  - Docker & Docker Compose"
echo "  - AWS CLI v2, CDK, SAM CLI"
echo "  - kubectl, Helm, k9s, kubectx/kubens"
echo "  - Istio CLI, aws-runas"
echo "  - jq, yq"
echo "  - Python 개발 패키지들"
echo "  - Starship 프롬프트"
echo ""
log_info "서비스 관리 명령어:"
echo "  - 상태 확인: sudo systemctl status code-server"
echo "  - 재시작: sudo systemctl restart code-server"
echo "  - 로그 확인: sudo journalctl -u code-server -f"
echo ""
log_success "설치가 완료되었습니다! 🎉" 