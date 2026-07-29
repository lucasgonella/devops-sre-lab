# DevOps SRE Lab

![Status](https://img.shields.io/badge/status-em%20desenvolvimento-yellow)
![Progresso](https://img.shields.io/badge/progresso-50%25-blue)
![Python](https://img.shields.io/badge/Python-3.13-blue)
![FastAPI](https://img.shields.io/badge/FastAPI-API-green)
![Docker](https://img.shields.io/badge/Docker-container-blue)
![CI](https://img.shields.io/badge/GitHub%20Actions-CI-black)
![Registry](https://img.shields.io/badge/GHCR-registry-blue)

Laboratório prático para desenvolver competências de **DevOps e SRE** usando uma aplicação real, containerização, integração contínua, publicação de artefatos, deploy reproduzível e recuperação automática após falha de validação.

## Objetivo

Construir uma aplicação pequena, mas com um fluxo próximo ao usado em ambientes reais:

```text
Código → testes → imagem Docker → registry → deploy → validação → observabilidade → operação
```

O objetivo principal não é apenas desenvolver a API, mas aprender a entregar, executar, monitorar e recuperar o serviço de forma segura e reproduzível.

## Estado atual

**Progresso estimado: 50%**

> O percentual representa o avanço do laboratório planejado e será atualizado conforme novas etapas forem concluídas.

A aplicação possui endpoints básicos de saúde e prontidão:

- `GET /health`
- `GET /ready`

Respostas atuais:

```json
{
  "status": "healthy",
  "service": "devops-sre-lab",
  "version": "1.0.0"
}
```

```json
{
  "status": "ready",
  "service": "devops-sre-lab",
  "version": "1.0.0"
}
```

O pipeline de CI testa a aplicação, constrói a imagem Docker, executa um smoke test e publica imagens no GitHub Container Registry.

O projeto também possui um script Bash de deploy que:

- valida o arquivo Compose;
- identifica a versão atualmente em execução;
- baixa a imagem definida por `IMAGE_TAG`;
- cria ou atualiza o container;
- aguarda os endpoints `/health` e `/ready` com tentativas automáticas;
- executa rollback para a tag anterior quando a validação falha;
- pode ser chamado de qualquer diretório.

O deploy foi validado localmente. A implantação em uma VM Linux no homelab ainda será realizada.

## Arquitetura atual

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
GitHub Actions
  ├─ instala dependências
  ├─ executa pytest
  ├─ constrói a imagem Docker
  ├─ inicia o container
  ├─ valida /health
  └─ publica SHA + latest no GHCR
     │
     ▼
GitHub Container Registry
     │
     ▼
Docker Compose + scripts/deploy.sh
  ├─ resolve IMAGE_TAG
  ├─ executa pull
  ├─ executa up -d
  ├─ valida /health e /ready
  └─ realiza rollback em caso de falha
     │
     ▼
Servidor Linux
  └─ próximo ambiente: VM no Proxmox/homelab
```

A definição de deploy não depende do Proxmox. O mesmo Compose e o mesmo script poderão ser utilizados futuramente em uma VM na AWS, Azure ou outra nuvem com Docker instalado.

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

### Containerização

- [x] Dockerfile com Python 3.13 slim
- [x] Arquivo `.dockerignore`
- [x] Build local da imagem
- [x] Execução local do container
- [x] Smoke test da API empacotada

### Integração contínua e registry

- [x] Pipeline de CI com GitHub Actions
- [x] Testes em Pull Requests e pushes na `main`
- [x] Build automático da imagem Docker
- [x] Smoke test do container no pipeline
- [x] Publicação da imagem no GitHub Container Registry
- [x] Tags de imagem com SHA completo do commit
- [x] Tag adicional `latest`
- [x] Build único seguido por teste, tag e publicação do mesmo artefato

### Docker Compose e deploy

- [x] Arquivo `docker-compose.yml`
- [x] Mapeamento de porta `8000:8000`
- [x] Política de reinício `unless-stopped`
- [x] Teste de recuperação após falha do processo principal
- [x] Uso obrigatório da variável `IMAGE_TAG`
- [x] Bloqueio do deploy quando `IMAGE_TAG` não está definida
- [x] Arquivo `.env.example`
- [x] Proteção do arquivo `.env` no `.gitignore`
- [x] Script portátil `scripts/deploy.sh`
- [x] Validação do Compose antes do deploy
- [x] Download da imagem com `docker compose pull`
- [x] Atualização idempotente com `docker compose up -d`
- [x] Retry automático para `/health` e `/ready`
- [x] Captura da tag anteriormente executada
- [x] Rollback automático após falha de validação
- [x] Teste controlado da lógica de rollback
- [x] Execução do script a partir de outro diretório

## Próximo passo

### Validar os arquivos de deploy no CI

O próximo marco é fazer o GitHub Actions validar também os arquivos que controlam o deploy.

Validações planejadas:

```text
Pull Request
    ↓
bash -n scripts/deploy.sh
    ↓
IMAGE_TAG=<tag-de-teste> docker compose config
    ↓
testes, build e smoke test atuais
```

Objetivos imediatos:

- [ ] Validar a sintaxe do `scripts/deploy.sh` no CI
- [ ] Validar o `docker-compose.yml` no CI
- [ ] Criar o documento `docs/git-workflow.md`
- [ ] Provisionar uma VM Ubuntu Server no Proxmox
- [ ] Instalar Docker e Docker Compose na VM
- [ ] Configurar acesso remoto seguro ao homelab
- [ ] Executar o primeiro deploy no servidor Linux
- [ ] Automatizar o deploy após merge na `main`
- [ ] Armazenar IP, usuário e chave SSH em GitHub Secrets

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

### Fase 4 — Deploy com Docker Compose — 75%

- [x] Criar arquivo Compose
- [x] Definir imagem, porta e restart policy
- [x] Validar execução local
- [x] Testar reinício após falha da aplicação
- [x] Tornar a tag da imagem configurável
- [x] Criar script de deploy portátil
- [x] Validar health e readiness com retry
- [x] Implementar rollback automático
- [x] Testar a lógica de rollback localmente
- [ ] Validar Compose e script no CI
- [ ] Implantar em servidor Linux
- [ ] Automatizar a atualização remota da aplicação

### Fase 5 — Configuração e persistência — 25%

- [x] Introduzir variável de ambiente para a tag da imagem
- [x] Criar arquivo `.env.example`
- [ ] Gerenciar secrets de deploy
- [ ] Adicionar banco de dados PostgreSQL
- [ ] Criar volumes persistentes
- [ ] Implementar migrações de banco

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
- [ ] Testar recuperação e rollback entre versões diferentes
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

### 3. Executar o deploy automatizado

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

### 4. Consultar o ambiente

Visualizar os containers:

```bash
docker compose ps
```

Visualizar logs:

```bash
docker compose logs -f api
```

Validar manualmente:

```bash
curl http://localhost:8000/health
curl http://localhost:8000/ready
```

Encerrar o ambiente:

```bash
docker compose down
```

## Como funciona o rollback atual

Antes de atualizar o container, o script identifica a imagem em execução e extrai sua tag.

```text
container atual
→ referência da imagem
→ PREVIOUS_TAG
```

Caso `/health` ou `/ready` não responda após 15 tentativas:

```text
validação falha
→ IMAGE_TAG recebe PREVIOUS_TAG
→ docker compose pull
→ docker compose up -d
→ /health e /ready são validados novamente
```

No primeiro deploy não existe uma versão anterior, portanto o rollback ainda não está disponível.

A lógica foi testada localmente com uma rota inexistente. O teste entre duas imagens realmente diferentes será realizado em uma etapa futura.

## Conceitos praticados

- Git e GitHub
- Branches e Pull Requests
- Integração contínua
- Fundamentos de entrega contínua
- Testes automatizados
- Docker
- Docker Compose
- Container Registry
- Versionamento de artefatos
- Tags e digests de imagens
- Health checks
- Readiness checks
- Restart policy
- Variáveis de ambiente
- Scripts Bash
- Strict mode do Bash
- Retry
- Idempotência
- Deploy reproduzível
- Rollback
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
