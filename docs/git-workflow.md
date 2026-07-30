# Fluxo de trabalho Git

Este documento registra o processo utilizado no projeto para trabalhar com branches, commits, Pull Requests e validações antes do merge na `main`.

## Fluxo resumido

```text
main atualizada
    ↓
branch de trabalho
    ↓
alteração local
    ↓
testes e validações
    ↓
commit
    ↓
push
    ↓
Pull Request
    ↓
CI aprovado
    ↓
merge
    ↓
limpeza da branch
```

## 1. Atualizar a `main`

```bash
git switch main
git pull --ff-only
```

O `--ff-only` impede a criação acidental de um merge commit durante o `pull`.

## 2. Criar uma branch

```bash
git switch -c feature/nome-da-alteracao
```

Prefixos utilizados:

- `feature/`: nova funcionalidade;
- `fix/`: correção de comportamento;
- `docs/`: documentação;
- `chore/`: manutenção técnica sem mudança funcional;
- `ci/`: alterações no pipeline.

Exemplos:

```text
feature/add-metrics
fix/deploy-rollback
ci/validate-deploy
docs/update-project-status
```

## 3. Revisar as alterações locais

```bash
git status
git diff
```

Antes do commit, executar as validações relacionadas à mudança.

### Testes Python

```bash
python -m pytest
```

### Sintaxe do script Bash

Linux ou Git Bash:

```bash
bash -n scripts/deploy.sh
```

PowerShell usando o Git Bash instalado no Windows:

```powershell
& "C:\Program Files\Git\bin\bash.exe" -n scripts/deploy.sh
```

### Docker Compose

Linux ou Git Bash:

```bash
IMAGE_TAG=test docker compose config
```

PowerShell:

```powershell
$env:IMAGE_TAG="test"
docker compose config
Remove-Item Env:IMAGE_TAG
```

## 4. Preparar o commit

Adicionar os arquivos desejados:

```bash
git add <arquivos>
```

Revisar exatamente o que será enviado:

```bash
git diff --cached
```

Validar problemas de whitespace:

```bash
git diff --cached --check
```

## 5. Criar o commit

```bash
git commit -m "tipo: descrição objetiva"
```

Exemplos:

```text
feat: add readiness dependency check
fix: preserve previous image tag during rollback
ci: validate deploy script and compose config
docs: document secure deployment architecture
```

Boas práticas:

- escrever a mensagem no imperativo ou como descrição direta da mudança;
- manter um único objetivo principal por commit;
- não incluir secrets, senhas, chaves ou arquivos `.env`;
- evitar commits genéricos como `ajustes` ou `alterações`.

## 6. Enviar a branch

```bash
git push -u origin <nome-da-branch>
```

O `-u` associa a branch local à branch remota.

## 7. Abrir o Pull Request

O Pull Request deve informar:

- o problema ou objetivo;
- o que foi alterado;
- como a mudança foi validada;
- riscos ou limitações conhecidos.

Checklist sugerido:

```text
[ ] A alteração possui escopo claro
[ ] Os testes locais passaram
[ ] A sintaxe Bash foi validada quando aplicável
[ ] O Docker Compose foi validado quando aplicável
[ ] Nenhum secret foi incluído
[ ] O diff foi revisado
```

## 8. Aguardar o CI

O pipeline atual verifica:

```text
pytest
→ bash -n scripts/deploy.sh
→ docker compose config
→ docker build
→ smoke test do container
```

Em pushes na `main`, o pipeline também publica no GHCR:

```text
ghcr.io/lucasgonella/devops-sre-lab:<sha-do-commit>
ghcr.io/lucasgonella/devops-sre-lab:latest
```

Não realizar o merge enquanto uma validação obrigatória estiver falhando.

## 9. Fazer o merge

Após aprovação do CI e revisão do conteúdo, realizar o merge pelo GitHub.

O projeto utiliza Pull Requests para preservar:

- rastreabilidade;
- revisão antes da integração;
- histórico das decisões;
- execução automática do pipeline.

## 10. Limpar o ambiente local

Após o merge:

```bash
git switch main
git pull --ff-only
git branch -d <nome-da-branch>
```

A branch remota também deve ser excluída após o merge.

## Regras de segurança

- não realizar push direto na `main`;
- não desativar validações apenas para concluir um merge;
- não versionar `.env`, tokens, chaves SSH ou credenciais;
- revisar comandos privilegiados e arquivos consumidos por eles;
- evitar `git push --force` em branches compartilhadas;
- não executar código de Pull Requests não confiáveis em um self-hosted runner com acesso ao ambiente interno.
