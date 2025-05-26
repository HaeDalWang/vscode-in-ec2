# AWS DevOps 학습 환경 - VS Code Server
EC2에서 실행되는 완전한 DevOps 학습 환경입니다.

**주의사항:**
- 서울 리전(ap-northeast-2)에서만 작동합니다
- 키페어를 미리 생성해두세요
- 비밀번호는 8자 이상으로 설정하세요
- 인스턴스 생성 후 약 20-25분 정도 기다리세요

## 설치된 도구들
- AWS CLI, CDK, SAM, Copilot
- Kubernetes (kubectl, helm, k9s, kubectx/kubens)
- Terraform, Terragrunt
- Docker, Docker Compose
- Ansible, Prometheus
- 그 외 다양한 개발 도구들

## 빠른 시작

1. 아래 버튼을 클릭하여 배포를 시작하세요:

[![Deploy to AWS](https://img.shields.io/badge/Deploy%20to-AWS-orange?style=for-the-badge&logo=amazon-aws)](https://console.aws.amazon.com/cloudformation/home?region=ap-northeast-2#/stacks/create/review?templateURL=https://raw.githubusercontent.com/HaeDalWang/vscode-in-ec2/refs/heads/main/cloudformation.yaml&stackName=VSCode-Server-Stack&param_InstanceType=t3.medium&param_VolumeSize=20
)

2. 필수 파라미터를 입력하세요:
   - **KeyPairName**: 기존 EC2 키페어 선택
   - **VsCodePassword**: VS Code 접속 비밀번호 (8자 이상)

3. 스택 생성 후 Outputs 탭에서 VS Code URL을 확인하세요

4. 브라우저에서 해당 URL로 접속하여 학습을 시작하세요!

## 비용 안내
- t3.medium 인스턴스: 시간당 약 $0.04 (서울 리전 기준)
- 사용하지 않을 때는 인스턴스를 중지하거나 스택을 삭제하세요

## 문제 해결
- 배포 실패 시 CloudFormation 이벤트 탭을 확인하세요
- VS Code 접속이 안 될 경우 10-15분 더 기다려보세요
- 보안 그룹에서 8080 포트가 열려있는지 확인하세요