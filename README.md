# DevOps SRE Lab

![Status](https://img.shields.io/badge/status-em%20desenvolvimento-yellow)
![Fase](https://img.shields.io/badge/fase-4%20deploy-blue)
![Python](https://img.shields.io/badge/Python-3.13-blue)
![FastAPI](https://img.shields.io/badge/FastAPI-API-green)
![Docker](https://img.shields.io/badge/Docker-container-blue)
![CI](https://img.shields.io/badge/GitHub%20Actions-CI-black)
![Registry](https://img.shields.io/badge/GHCR-registry-blue)

Laboratório prático para desenvolver competências de **DevOps e SRE** usando uma aplicação real, testes automatizados, containerização, integração contínua, publicação de artefatos, deploy reproduzível e rollback.

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
Deploy
  ↓
Health e readiness checks
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

O script `scripts/deploy.sh`:

- pode ser executado a partir de qualquer diretório;
- valida a configuração do Docker Compose;
- identifica a tag atualmente em execução;
- baixa a imagem definida por `IMAGE_TAG`;
- atualiza o serviço de forma idempotente;
- aguarda `/health` e `/ready` com retry;
- executa rollback para a tag anterior quando a validação falha.

O fluxo foi validado localmente. O deploy em um servidor Linux e a automação de CD ainda não foram implementados.

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
Imagem pronta para deploy
```

A imagem testada pelo pipeline é a mesma imagem posteriormente etiquetada e publicada no registry.

## Arquitetura planejada para o CD

O próximo marco é realizar o primeiro deploy seguro no homelab.

```text
GitHub
  │
  ├─ CI em runner hospedado pelo GitHub
  │
  └─ CD em self-hosted runner dedicado
              │
              │ rede privada
              ▼
        Servidor da aplicação
              │
              ├─ usuário deploy
              ├─ sudo restrito a um comando
              ├─ script privilegiado protegido
              └─ Docker Compose + validação + rollback
```

Controles planejados:

- executar o self-hosted runner em uma VM separada do servidor da aplicação;
- utilizar conectividade privada entre as VMs;
- usar um usuário dedicado chamado `deploy`;
- não conceder shell irrestrito de `root` ao usuário de automação;
- liberar no `sudoers` somente o comando exato de deploy;
- manter o script privilegiado, o Compose e seus diretórios protegidos contra escrita pelo usuário `deploy`;
- usar caminhos absolutos e argumentos controlados no script privilegiado;
- manter secrets fora do repositório.

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

### Docker Compose e deploy local

- [x] Arquivo `docker-compose.yml`
- [x] Mapeamento de porta `8000:8000`
- [x] Política de reinício `unless-stopped`
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

## Próximo marco

### Primeiro CD seguro no homelab

- [ ] Provisionar uma VM para o self-hosted runner
- [ ] Provisionar uma VM separada para a aplicação
- [ ] Instalar Docker e Docker Compose no servidor da aplicação
- [ ] Configurar conectividade privada entre as VMs
- [ ] Criar o usuário de automação `deploy`
- [ ] Instalar o script privilegiado de deploy como arquivo pertencente ao `root`
- [ ] Proteger o Compose e os diretórios utilizados pelo script
- [ ] Configurar uma regra mínima no `sudoers`
- [ ] Criar o workflow de CD após merge na `main`
- [ ] Executar o primeiro deploy remoto
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
- [ ] Implantar em servidor Linux
- [ ] Automatizar a atualização remota da aplicação

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

### 4. Consultar o ambiente

```bash
docker compose ps
docker compose logs -f api
curl http://localhost:8000/health
curl http://localhost:8000/ready
```

Para encerrar:

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

A lógica foi testada localmente com uma rota inexistente. O teste entre duas imagens realmente diferentes permanece como próximo passo.

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
