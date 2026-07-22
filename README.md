# DevOps SRE Lab

![Status](https://img.shields.io/badge/status-em%20desenvolvimento-yellow)
![Progresso](https://img.shields.io/badge/progresso-35%25-blue)
![Python](https://img.shields.io/badge/Python-3.13-blue)
![FastAPI](https://img.shields.io/badge/FastAPI-API-green)
![Docker](https://img.shields.io/badge/Docker-container-blue)
![CI](https://img.shields.io/badge/GitHub%20Actions-CI-black)

Laboratório prático para desenvolver competências de **DevOps e SRE** usando uma aplicação real, containerização, integração contínua, publicação de artefatos e implantação automatizada.

## Objetivo

Construir uma aplicação pequena, mas com um fluxo próximo ao usado em ambientes reais:

```text
Código → testes → imagem Docker → registry → deploy → observabilidade → operação
```

O objetivo principal não é apenas desenvolver a API, mas aprender a entregar, executar, monitorar e recuperar o serviço de forma reproduzível.

## Estado atual

**Progresso estimado: 35%**

> O percentual representa o avanço do laboratório planejado e será atualizado conforme novas etapas forem concluídas.

A aplicação possui endpoints básicos de saúde e prontidão:

- `GET /health`
- `GET /ready`

Resposta atual:

```json
{
  "status": "healthy",
  "service": "devops-sre-lab",
  "version": "1.0.0"
}
```

## Arquitetura atual

```text
GitHub Repository
       │
       ▼
GitHub Actions
  ├─ executa pytest
  ├─ constrói a imagem Docker
  ├─ inicia o container
  ├─ valida /health
  └─ publica a imagem no GHCR
       │
       ▼
GitHub Container Registry
       │
       ▼
Docker Compose
  └─ define como a aplicação será executada
```

## O que já foi implementado

- [x] API criada com FastAPI
- [x] Endpoint de health check
- [x] Endpoint de readiness check
- [x] Testes automatizados com pytest
- [x] Controle de versão com Git
- [x] Fluxo de desenvolvimento por branches e Pull Requests
- [x] Pipeline de CI com GitHub Actions
- [x] Build automático da imagem Docker
- [x] Smoke test do container no pipeline
- [x] Publicação da imagem no GitHub Container Registry
- [x] Tags de imagem com SHA do commit e `latest`
- [x] Docker Compose com imagem versionada
- [x] Mapeamento da porta `8000`
- [x] Política de reinício `unless-stopped`
- [x] Teste de recuperação após falha do processo principal

## Próximo passo

### Implantar a aplicação em um servidor usando Docker Compose

O próximo marco é fazer o Compose deixar de ser apenas uma definição local e passar a controlar uma implantação real.

Fluxo planejado:

```text
Merge na main
    ↓
CI testa e publica a imagem no GHCR
    ↓
Servidor recebe a nova versão
    ↓
docker compose pull
    ↓
docker compose up -d
    ↓
Health check confirma o deploy
```

Objetivos dessa etapa:

- [ ] Preparar um servidor Linux para execução da aplicação
- [ ] Instalar Docker e Docker Compose
- [ ] Clonar ou disponibilizar o arquivo Compose no servidor
- [ ] Autenticar o servidor no GHCR, caso necessário
- [ ] Subir a aplicação com `docker compose up -d`
- [ ] Validar o endpoint `/health`
- [ ] Definir processo de atualização com `pull` e `up -d`
- [ ] Automatizar o deploy após merge na `main`
- [ ] Criar estratégia básica de rollback

## Roadmap

### Fase 1 — Aplicação e testes — 100%

- [x] Criar API
- [x] Criar health check
- [x] Criar readiness check
- [x] Adicionar testes automatizados

### Fase 2 — Containerização — 100%

- [x] Criar Dockerfile
- [x] Criar `.dockerignore`
- [x] Construir imagem
- [x] Executar container localmente
- [x] Validar aplicação empacotada

### Fase 3 — Integração contínua — 100%

- [x] Executar testes em Pull Requests
- [x] Construir imagem no CI
- [x] Realizar smoke test
- [x] Publicar imagem no GHCR
- [x] Versionar imagem pelo SHA do commit

### Fase 4 — Deploy com Docker Compose — 35%

- [x] Criar arquivo Compose
- [x] Definir imagem, porta e restart policy
- [x] Validar execução local
- [x] Testar reinício após falha da aplicação
- [ ] Validar o Compose no CI
- [ ] Implantar em servidor Linux
- [ ] Automatizar atualização da aplicação
- [ ] Implementar rollback

### Fase 5 — Configuração e persistência — 0%

- [ ] Variáveis de ambiente
- [ ] Arquivo `.env.example`
- [ ] Gerenciamento de secrets
- [ ] Banco de dados PostgreSQL
- [ ] Volumes persistentes
- [ ] Migrações de banco

### Fase 6 — Observabilidade — 0%

- [ ] Logs estruturados
- [ ] Métricas da aplicação
- [ ] Prometheus
- [ ] Grafana
- [ ] Alertas
- [ ] Dashboards de disponibilidade e latência

### Fase 7 — Práticas SRE — 0%

- [ ] Definir SLI
- [ ] Definir SLO
- [ ] Definir orçamento de erro
- [ ] Criar runbooks
- [ ] Simular incidentes
- [ ] Testar recuperação e rollback
- [ ] Documentar post-mortem

### Fase 8 — Infraestrutura como código e evolução — 0%

- [ ] Provisionar infraestrutura com Terraform
- [ ] Automatizar configuração do servidor
- [ ] Adicionar ambiente de homologação
- [ ] Implementar estratégia de releases
- [ ] Avaliar migração futura para Kubernetes

## Estrutura atual do projeto

```text
.
├── .github/
│   └── workflows/
│       └── tests.yml
├── tests/
│   └── test_health.py
├── .dockerignore
├── .gitignore
├── docker-compose.yml
├── Dockerfile
├── main.py
├── requirements.txt
└── README.md
```

## Executar localmente com Docker Compose

```bash
docker compose up -d
```

Validar a aplicação:

```bash
curl http://localhost:8000/health
```

Visualizar os containers:

```bash
docker compose ps
```

Visualizar logs:

```bash
docker compose logs -f api
```

Encerrar o ambiente:

```bash
docker compose down
```

## Conceitos praticados

- Git e GitHub
- Branches e Pull Requests
- CI/CD
- Testes automatizados
- Docker
- Docker Compose
- Container Registry
- Versionamento de artefatos
- Health checks
- Readiness checks
- Restart policy
- Deploy reproduzível
- Recuperação de serviço

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
