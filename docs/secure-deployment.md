# Arquitetura de deploy seguro

Este documento descreve a arquitetura planejada para o primeiro CD do projeto no homelab.

A implementação ainda não foi concluída. O objetivo é registrar as decisões antes de provisionar as VMs e criar o workflow de deploy.

## Objetivo

Automatizar o deploy após o merge na `main` sem entregar acesso irrestrito de `root` ao GitHub Actions ou ao usuário de automação.

## Arquitetura proposta

```text
GitHub Repository
       │
       ├─ Pull Request
       │      └─ CI em runner hospedado pelo GitHub
       │
       └─ merge na main
              │
              ▼
       self-hosted runner
       VM exclusiva no homelab
              │
              │ SSH em rede privada
              ▼
       servidor da aplicação
              │
              ├─ usuário deploy
              ├─ sudo restrito
              ├─ script root-owned
              ├─ Compose protegido
              └─ Docker
```

## Separação de responsabilidades

### Runner de CI

Os testes de Pull Requests continuam em um runner hospedado pelo GitHub.

Esse runner:

- executa `pytest`;
- valida o Bash e o Docker Compose;
- constrói e testa a imagem;
- publica a imagem no GHCR após push na `main`.

### Self-hosted runner de CD

O self-hosted runner deve ficar em uma VM dedicada.

Ele não deve compartilhar o mesmo sistema operacional com a aplicação porque um workflow comprometido poderia afetar diretamente o serviço e seus dados.

O runner de CD deve executar apenas workflows confiáveis, acionados a partir da `main` protegida. Pull Requests externos ou não revisados não devem executar nesse runner.

### Servidor da aplicação

A aplicação deve ser executada em outra VM.

O servidor recebe somente o necessário para:

- autenticar no registry quando aplicável;
- baixar a imagem escolhida;
- atualizar o container;
- validar `/health` e `/ready`;
- realizar rollback.

## Conectividade

A comunicação entre o runner e o servidor deve ocorrer por rede privada.

Opções previstas:

- rede interna do Proxmox;
- Tailscale;
- WireGuard.

Não é necessário expor a porta SSH diretamente na internet.

A chave do host SSH deve ser validada e registrada em `known_hosts`. Não utilizar `StrictHostKeyChecking=no` para ignorar a identidade do servidor.

## Usuário de automação

O servidor terá um usuário dedicado chamado `deploy`.

Esse usuário não deve:

- utilizar a conta `root` diretamente;
- possuir `sudo` irrestrito;
- possuir acesso a `/usr/bin/bash` via `sudo`;
- poder editar scripts executados como `root`;
- poder editar arquivos que controlam indiretamente comandos executados como `root`.

## Regra mínima no sudoers

Exemplo planejado:

```sudoers
deploy ALL=(root) NOPASSWD: /usr/local/sbin/deploy-app
```

Essa regra permite executar somente o comando exato de deploy sem interação de senha.

Não utilizar regras amplas como:

```sudoers
deploy ALL=(root) NOPASSWD: ALL
deploy ALL=(root) NOPASSWD: /usr/bin/bash
deploy ALL=(root) NOPASSWD: /usr/local/sbin/*
```

## Proteção do script privilegiado

O script `/usr/local/sbin/deploy-app` deve pertencer ao `root`.

Exemplo:

```bash
sudo chown root:deploy /usr/local/sbin/deploy-app
sudo chmod 750 /usr/local/sbin/deploy-app
```

Resultado esperado:

```text
-rwxr-x--- root deploy /usr/local/sbin/deploy-app
```

O usuário `deploy` pode ler e executar o arquivo, mas não modificá-lo.

## Proteção dos arquivos consumidos pelo script

Proteger somente o script não é suficiente.

Se o script executar um `docker-compose.yml` editável pelo usuário `deploy`, esse usuário ainda poderá alterar o comportamento executado como `root`.

O arquivo Compose e seu diretório também devem ser protegidos.

Exemplo de diretório:

```bash
sudo chown root:deploy /opt/devops-sre-lab
sudo chmod 750 /opt/devops-sre-lab
```

Exemplo do Compose:

```bash
sudo chown root:deploy /opt/devops-sre-lab/docker-compose.yml
sudo chmod 640 /opt/devops-sre-lab/docker-compose.yml
```

Resultado esperado:

```text
drwxr-x--- root deploy /opt/devops-sre-lab
-rw-r----- root deploy /opt/devops-sre-lab/docker-compose.yml
```

O diretório não pode permitir escrita ao grupo `deploy`, pois a escrita no diretório permitiria apagar e substituir o arquivo mesmo sem permissão de escrita no arquivo original.

## Cuidados dentro do script

O script privilegiado deve:

- usar caminhos absolutos para comandos e arquivos importantes;
- evitar curingas em operações privilegiadas;
- não aceitar argumentos arbitrários sem validação;
- não executar arquivos editáveis pelo usuário `deploy`;
- não carregar configurações ou variáveis de arquivos não confiáveis;
- definir um ambiente previsível;
- interromper a execução em caso de erro;
- registrar mensagens suficientes para auditoria e troubleshooting.

## Imagem de deploy

O CD deve utilizar preferencialmente a tag imutável do SHA do commit:

```text
ghcr.io/lucasgonella/devops-sre-lab:<sha-completo>
```

A tag `latest` pode existir por conveniência, mas não deve ser a principal referência para um deploy reproduzível.

## Fluxo planejado

```text
merge na main
    ↓
CI testa e publica imagem com SHA
    ↓
workflow de CD recebe o SHA
    ↓
self-hosted runner conecta ao servidor
    ↓
IMAGE_TAG=<sha>
    ↓
sudo /usr/local/sbin/deploy-app
    ↓
pull + up -d
    ↓
health e readiness
    ↓
sucesso ou rollback
```

## Critérios para considerar o CD concluído

- [ ] Runner e aplicação executados em VMs separadas
- [ ] Comunicação realizada por rede privada
- [ ] Chave SSH dedicada ao deploy
- [ ] Host key validada em `known_hosts`
- [ ] Usuário `deploy` criado sem privilégios amplos
- [ ] Regra do `sudoers` limitada ao comando exato
- [ ] Script privilegiado pertencente ao `root`
- [ ] Compose e diretórios protegidos contra escrita
- [ ] Deploy acionado somente após merge confiável na `main`
- [ ] Imagem selecionada pela tag imutável do SHA
- [ ] Health e readiness validados
- [ ] Rollback testado entre duas imagens diferentes
