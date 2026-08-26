# DevOps SRE Lab

![Status](https://img.shields.io/badge/status-em%20desenvolvimento-yellow)
![Fase](https://img.shields.io/badge/fase-4%20deploy-blue)
![Python](https://img.shields.io/badge/Python-3.13-blue)
![FastAPI](https://img.shields.io/badge/FastAPI-API-green)
![Docker](https://img.shields.io/badge/Docker-container-blue)
![CI](https://img.shields.io/badge/GitHub%20Actions-CI-black)
![Registry](https://img.shields.io/badge/GHCR-registry-blue)

Laboratório prático para desenvolver competências de **DevOps e SRE** usando uma aplicação real, testes automatizados, containerização, integração contínua, publicação de artefatos, deploy reproduzível, validação operacional e rollback.

## Objetivo

Construir e evoluir um fluxo próximo ao utilizado em ambientes reais:

```text
Código
  ↓
Pull Request
  ↓
Testes e validações
  ↓
Imagem Docker versionada
  ↓
Container Registry
  ↓
Deploy em servidor Linux
  ↓
Health e readiness checks
  ↓
CD automatizado
  ↓
Observabilidade e operação
```

O foco não é apenas desenvolver a API. O projeto também exercita como entregar, executar, validar, proteger, monitorar e recuperar um serviço.

## Estado atual

A aplicação possui dois endpoints operacionais:

- `GET /health`
- `GET /ready`

Exemplo de resposta:

```json
{
  "status": "healthy",
  "service": "devops-sre-lab",
  "version": "1.0.0"
}
```

O pipeline de CI atualmente:

- instala as dependências Python;
- executa os testes com `pytest`;
- valida a sintaxe de `scripts/deploy.sh` com `bash -n`;
- valida o `docker-compose.yml` com uma tag de teste;
- constrói a imagem Docker;
- inicia o container e valida o endpoint `/health`;
- publica a imagem no GHCR após push na `main`;
- publica as tags do SHA completo do commit e `latest`.

O primeiro servidor Linux do laboratório já foi provisionado no Proxmox:

```text
app01
├─ Ubuntu Server 26.04.1 LTS
├─ IP: 192.168.1.110/24
├─ Docker Engine
├─ Docker Compose plugin
├─ QEMU Guest Agent
└─ aplicação publicada na porta 8000
```

O primeiro deploy real usando uma imagem versionada pelo SHA do commit foi executado com sucesso na `app01`. Os endpoints `/health` e `/ready` foram validados a partir de outro host da rede com HTTP 200.

## Arquitetura implementada

```text
Desenvolvedor
     │
     ▼
GitHub Repository
     │
     ▼
Pull Request
     │
     ▼
GitHub-hosted runner
  ├─ pytest
  ├─ bash -n scripts/deploy.sh
  ├─ docker compose config
  ├─ docker build
  ├─ smoke test do container
  └─ push SHA + latest
     │
     ▼
GitHub Container Registry
     │
     ▼
Imagem versionada
     │
     ▼
app01 — Ubuntu Server
  ├─ Docker Compose
  ├─ wrapper privilegiado de deploy
  ├─ /health
  └─ /ready
```

A imagem testada pelo pipeline é a mesma imagem posteriormente etiquetada, publicada no registry e utilizada no servidor.

## Segurança do deploy no servidor

Na `app01`, o usuário de automação não possui acesso direto ao socket Docker.

O modelo atual é:

```text
deploy
  │
  └─ sudo restrito
       │
       ▼
/usr/local/sbin/deploy-app
       │
       ├─ valida SHA completo de 40 caracteres
       ├─ executa Docker Compose como root
       ├─ valida /health e /ready
       └─ realiza rollback quando necessário
```

Controles aplicados:

- usuário `deploy` fora do grupo `docker`;
- diretório `/opt/devops-sre-lab` pertencente a `root:deploy` e modo `750`;
- `docker-compose.yml` pertencente a `root:deploy` e modo `640`;
- wrapper `/usr/local/sbin/deploy-app` pertencente a `root:deploy` e modo `750`;
- regra dedicada no `sudoers` liberando somente o wrapper;
- execução não interativa com `NOPASSWD` somente para o comando autorizado;
- tag de deploy restrita ao SHA completo do commit.

Durante o primeiro teste foi identificado um problema real no wrapper: o Compose era consultado antes da variável `IMAGE_TAG` ser exportada. A ordem foi corrigida e o deploy passou a funcionar normalmente.

A proposta detalhada está em [`docs/secure-deployment.md`](docs/secure-deployment.md).

## O que já foi implementado

### Aplicação e testes

- [x] API criada com FastAPI
- [x] Endpoint de health check
- [x] Endpoint de readiness check
- [x] Testes automatizados com pytest

### Git e colaboração

- [x] Controle de versão com Git
- [x] Repositório no GitHub
- [x] Desenvolvimento por branches
- [x] Pull Requests antes do merge na `main`
- [x] Exclusão das branches após o merge
- [x] Documentação do fluxo de trabalho Git

### Containerização

- [x] Dockerfile com Python 3.13 slim
- [x] Arquivo `.dockerignore`
- [x] Build local da imagem
- [x] Execução local do container
- [x] Smoke test da API empacotada

### Integração contínua e registry

- [x] Pipeline de CI com GitHub Actions
- [x] Testes em Pull Requests e pushes na `main`
- [x] Validação da sintaxe do script de deploy
- [x] Validação do Docker Compose no CI
- [x] Build automático da imagem Docker
- [x] Smoke test do container no pipeline
- [x] Publicação da imagem no GitHub Container Registry
- [x] Tags de imagem com SHA completo do commit
- [x] Tag adicional `latest`
- [x] Build único seguido por teste, tag e publicação do mesmo artefato

### Deploy em servidor Linux

- [x] Provisionar a VM `app01`
- [x] Configurar IP fixo
- [x] Instalar QEMU Guest Agent
- [x] Instalar Docker Engine
- [x] Instalar Docker Compose plugin
- [x] Manter o usuário `deploy` fora do grupo `docker`
- [x] Criar diretório protegido da aplicação
- [x] Instalar Compose protegido contra escrita pelo usuário de automação
- [x] Criar wrapper privilegiado de deploy
- [x] Restringir o wrapper a SHA completo de commit
- [x] Configurar regra mínima no `sudoers`
- [x] Executar primeiro deploy real a partir do GHCR
- [x] Validar `/health` externamente
- [x] Validar `/ready` externamente

## Próximo marco

### Automatizar o CD com runner dedicado

- [ ] Provisionar a VM `runner01`
- [ ] Instalar e registrar o self-hosted runner
- [ ] Configurar conectividade entre `runner01` e `app01`
- [ ] Configurar autenticação remota segura
- [ ] Criar o workflow de CD após merge na `main`
- [ ] Fazer o workflow enviar o SHA aprovado para a `app01`
- [ ] Validar o deploy automático ponta a ponta
- [ ] Testar rollback entre duas imagens realmente diferentes

## Roadmap

### Fase 1 — Aplicação e testes — concluída

- [x] Criar API
- [x] Criar health check
- [x] Criar readiness check
- [x] Adicionar testes automatizados

### Fase 2 — Containerização — concluída

- [x] Criar Dockerfile
- [x] Criar `.dockerignore`
- [x] Construir imagem
- [x] Executar container localmente
- [x] Validar aplicação empacotada

### Fase 3 — Integração contínua — concluída

- [x] Executar testes em Pull Requests
- [x] Validar os arquivos de deploy no CI
- [x] Construir imagem no CI
- [x] Realizar smoke test
- [x] Publicar imagem no GHCR
- [x] Versionar imagem pelo SHA do commit

### Fase 4 — Deploy com Docker Compose — em andamento

- [x] Criar arquivo Compose
- [x] Definir imagem, porta e restart policy
- [x] Validar execução local
- [x] Tornar a tag da imagem configurável
- [x] Criar script de deploy portátil
- [x] Validar health e readiness com retry
- [x] Implementar rollback automático
- [x] Testar a lógica de rollback localmente
- [x] Validar Compose e script no CI
- [x] Implantar em servidor Linux
- [x] Executar deploy manual controlado por SHA
- [ ] Automatizar a atualização remota da aplicação
- [ ] Testar rollback real entre duas versões distintas

### Fase 5 — Configuração e persistência

- [x] Introduzir variável de ambiente para a tag da imagem
- [x] Criar arquivo `.env.example`
- [ ] Gerenciar secrets de deploy
- [ ] Adicionar banco de dados PostgreSQL
- [ ] Criar volumes persistentes
- [ ] Implementar migrações de banco

### Fase 6 — Observabilidade

- [ ] Logs estruturados
- [ ] Métricas da aplicação
- [ ] Prometheus
- [ ] Grafana
- [ ] Alertas
- [ ] Dashboards de disponibilidade e latência

### Fase 7 — Práticas SRE

- [ ] Definir SLI
- [ ] Definir SLO
- [ ] Definir orçamento de erro
- [ ] Criar runbooks
- [ ] Simular incidentes
- [ ] Testar recuperação e rollback entre versões diferentes
- [ ] Documentar post-mortem

### Fase 8 — Infraestrutura como código e evolução

- [ ] Provisionar infraestrutura com Terraform
- [ ] Automatizar a configuração do servidor
- [ ] Adicionar ambiente de homologação
- [ ] Implementar estratégia de releases
- [ ] Avaliar migração futura para Kubernetes

## Estrutura do projeto

```text
.
├── .github/
│   └── workflows/
│       └── tests.yml
├── docs/
│   ├── git-workflow.md
│   └── secure-deployment.md
├── scripts/
│   └── deploy.sh
├── tests/
│   └── test_health.py
├── .dockerignore
├── .env.example
├── .gitignore
├── docker-compose.yml
├── Dockerfile
├── main.py
├── requirements.txt
└── README.md
```

## Executar localmente com Docker Compose

### 1. Criar o arquivo local de ambiente

```bash
cp .env.example .env
```

Edite o `.env` e informe uma tag existente no GHCR:

```env
IMAGE_TAG=<sha-completo-do-commit>
```

O arquivo `.env` não é versionado.

### 2. Validar a configuração

```bash
docker compose config
```

Sem uma `IMAGE_TAG`, o Compose interrompe a execução:

```text
required variable IMAGE_TAG is missing a value: IMAGE_TAG não definida
```

### 3. Executar o deploy local

```bash
./scripts/deploy.sh
```

Fluxo executado:

```text
validar Compose
→ identificar versão anterior
→ baixar imagem
→ atualizar container
→ aguardar /health
→ aguardar /ready
→ aprovar deploy ou executar rollback
```

## Deploy controlado na app01

O servidor utiliza um wrapper protegido:

```bash
sudo -n /usr/local/sbin/deploy-app <sha-completo-do-commit>
```

O wrapper aceita somente um SHA hexadecimal completo de 40 caracteres.

Fluxo:

```text
validar SHA
→ definir IMAGE_TAG
→ identificar versão anterior
→ validar Compose
→ baixar imagem do GHCR
→ atualizar container
→ validar /health e /ready
→ concluir ou executar rollback
```

## Como funciona o rollback atual

Antes de atualizar o container, o wrapper identifica a imagem em execução e extrai sua tag.

Caso `/health` ou `/ready` não responda após as tentativas configuradas:

```text
validação falha
→ IMAGE_TAG recebe PREVIOUS_TAG
→ docker compose pull
→ docker compose up -d
→ /health e /ready são validados novamente
```

A lógica de rollback já foi testada localmente. O próximo teste será entre duas imagens realmente diferentes no servidor Linux.

## Fluxo de trabalho Git

O processo de criação de branches, commits, Pull Requests, validação e limpeza está documentado em [`docs/git-workflow.md`](docs/git-workflow.md).

## Conceitos praticados

- Git, branches e Pull Requests
- Integração contínua
- Fundamentos de entrega contínua
- Testes automatizados
- Docker e Docker Compose
- Container Registry
- Versionamento de artefatos
- Tags e digests de imagens
- Health e readiness checks
- Restart policy
- Variáveis de ambiente
- Scripts Bash e strict mode
- Retry e idempotência
- Deploy reproduzível
- Rollback
- Permissões Linux
- Princípio do menor privilégio
- Segurança de automações
- Sudoers com comando restrito
- Deploy por artefato imutável identificado por SHA

## Resultado esperado

Ao final, o projeto deverá demonstrar um fluxo completo de entrega e operação:

```text
Desenvolvimento
    ↓
Pull Request
    ↓
Testes automatizados
    ↓
Build da imagem
    ↓
Publicação no registry
    ↓
Deploy automatizado
    ↓
Monitoramento
    ↓
Alertas e resposta a incidentes
```

Este repositório também funciona como registro público da evolução prática em **DevOps e SRE**.
